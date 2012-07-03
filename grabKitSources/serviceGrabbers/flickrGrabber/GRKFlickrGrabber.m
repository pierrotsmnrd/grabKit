/*
 * This file is part of the GrabKit package.
 * Copyright (c) 2012 Pierre-Olivier Simonard <pierre.olivier.simonard@gmail.com>
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
 * associated documentation files (the "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the 
 * following conditions:
 *  
 * The above copyright notice and this permission notice shall be included in all copies or substantial 
 * portions of the Software.
 *  
 * The Software is provided "as is", without warranty of any kind, express or implied, including but not 
 * limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no
 * event shall the authors or copyright holders be liable for any claim, damages or other liability, whether
 * in an action of contract, tort or otherwise, arising from, out of or in connection with the Software or the 
 * use or other dealings in the Software.
 *
 * Except as contained in this notice, the name(s) of (the) Author shall not be used in advertising or otherwise
 * to promote the sale, use or other dealings in this Software without prior written authorization from (the )Author.
 */

#import "GRKFlickrGrabber.h"
#import "GRKFlickrConstants.h"
#import "GRKFlickrConnector.h"
#import "GRKFlickrQuery.h"
#import "GRKAlbum.h"
#import "NSString+date.h"

@interface GRKFlickrGrabber()
-(BOOL) isResultForAlbumsInTheExpectedFormat:(id)result;
-(GRKAlbum *) albumWithRawAlbum:(NSDictionary*)rawAlbum;

-(BOOL) isResultForPhotosInTheExpectedFormat:(id)result;
-(GRKPhoto *) photoWithRawPhoto:(NSDictionary*)rawPhoto;

-(GRKImage *) imageWithRawPhotoDictionary:(NSDictionary*)rawPhoto forSizeKey:(NSString*)sizeKey;
@end

@implementation GRKFlickrGrabber


-(id) init {
    
    if ((self = [super initWithServiceName:kGRKServiceNameFlickr]) != nil){
        
        NSAssert( ! [kGRKFlickrApiKey  isEqualToString:@""], @"FlickR constant 'kGRKFlickrApiKey ' is not set." ); 
        NSAssert( ! [kGRKFlickrApiSecret  isEqualToString:@""], @"FlickR constant 'kGRKFlickrApiSecret ' is not set." ); 
		NSAssert( ! [kGRKFlickrAppName  isEqualToString:@""], @"FlickR constant 'kGRKFlickrAppName ' is not set." ); 
        
    }     
    
    return self;
}


#pragma mark - GRKServiceGrabberConnectionProtocol methods


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)connectionIsCompleteBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    // use a GRKFlickrConnector 
    __block GRKFlickrConnector * flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];
    
    [flickrConnector connectWithConnectionIsCompleteBlock:^(BOOL connected){
        
        if ( connectionIsCompleteBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                connectionIsCompleteBlock(connected);
            });
        }
        [flickrConnector release];
        
    } andErrorBlock:^(NSError * error){
        
        if ( errorBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        
        [flickrConnector release];                                            
        
    } ];
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;
{
    // use a GRKFlickrConnector 
    __block GRKFlickrConnector * flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];
    
    [flickrConnector disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected){
        
        if ( disconnectionIsCompleteBlock != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
	            disconnectionIsCompleteBlock(disconnected);
            });
        }
        
        [flickrConnector release];        
        
    } ];
    
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{
    
    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    
    // use a GRKFlickrConnector
    __block GRKFlickrConnector * flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];
    
    [flickrConnector isConnected:^(BOOL connected){
        dispatch_async(dispatch_get_main_queue(), ^{        
            connectedBlock(connected);
        });
        [flickrConnector release];	
        
    }];
    
    
}


#pragma mark GRKServiceGrabberProtocol methods



