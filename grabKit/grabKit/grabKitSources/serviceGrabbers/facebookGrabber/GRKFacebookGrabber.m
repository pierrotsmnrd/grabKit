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


#import "GRKFacebookGrabber.h"
#import "GRKConnectorsDispatcher.h"
#import "GRKFacebookQuery.h"
#import "GRKAlbum.h"
#import "ISO8601DateFormatter.h"



@interface GRKFacebookGrabber()
-(BOOL) isResultForAlbumsInTheExpectedFormat:(id)result;
-(GRKAlbum *) albumWithRawAlbum:(NSDictionary*)rawAlbum;

-(BOOL) isResultForPhotosInTheExpectedFormat:(id)result;
-(GRKPhoto *) photoWithRawPhoto:(NSDictionary*)rawPhoto;

-(GRKImage *) imageWithRawImage:(NSDictionary*)rawImage originalWidth:(NSDecimalNumber*)originalWidth originalHeight:(NSDecimalNumber*)originalHeight;
@end



@implementation GRKFacebookGrabber


-(id) init {
    
    if ((self = [super initWithServiceName:kGRKServiceNameFacebook]) != nil){
        
        facebookConnector = nil;

    }     
    
    return self;
}

#pragma mark - GRKServiceGrabberConnectionProtocol methods


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)connectionIsCompleteBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{

    // First, reinitialize the connector, if it has been already used
    [facebookConnector cancelAll]; 
    
    
    // use a GRKFacebookConnector
    facebookConnector = [[GRKFacebookConnector alloc] initWithGrabberType:_serviceName];
    
    [facebookConnector connectWithConnectionIsCompleteBlock:^(BOOL connected){
                     
                     if ( connectionIsCompleteBlock != nil ){
                         dispatch_async(dispatch_get_main_queue(), ^{
                         connectionIsCompleteBlock(connected);
                         });
                     }
                     
                    facebookConnector = nil;
                     
                 } andErrorBlock:^(NSError * error){
        
                        if ( errorBlock != nil ){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                errorBlock(error);
                            });
                        }
                   
                     facebookConnector = nil;
                }];
    
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;
{
    // First, reinitialize the connector, if it has been already used
   [facebookConnector cancelAll]; 
    
    
    // use a GRKFacebookConnector
    facebookConnector = [[GRKFacebookConnector alloc] initWithGrabberType:_serviceName];
    
    [facebookConnector disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected){
        
        if ( disconnectionIsCompleteBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
            disconnectionIsCompleteBlock(disconnected);
            });
        }
        facebookConnector = nil;
        
    }];
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{

    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    
    // First, reinitialize the connector, if it has been already used
    [facebookConnector cancelAll];
    
    // use a GRKFacebookConnector
    facebookConnector = [[GRKFacebookConnector alloc] initWithGrabberType:_serviceName];
    
    [facebookConnector isConnected:^(BOOL connected){
        
            dispatch_async(dispatch_get_main_queue(), ^{
            connectedBlock(connected);
          
                facebookConnector = nil;
    	});
        
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

    
    NSMutableDictionary * params = [NSMutableDictionary  dictionaryWithObjectsAndKeys:@"id,name,count,updated_time,created_time,location", @"fields", nil];
    
    NSNumber * offset = [NSNumber numberWithInt:(pageIndex * numberOfAlbumsPerPage )];
    [params setObject:[offset stringValue] forKey:@"offset"];	
    [params setObject:[NSString stringWithFormat:@"%d", numberOfAlbumsPerPage] forKey:@"limit"];
    
    
   __block GRKFacebookQuery * albumsQuery = nil;
    
    albumsQuery = [GRKFacebookQuery queryWithGraphPath:@"me/albums"
                                 withParams:params
                  withHandlingBlock:^(GRKFacebookQuery * fbquery, id result){
                      
                      if ( ! [self isResultForAlbumsInTheExpectedFormat:result] ){
                          if ( errorBlock != nil ) {

                              // Create an error for "bad format result" and call the errorBlock
                              NSError * error = [self errorForBadFormatResultForAlbumsOperation];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  errorBlock(error);
                              });
                          }
                          [self unregisterQueryAsLoading:albumsQuery];
                          albumsQuery = nil;
                          
                          return;
                      }
                      
                      // handle each album data to build a NSMutableDictionary of GRKAlbum objects
                      
                      NSArray * rawAlbums = [(NSDictionary *)result objectForKey:@"data"];
                      NSMutableArray * albums = [NSMutableArray arrayWithCapacity:[rawAlbums count]];
                      
                      for( NSDictionary * rawAlbum in rawAlbums ){
                     
                          @autoreleasepool {
                              GRKAlbum * album = [self albumWithRawAlbum:rawAlbum];
                              [albums addObject:album];
                          }
                          
                      }
                      
                      if ( completeBlock != nil ) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                          completeBlock(albums);
                          });
                      }
                      [self unregisterQueryAsLoading:albumsQuery];
                      albumsQuery = nil;
                      
                  }andErrorBlock:^(NSError * error){
                      
                      if ( errorBlock != nil) {
                          NSError * GRKError = [self errorForAlbumsOperationWithOriginalError:error];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              errorBlock(GRKError);
                          });
                      }
                      [self unregisterQueryAsLoading:albumsQuery];
                      albumsQuery = nil;
                      
                  }] ;
    
    [self registerQueryAsLoading:albumsQuery];
    [albumsQuery perform];
    
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
    
    NSNumber * offset = [NSNumber numberWithInt:(pageIndex * numberOfPhotosPerPage )];
    [params setObject:[offset stringValue] forKey:@"offset"];	
    [params setObject:[NSString stringWithFormat:@"%d", numberOfPhotosPerPage] forKey:@"limit"];
    
    __block GRKFacebookQuery * fillAlbumQuery = nil;
    
    fillAlbumQuery = [GRKFacebookQuery queryWithGraphPath:[NSString stringWithFormat:@"%@/photos", album.albumId ]
                                     withParams:params
                              withHandlingBlock:^(GRKFacebookQuery * fbquery, id result){
                                  
                                  if ( ! [self isResultForPhotosInTheExpectedFormat:result] ){
                                      if ( errorBlock != nil ){
                                          // Create an error for "bad format result" and call the errorBlock
                                          NSError * error = [self errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:album];
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              errorBlock(error);
                                          });
                                      }
                                    
                                      [self unregisterQueryAsLoading:fillAlbumQuery];
                                      fillAlbumQuery = nil;
                                      return;
                                  }
                                  
                                  NSArray * rawPhotos = [(NSDictionary *)result objectForKey:@"data"];
                                  
                                  NSMutableArray * newPhotos = [NSMutableArray array];
                                  
                                  for( NSDictionary * rawPhoto in rawPhotos ){
                                     
                                      @autoreleasepool {

                                          GRKPhoto * photo = [self photoWithRawPhoto:rawPhoto];
                                          // add photo to the result
                                          [newPhotos addObject:photo];
                                      }
                                      
                                  }
                                  
                                  
                                  // add the new photos in the album
                                  [album addPhotos:newPhotos forPageIndex:pageIndex withNumberOfPhotosPerPage:numberOfPhotosPerPage];
                                  
                                  // pass the new photos to the completeBlock
                                  if ( completeBlock != nil ){
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completeBlock(newPhotos);
                                      });
                                  }
                                  
                                  [self unregisterQueryAsLoading:fillAlbumQuery];
                                  fillAlbumQuery = nil;
                                  
                              }andErrorBlock:^(NSError * error){
                                  
                                  if ( errorBlock != nil ){
                                      
                                      NSError * GRKError = [self errorForFillAlbumOperationWithOriginalError:error];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          errorBlock(GRKError);
                                      });
                                  }
                                  
                                  [self unregisterQueryAsLoading:fillAlbumQuery];
                                  fillAlbumQuery = nil;
                                  
                              }];
    [self registerQueryAsLoading:fillAlbumQuery];
    [fillAlbumQuery perform];
    
}


