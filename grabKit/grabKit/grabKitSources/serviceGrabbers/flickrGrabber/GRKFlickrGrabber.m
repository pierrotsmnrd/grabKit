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
#import "GRKConstants.h"
#import "GRKFlickrQuery.h"
#import "GRKAlbum.h"
#import "NSString+date.h"

#import "GRKFlickrQueriesQueue.h"

@interface GRKFlickrGrabber()
-(BOOL) isResultForAlbumsInTheExpectedFormat:(id)result;
-(GRKAlbum *) albumWithRawAlbum:(NSDictionary*)rawAlbum;

-(BOOL) isResultForPhotosInTheExpectedFormat:(id)result;
-(GRKPhoto *) photoWithRawPhotoFromPhotosetsGetPhotos:(NSDictionary*)rawPhoto;


-(GRKPhoto *) photoWithRawDataFromPhotosGetInfos:(NSDictionary*)rawDataPhotosGetInfos andRawDataFromPhotosGetSizes:(NSDictionary*)rawDataPhotosGetSizes;


-(GRKImage *) imageWithRawPhotoDictionary:(NSDictionary*)rawPhoto forSizeKey:(NSString*)sizeKey;

-(void)resetAndRebuildConnector;
@end

@implementation GRKFlickrGrabber


-(id) init {
    
    if ((self = [super initWithServiceName:kGRKServiceNameFlickr]) != nil){
        
    }     
    
    return self;
}


#pragma mark - GRKServiceGrabberConnectionProtocol methods


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)connectionIsCompleteBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    [self resetAndRebuildConnector];
    
    // use a GRKFlickrConnector 
    flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];
    
    [flickrConnector connectWithConnectionIsCompleteBlock:^(BOOL connected){
        
        if ( connectionIsCompleteBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                connectionIsCompleteBlock(connected);
            });
        }

        flickrConnector = nil;
        
    } andErrorBlock:^(NSError * error){
        
        if ( errorBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
        
        flickrConnector = nil;      
        
    }];
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;
{
    
    [self resetAndRebuildConnector];
    
    // use a GRKFlickrConnector 
    flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];
    
    [flickrConnector disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected){
        
        if ( disconnectionIsCompleteBlock != nil ) {
            dispatch_async(dispatch_get_main_queue(), ^{
	            disconnectionIsCompleteBlock(disconnected);
            });
        }
           
        flickrConnector = nil;
        
    }];
    
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{
    
    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    
    [self resetAndRebuildConnector];
    
    [flickrConnector isConnected:^(BOOL connected){
        dispatch_async(dispatch_get_main_queue(), ^{        
            connectedBlock(connected);
        });

        flickrConnector = nil;
        
    }];
    
    
}