/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) albumsOfCurrentUserAtPageIndex:(NSUInteger)pageIndex
              withNumberOfAlbumsPerPage:(NSUInteger)numberOfAlbumsPerPage
                       andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                          andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    if ( numberOfAlbumsPerPage > kGRKMaximumNumberOfAlbumsPerPage ) {
        
        NSException* exception = [NSException
                                  exceptionWithName:@"numberOfAlbumsPerPageTooHigh"
                                  reason:[NSString stringWithFormat:@"The number of albums per page you asked (%d) is too high", numberOfAlbumsPerPage]
                                  userInfo:nil];
        @throw exception;
    }

    
    NSMutableDictionary * params = [NSMutableDictionary  dictionary];
    
    // use pageIndex+1 because Flickr starts at page 1, and we start at page 0
    [params setObject:[[NSNumber numberWithInt:pageIndex+1] stringValue] forKey:@"page"];  
    [params setObject:[[NSNumber numberWithInt:numberOfAlbumsPerPage] stringValue] forKey:@"per_page"];   
    
    	//#warning for dev only
        //[params setObject:@"35591378@N03" forKey:@"user_id"];
	
    
    
    __block GRKFlickrQuery * query = nil;
    
    query = [GRKFlickrQuery queryWithMethod:@"flickr.photosets.getList"
                                 andParams:params
                         withHandlingBlock:^(GRKFlickrQuery * query, id result){
                             
                             if ( ! [self isResultForAlbumsInTheExpectedFormat:result]){
                                 if ( errorBlock != nil ){
                                     
                                     // Create an error for "bad format result" and call the errorBlock
                                     NSError * error = [self errorForBadFormatResultForAlbumsOperation];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         errorBlock(error);
                                     });

                                 }
                                 [query release];
                                 return;
                             }
                             
                             // handle each album data to build a NSMutableDictionary of GRKAlbum objects
                             
                             NSArray * rawAlbums = [[(NSDictionary *)result objectForKey:@"photosets"] objectForKey:@"photoset"];
                             NSMutableArray * albums = [NSMutableArray arrayWithCapacity:[rawAlbums count]];
                             
                             for( NSDictionary * rawAlbum in rawAlbums ){
                                 NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                                 
                                 GRKAlbum * album = [self albumWithRawAlbum:rawAlbum];
                                 [albums addObject:album];
                                 
                                 [pool drain];
                             }
                             
                             if ( completeBlock != nil ) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completeBlock(albums);
                                 });
                             }
                             [self unregisterQueryAsLoading:query];
                             
                             
                         }andErrorBlock:^(NSError * error){
                             
                             if ( errorBlock != nil ){
                                 NSError * GRKError = [self errorForAlbumsOperationWithOriginalError:error];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     errorBlock(GRKError);
                                 });
                             }
                             [self unregisterQueryAsLoading:query];
                             
                         }] ;
    [self registerQueryAsLoading:query];
    [query perform];
}



/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) fillAlbum:(GRKAlbum *)album
withPhotosAtPageIndex:(NSUInteger)pageIndex
withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage
 andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
    andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    
    if ( numberOfPhotosPerPage > kGRKMaximumNumberOfPhotosPerPage ) {
        
        NSException* exception = [NSException
                                  exceptionWithName:@"numberOfPhotosPerPageTooHigh"
                                  reason:[NSString stringWithFormat:@"The number of photos per page you asked (%d) is too high", numberOfPhotosPerPage]
                                  userInfo:nil];
        @throw exception;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary  dictionary];
    
    // set the album id ("photoset" for FlickR) 
    [params setObject:album.albumId forKey:@"photoset_id"];
    
    // use pageIndex+1 because Flickr starts at page 1, and we start at page 0
    [params setObject:[[NSNumber numberWithInt:pageIndex+1] stringValue] forKey:@"page"];  
    [params setObject:[[NSNumber numberWithInt:numberOfPhotosPerPage] stringValue] forKey:@"per_page"];   
    
    // ask only for photos, not for videos
    [params setObject:@"photos" forKey:@"media"];   
    
    NSArray * fields = [NSArray arrayWithObjects:@"date_upload",
                        @"date_taken", 
                        @"last_update", 
                        @"original_format",
                        @"o_dims",
                        @"description",
                        @"url_l",
                        @"url_sq",
                        @"url_t",
                        @"url_s",
                        @"url_m",
                        @"url_o",
                        nil];
    
    [params setObject:[fields componentsJoinedByString:@","] forKey:@"extras"];
    
    __block GRKFlickrQuery * query = nil;
    
    query = [[GRKFlickrQuery queryWithMethod:@"flickr.photosets.getPhotos"
                                  andParams:params
                          withHandlingBlock:^(GRKFlickrQuery * query, id result){
                              
                              
                              if ( ! [self isResultForPhotosInTheExpectedFormat:result] ){
                                  if ( errorBlock != nil ){
                                      
                                      // Create an error for "bad format result" and call the errorBlock
                                      NSError * error = [self errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:album];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          errorBlock(error);
                                      });
                                      
                                  }
                                  [query release];
                                  return;
                              }
                              
                              
                              // If there are more photos, rawPhotos is an NSArray.
                              // But if there is only 1 photo in the photoset, rawPhotos is a NSDictionary.
                              // Let's have a NSArray in every cases.
                              
                              id rawPhotos = [[(NSDictionary *)result objectForKey:@"photoset"] objectForKey:@"photo"];
                              if ( [rawPhotos isKindOfClass:[NSDictionary class]] ){
                                  rawPhotos = [NSArray arrayWithObject:rawPhotos];
                              }
                              
                              
                              NSMutableArray * newPhotos = [NSMutableArray array];
                              
                              
                              for( NSDictionary * rawPhoto in rawPhotos ){
                                  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                                  
                                  GRKPhoto * photo = [self photoWithRawPhoto:rawPhoto];
                                  [newPhotos addObject:photo];
                                  
                                  [pool drain];
                              }
                              
                              [album addPhotos:newPhotos forPageIndex:pageIndex withNumberOfPhotosPerPage:numberOfPhotosPerPage];
                              
                              if ( completeBlock != nil ){
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      completeBlock(newPhotos);
                                  });
                              }
                              
                              [self unregisterQueryAsLoading:query];
                              
                          }andErrorBlock:^(NSError * error){
                              
                              if ( errorBlock != nil ){
                                  NSError * GRKError = [self errorForFillAlbumOperationWithOriginalError:error];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      errorBlock(GRKError);
                                  });

                              }
                              [self unregisterQueryAsLoading:query];
                          }] retain];
    
    [self registerQueryAsLoading:query];
    [query perform];
}