/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) cancelAll {
    
    [facebookConnector cancelAll];
    
    NSArray * queriesToCancel = [NSArray arrayWithArray:_queries];
    
    for( GRKFacebookQuery * query in queriesToCancel ){
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
    if ( ! [result isKindOfClass:[NSDictionary class]] ){
        return NO;
    }
    if ( [(NSDictionary *)result objectForKey:@"data"] == nil ){
        return NO;
    }
    if ( ! [[(NSDictionary *)result objectForKey:@"data"] isKindOfClass:[NSArray class]] ){
        return NO;
    }    
    
    return YES;  
}

/** Build and return a GRKAlbum from the given dictionary.

 @param rawAlbum a NSDictionary representing the album to build, as returned by Facebook's API
 @return an autoreleased GRKAlbum
*/
-(GRKAlbum *) albumWithRawAlbum:(NSDictionary*)rawAlbum;
{
    
    NSString * albumId = [rawAlbum objectForKey:@"id"];
    NSString * name = [rawAlbum objectForKey:@"name"];
    NSUInteger count = [[rawAlbum objectForKey:@"count"] intValue];
    
    // raw dates stored as strings in the FB result. 
    // there are ISO 8601 dates, looking like : 2010-09-08T21:11:25+0000
    NSString * dateCreatedDatetimeISO8601String = [rawAlbum objectForKey:@"created_time"];
    NSString * dateUpdatedDatetimeISO8601String = [rawAlbum objectForKey:@"updated_time"];
    
    // convert the string dates to NSDate
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate * dateCreated = [formatter dateFromString:dateCreatedDatetimeISO8601String];
    NSDate * dateUpdated = [formatter dateFromString:dateUpdatedDatetimeISO8601String];

    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    if (dateCreated != nil) [dates setObject:dateCreated forKey:kGRKAlbumDatePropertyDateCreated];
    if (dateUpdated != nil) [dates setObject:dateUpdated forKey:kGRKAlbumDatePropertyDateUpdated];
    
    
    GRKAlbum * album = [GRKAlbum albumWithId:albumId andName:name andCount:count andDates:dates];
    
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
    if ( [(NSDictionary *)result objectForKey:@"data"] == nil ){
        return NO;    }
    if ( ! [[(NSDictionary *)result objectForKey:@"data"] isKindOfClass:[NSArray class]] ){
        return NO;
    }
    
    return YES;
}


/** Build and return a GRKPhoto from the given dictionary.
 
 @param rawPhoto a NSDictionary representing the photo to build, as returned by Facebook's API
 @return an autoreleased GRKPhoto
 */
-(GRKPhoto *) photoWithRawPhoto:(NSDictionary*)rawPhoto;
{
    NSString * photoId = [rawPhoto objectForKey:@"id"];

	// on Facebook, the "name" value of a photo is its caption
    NSString * photoCaption = [rawPhoto objectForKey:@"name"]  ;
    
    // raw dates stored as strings in the FB result. 
    // they are ISO 8601 dates, looking like : 2010-09-08T21:11:25+0000
    NSString * dateCreatedDatetimeISO8601String = [rawPhoto objectForKey:@"created_time"];
    NSString * dateUpdatedDatetimeISO8601String = [rawPhoto objectForKey:@"updated_time"];
    
    // convert the string dates to NSDate
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate * dateCreated = [formatter dateFromString:dateCreatedDatetimeISO8601String];
    NSDate * dateUpdated = [formatter dateFromString:dateUpdatedDatetimeISO8601String];
    
    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    if (dateCreated != nil) [dates setObject:dateCreated forKey:kGRKPhotoDatePropertyDateCreated];
    if (dateUpdated != nil) [dates setObject:dateUpdated forKey:kGRKPhotoDatePropertyDateUpdated];
    
    
    // Width and Height of the original image. will be used to set the isOriginal value when we build images
    NSDecimalNumber * originalHeight = [rawPhoto objectForKey:@"height"];
    NSDecimalNumber * originalWidth = [rawPhoto objectForKey:@"width"];
    
    
    NSMutableArray * images = [NSMutableArray array];
    
    for( NSDictionary * rawImage in [rawPhoto objectForKey:@"images"] ){
        GRKImage * image = [self imageWithRawImage:rawImage originalWidth:originalWidth originalHeight:originalHeight];
    	[images addObject:image];   
    }
    
    GRKPhoto * photo = [GRKPhoto photoWithId:photoId andCaption:photoCaption andName:nil andImages:images andDates:dates];
    
    return photo;
}


/** Build and return a GRKImage from the given dictionary.
 
 @param rawImage a NSDictionary representing the image to build, as returned by Facebook's API
 @param originalWidth the width of the original photo. it is used to define if the result GRKImage is original or not.
 @param originalHeight the height of the original photo. it is used to define if the result GRKImage is original or not.
 @return an autoreleased GRKImage
 */
-(GRKImage *) imageWithRawImage:(NSDictionary*)rawImage originalWidth:(NSDecimalNumber*)originalWidth originalHeight:(NSDecimalNumber*)originalHeight;
{
    
    BOOL sameWidth = [(NSDecimalNumber*)[rawImage objectForKey:@"width"] compare:originalWidth] == NSOrderedSame;
    BOOL sameHeight = [(NSDecimalNumber*)[rawImage objectForKey:@"height"] compare:originalHeight] == NSOrderedSame;
    
    GRKImage * image = [GRKImage imageWithURLString:[rawImage objectForKey:@"source"] 
                                   andWidth:[[rawImage objectForKey:@"width"] intValue]  
                                  andHeight:[[rawImage objectForKey:@"height"]  intValue]
                                 isOriginal:sameWidth && sameHeight];
    
	return image;
    
}


@end