-(void)resetAndRebuildConnector;
{
    
    [flickrConnector cancelAll];
    
    // use a GRKFlickrConnector 
    flickrConnector = [[GRKFlickrConnector alloc] initWithGrabberType:_serviceName];

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
    
    __block GRKFlickrQuery * albumsQuery = nil;
    
    albumsQuery = [GRKFlickrQuery queryWithMethod:@"flickr.photosets.getList"
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

                                 [self unregisterQueryAsLoading:albumsQuery];
                                 albumsQuery = nil;
                                 
                                 return;
                             }
                             
                             // handle each album data to build a NSMutableDictionary of GRKAlbum objects
                             
                             NSArray * rawAlbums = [[(NSDictionary *)result objectForKey:@"photosets"] objectForKey:@"photoset"];
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
                             
                             if ( errorBlock != nil ){
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
    
    __block GRKFlickrQuery * fillAlbumQuery = nil;
    
    fillAlbumQuery = [GRKFlickrQuery queryWithMethod:@"flickr.photosets.getPhotos"
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

                                  [self unregisterQueryAsLoading:fillAlbumQuery];
                                  fillAlbumQuery = nil;
                                  
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
                                
                                  @autoreleasepool {
                                      GRKPhoto * photo = [self photoWithRawPhotoFromPhotosetsGetPhotos:rawPhoto];
                                      [newPhotos addObject:photo];
                                  }
                              }
                              
                              [album addPhotos:newPhotos forPageIndex:pageIndex withNumberOfPhotosPerPage:numberOfPhotosPerPage];
                              
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

-(void) fillCoverPhotoOfAlbums:(NSArray *)albums withCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock {

    
    /* To retrieve the coverPhoto of ONE album, there are 3 queries to perform :
     1) One query to get the id of the cover photo for the given photo album  (i.e, in Flickr's language, get the id of the primary photo of the given photoset)
        Once we have this id, we can perform ...
     
     2) ... one query to get infos for the cover photo (with the FlickR API method flickr.photos.getInfo)
     3) ... and one query to get images for the cover photo (with the FlickR API method flickr.photos.getSizes)
     
     Then, we can build a GRKPhoto from the results of these queries
    
     
     So, for SEVERAL albums, the plan is : 
     _ First, retrieve the id of the coverPhoto of ALL the given albums. That'll be a first queriesQueue.
     _ Then, retrieve data (infos+images) to build GRKPhoto and update the albums. That'll be a second queriesQueue
     
     */
    
    
    
    //First, build and execute a queriesQueue to retrieve the cover photo ids of the given albums
    
    __block GRKFlickrQueriesQueue * queueForCoverPhotoIds = [[GRKFlickrQueriesQueue alloc] init];
    

    for( GRKAlbum * album in albums ){
        
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:album.albumId forKey:@"photoset_id"];
        
         // We use the album_id as query name. that'll be useful later ;)
        
        [queueForCoverPhotoIds addQueryWithMethod:@"flickr.photosets.getInfo"
                                        andParams:params 
                                          andName:album.albumId
                                 andHandlingBlock:^id(GRKFlickrQueriesQueue *queue, id result, NSError *error) {

                                     // If the result is not in the expected format, ...
                                     if ( error != nil 
                                         ||  ! [result isKindOfClass:[NSDictionary class]]
                                         ||  [result objectForKey:@"photoset"] == nil 
                                         ||  [[result objectForKey:@"photoset"] objectForKey:@"primary"] == nil ){
                                         
                                         // .. just return nil. this album won't have its coverPhoto set
                                         return nil;
                                     }
                                     
                                     // else return the coverPhoto id
                                     return [[result objectForKey:@"photoset"] objectForKey:@"primary"];
                                     
                                 }];
        
    }
    
    [self registerQueryAsLoading:queueForCoverPhotoIds];
    
    // Perform the queue to retrieve the cover photo ids of the given albums
    [queueForCoverPhotoIds performWithFinalBlock:^(id query, id results) {
       
        
         // at this point, result is a dictionary with the albums ids as keys, and their coverPhoto id as value.
   
         // Let's make another queue to get data for each of these coverPhotos ...
         __block GRKFlickrQueriesQueue * subQueueForCoverPhotosData = [[GRKFlickrQueriesQueue alloc] init];
         
         
          for( NSString * albumId in [results allKeys] ){
          
            NSString * coverPhotoId = [results objectForKey:albumId];
            NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObject:coverPhotoId forKey:@"photo_id"];
              
            // ... First, retrieve the photo's informations ...
            [subQueueForCoverPhotosData addQueryWithMethod:@"flickr.photos.getInfo"
                                          andParams:params 
                                            andName:[NSString stringWithFormat:@"flickr.photos.getInfo_%@", albumId]
                                   andHandlingBlock:^id(GRKFlickrQueriesQueue *queue, id result, NSError *error) {
                                       
                                       if ( error != nil || [result objectForKey:@"photo"] == nil){
                                           // if an error occur, just return nil. this album won't have its coverPhoto set
                                           return nil;
                                       }
                                       
                                       return [result objectForKey:@"photo"];
                                   }];
            
            // ... then the sizes (i.d. the images) of the photo
            [subQueueForCoverPhotosData addQueryWithMethod:@"flickr.photos.getSizes" 
                                          andParams:params 
                                            andName:[NSString stringWithFormat:@"flickr.photos.getSizes_%@", albumId]
                                   andHandlingBlock:^id(GRKFlickrQueriesQueue *queue, id result, NSError *error) {
                                       
                                       if ( error != nil || [result objectForKey:@"sizes"] == nil ){
                                        // if an error occur, just return nil. this album won't have its coverPhoto set
                                           return nil;
                                       }
                                       
                                       return [result objectForKey:@"sizes"];
                                   }];
            
              
              // If we use the coverPhotoId in the name of the queries, 
              // it'll be impossible to know which result is needed to build a GRKPhoto for an album.
              // The trick is to use the albumId in the names of the queries, for the loop in the handling block below.

            
        }
        
        
        [self registerQueryAsLoading:subQueueForCoverPhotosData];
        
        // at this point, the queriesQueue is ready to be run
        [subQueueForCoverPhotosData performWithFinalBlock:^(id query, id results) {
           
            // at this point, result is a dictionary with keys like "flickr.photo.method_photoId" and with data as values.
            // let's handle these data to build GRKPhoto and set albums' coverPhoto
            
            NSMutableArray * updatedAlbums = [NSMutableArray array];
            
            for( GRKAlbum * album in albums ){
             
                NSString * getInfosKey = [NSString stringWithFormat:@"flickr.photos.getInfo_%@", album.albumId];
                NSString * getSizesKey = [NSString stringWithFormat:@"flickr.photos.getSizes_%@", album.albumId];
                
                if ( [results objectForKey:getInfosKey] != nil && [results objectForKey:getSizesKey] != nil){

                    album.coverPhoto = [self photoWithRawDataFromPhotosGetInfos:[results objectForKey:getInfosKey] 
                                                   andRawDataFromPhotosGetSizes:[results objectForKey:getSizesKey]];
                    [updatedAlbums addObject:album];
                }
                
            }
            
            if ( completeBlock != nil ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(updatedAlbums);
                });
            }
            
            [self unregisterQueryAsLoading:subQueueForCoverPhotosData];
            subQueueForCoverPhotosData = nil;

            
        }];
        
        [self unregisterQueryAsLoading:queueForCoverPhotoIds];
        queueForCoverPhotoIds = nil;
        
        
    }];
    
}