/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) cancelAll {
    
    NSArray * queriesToCancel = [NSArray arrayWithArray:_queries];
    
    for( GRKFlickrQuery * query in queriesToCancel ){
        
        [query cancel];
        [self unregisterQueryAsLoading:query];
    }
    
}



/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) cancelAllWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock;
{
    [self cancelAll];
    if ( completeBlock != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(nil);
        });
    }
    
}


#pragma mark - Internal processing methods


/** Check if the given result for an album is in the expected format.
 @param result the data to check. 
 @return  a boolean value. if YES, the data are in the expected format.
 
 */
-(BOOL) isResultForAlbumsInTheExpectedFormat:(id)result;
{
    
    // check if the result has the expected format
    if ( ! [result isKindOfClass:[NSDictionary class]] ){
		return NO;
    }
    
    if ( [(NSDictionary *)result objectForKey:@"photosets"] == nil ){
        return NO;
    }
    /*    if ( ! [[[(NSDictionary *)result objectForKey:@"photosets"] objectForKey:@"photoset"] isKindOfClass:[NSArray class]] ){
     return NO;
     }
     */
    return YES;
}



/** Build and return a GRKAlbum from the given dictionary.
 
 @param rawAlbum a NSDictionary representing the album to build, as returned by FlickR's API
 @return an autoreleased GRKAlbum
 */
-(GRKAlbum *) albumWithRawAlbum:(NSDictionary*)rawAlbum;
{
    
    NSString * albumId = [rawAlbum objectForKey:@"id"];
    NSString * name = [[rawAlbum objectForKey:@"title"] objectForKey:@"_text"];
    NSUInteger count = [[rawAlbum objectForKey:@"photos"] intValue];
    
    // raw dates stored as timestamps in the FlickR's result. 
    NSTimeInterval dateCreatedTimestamp = [[rawAlbum objectForKey:@"date_create"] doubleValue];
    NSTimeInterval dateUpdatedTimestamp = [[rawAlbum objectForKey:@"date_update"] doubleValue];                                  
    
    NSDate * dateCreated = [NSDate dateWithTimeIntervalSince1970:dateCreatedTimestamp];
    NSDate * dateUpdated = [NSDate dateWithTimeIntervalSince1970:dateUpdatedTimestamp]; 
    
    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    if (dateCreated != nil) [dates setObject:dateCreated forKey:kGRKPhotoDatePropertyDateCreated];
    if (dateUpdated != nil) [dates setObject:dateUpdated forKey:kGRKPhotoDatePropertyDateUpdated];
    
    
    GRKAlbum * album = [GRKAlbum albumWithId:albumId andName:name andCount:count /*andPhotos:nil*/ andDates:dates];
    
	return album;
    
    
}

/** Check if the given result for a photo is in the expected format.
 @param result the data to check. 
 @return  a boolean value. if YES, the data are in the expected format.
 
 */
-(BOOL) isResultForPhotosInTheExpectedFormat:(id)result;
{
    // check if the result as the expected format, calls errorBlock if not.
    if ( ! [result isKindOfClass:[NSDictionary class]] ){
        return NO;
    }
    if ( [(NSDictionary *)result objectForKey:@"photoset"] == nil ){
        return NO;
    }
    /*
     if ( ! [[[(NSDictionary *)result objectForKey:@"photoset"] objectForKey:@"photo"] isKindOfClass:[NSArray class]] ){
     return NO;
     }
     */ 
    return YES;
}




/** Build and return a GRKPhoto from the given dictionary.
 
 @param rawPhoto a NSDictionary representing the photo to build, as returned by FlickR's API
 @return an autoreleased GRKPhoto
 */
-(GRKPhoto *) photoWithRawPhoto:(NSDictionary*)rawPhoto;
{
    
    NSString * photoId = [rawPhoto objectForKey:@"id"];
    NSString * photoName = [rawPhoto objectForKey:@"title"] ;
    
    NSString * caption = @"";
    if  ( [[rawPhoto objectForKey:@"description"] isKindOfClass:[NSDictionary class]] )
        caption = [[rawPhoto objectForKey:@"description"] objectForKey:@"_text"];
    
    
    // raw dates stored as timestamps in the FlickR's result. 
    NSTimeInterval dateCreatedTimestamp = [[rawPhoto objectForKey:@"dateupload"] doubleValue];
    NSTimeInterval dateUpdatedTimestamp = [[rawPhoto objectForKey:@"lastupdate"] doubleValue];                                  
    // The "date Taken" value is stored as formated date string like : "2011-12-17 18:31:40"
    NSString * dateTakenDatetimeString = [rawPhoto objectForKey:@"datetaken"];
    
    NSDate * dateCreated = [NSDate dateWithTimeIntervalSince1970:dateCreatedTimestamp];
    NSDate * dateUpdated = [NSDate dateWithTimeIntervalSince1970:dateUpdatedTimestamp]; 
    NSDate * dateTaken = [dateTakenDatetimeString dateWithFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    if (dateCreated != nil) [dates setObject:dateCreated forKey:kGRKPhotoDatePropertyDateCreated];
    if (dateUpdated != nil) [dates setObject:dateUpdated forKey:kGRKPhotoDatePropertyDateUpdated];
    if (dateTaken != nil) [dates setObject:dateTaken forKey:kGRKPhotoDatePropertyDateTaken];
    
    
    // let's use the flickrSizes to build the images
    NSMutableArray * images = [NSMutableArray array];
    NSArray * flickrSizes = [NSArray arrayWithObjects:@"m", @"o", @"s", @"sq", @"t", @"l", nil];
    
    for( NSString * size in  flickrSizes ){
        GRKImage * image = [self imageWithRawPhotoDictionary:rawPhoto forSizeKey:size];
        if ( image != nil ){
            [images addObject:image];
        }
    }
    
    
    GRKPhoto * photo = [GRKPhoto photoWithId:photoId andCaption:caption andName:photoName andImages:images andDates:dates];
    return photo;
}




/** Build and return a GRKImage from the given dictionary.
 
 @param rawPhoto a NSDictionary representing the image to build, as returned by FlickR's API
 @param sizeKey a string representing the category of size, according to FlickR's API. s:small, sq:square, ..., o:original, l:large
 @return an autoreleased GRKImage
 */
-(GRKImage *) imageWithRawPhotoDictionary:(NSDictionary*)rawPhoto forSizeKey:(NSString*)sizeKey;
{
    
    NSString * heightKey = [NSString stringWithFormat:@"height_%@", sizeKey];
    NSString * widthKey = [NSString stringWithFormat:@"width_%@", sizeKey];
    NSString * urlKey = [NSString stringWithFormat:@"url_%@", sizeKey];
    
    if ( [rawPhoto objectForKey:heightKey] != nil
        && [rawPhoto objectForKey:widthKey] != nil
        && [rawPhoto objectForKey:urlKey] != nil ){
        
        BOOL isOriginal = [sizeKey isEqualToString:@"o"] || [sizeKey isEqualToString:@"l"];
        GRKImage * image = [GRKImage imageWithURLString:[rawPhoto objectForKey:urlKey] 
                                             andWidth:[[rawPhoto objectForKey:widthKey] intValue]  
                                            andHeight:[[rawPhoto objectForKey:heightKey] intValue]
                                           isOriginal:isOriginal];
        return image;
    }
    
    return nil;
}




@end