-(void) fillCoverPhotoOfAlbum:(GRKAlbum *)album andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock {
    
    [self fillCoverPhotoOfAlbums:[NSArray arrayWithObject:album] 
                withCompleteBlock:completeBlock 
                   andErrorBlock:errorBlock];
        
}




/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) cancelAll {
    
    [flickrConnector cancelAll];

    
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
 @return a GRKAlbum
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
 
 @param rawPhoto a NSDictionary representing the photo to build, as returned by FlickR's API method "flickr.photosets.getPhotos"
 @return a GRKPhoto
 */
-(GRKPhoto *) photoWithRawPhotoFromPhotosetsGetPhotos:(NSDictionary*)rawPhoto;
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
 @return a GRKImage
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



/** Build and return a GRKPhoto from the given dictionaries.
 
 @param rawDataPhotosGetInfos a NSDictionary containing general infos to build the photo, as returned by FlickR's API method "flickr.photos.getInfos"
 @param rawDataPhotosGetSizes a NSDictionary containing data about the photo's images, as returned by FlickR's API method "flickr.photos.getSizes"
 @return a GRKPhoto 
 */
-(GRKPhoto *) photoWithRawDataFromPhotosGetInfos:(NSDictionary*)rawDataPhotosGetInfos andRawDataFromPhotosGetSizes:(NSDictionary*)rawDataPhotosGetSizes {
    
    // First, handle the data for "getInfos"
    NSString * photoId = [rawDataPhotosGetInfos objectForKey:@"id"];
    NSString * photoName = [[rawDataPhotosGetInfos objectForKey:@"title"] objectForKey:@"_text"];
    
    NSString * caption = @"";
    if  ( [[rawDataPhotosGetInfos objectForKey:@"description"] isKindOfClass:[NSDictionary class]] )
        caption = [[rawDataPhotosGetInfos objectForKey:@"description"] objectForKey:@"_text"];
    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    
    if ( [rawDataPhotosGetInfos objectForKey:@"dates"] != nil ){

        NSDictionary * rawDates = [rawDataPhotosGetInfos objectForKey:@"dates"];
    
        // raw dates stored as timestamps in the FlickR's result. 
        NSTimeInterval dateCreatedTimestamp = [[rawDates objectForKey:@"posted"] doubleValue];
        NSTimeInterval dateUpdatedTimestamp = [[rawDates objectForKey:@"lastupdate"] doubleValue];                                  
        // The "date Taken" value is stored as formated date string like : "2011-12-17 18:31:40"
        NSString * dateTakenDatetimeString = [rawDates objectForKey:@"taken"];
        
        NSDate * dateCreated = [NSDate dateWithTimeIntervalSince1970:dateCreatedTimestamp];
        NSDate * dateUpdated = [NSDate dateWithTimeIntervalSince1970:dateUpdatedTimestamp]; 
        NSDate * dateTaken = [dateTakenDatetimeString dateWithFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        if (dateCreated != nil) [dates setObject:dateCreated forKey:kGRKPhotoDatePropertyDateCreated];
        if (dateUpdated != nil) [dates setObject:dateUpdated forKey:kGRKPhotoDatePropertyDateUpdated];
        if (dateTaken != nil) [dates setObject:dateTaken forKey:kGRKPhotoDatePropertyDateTaken];
        

    }

    // Then, handle the data for the images
    
    NSMutableArray * images = [NSMutableArray array];
    NSUInteger numberOfImages = [[rawDataPhotosGetSizes objectForKey:@"size"] count];
    
    [[rawDataPhotosGetSizes objectForKey:@"size"] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id rawImageDictionary, NSUInteger idx, BOOL *stop) {
    
        if( rawImageDictionary != nil && [rawImageDictionary isKindOfClass:[NSDictionary class]] ){    

            NSString * URLstring = [rawImageDictionary objectForKey:@"source"];
            NSUInteger width = [[rawImageDictionary objectForKey:@"width"] intValue];
            NSUInteger height = [[rawImageDictionary objectForKey:@"height"] intValue];
            
            // The last returned image is the original, or at least the biggest one
            BOOL isOrignal = (idx == numberOfImages - 1);
        
            GRKImage * newImage = [GRKImage imageWithURLString:URLstring andWidth:width andHeight:height isOriginal:isOrignal];
            [images addObject:newImage];
        
        }
        
    }];
    
    
    GRKPhoto * result = [GRKPhoto photoWithId:photoId andCaption:caption andName:photoName andImages:images andDates:dates];
    return result;
    
}



@end
