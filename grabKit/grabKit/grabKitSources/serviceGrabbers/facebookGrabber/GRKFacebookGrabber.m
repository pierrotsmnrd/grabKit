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
#import "GRKFacebookBatchQuery.h"
#import "GRKFacebookQuery.h"
#import "GRKAlbum.h"
#import "ISO8601DateFormatter.h"
#import "GRKConstants.h"


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
    
/* 
 Internal implementation details : 
 Problem : 
        We want to give access to the tagged photos of the user. 
        This must be done by making specific calls to Facebook's Graph API.
 
        We can't consider a "tagged photos" album as last album, because we don't know by advance how many albums the user has.
        We could assume that when we ask for N albums and we receive less than N, then we reached the last albums, so we could make
            an extra call for the tagged photos. But it forces us to make an extra call. 

 Solution : Let's consider the first album as the "tagged photos" album.
            When asking for the first page of N albums, ask for "N-1 albums" and "tagged photos", in one call of batch queries.
    
        This implies to shift the parameter "offset" built in every requests.
 */
    
    
    // asking for the first page of albums ? 
    if ( pageIndex == 0 ){
        
        // then we know we'll ask for one less album
        numberOfAlbumsPerPage -= 1 ;
        
        //Create a batchQuery to ask for : 
        // _ the tagged photos (with a FQL query)
        // _ the photo albums (with a graph path query)
       __block GRKFacebookBatchQuery * batchQuery = [[GRKFacebookBatchQuery alloc] init];
        
        
        //  First query of the batch : the tagged photos
        NSString * graphPathFQL = @"fql";
        NSMutableDictionary *paramsFQL = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"SELECT '' FROM photo_tag WHERE subject=me()", @"q",
                                          nil];
        
        [batchQuery addQueryWithGraphPath:graphPathFQL 
                               withParams:paramsFQL 
                                  andName:@"taggedPhotos" 
                         andHandlingBlock:^id(GRKFacebookBatchQuery *query, id result, NSError *error) {
            
            // Build the GRKAlbum of the tagged photos from the result, and return it. Or return the error if needed.
            
            if ( error ) {
                return error;
            }
            
            if ( [result objectForKey:@"data"] == nil ) {

                NSError * error = [self errorForBadFormatResultForAlbumsOperation];
                return error;
            }
            

            GRKAlbum * taggedPhotosAlbum = [[GRKAlbum alloc] initWithId:@"me" // do NOT change this value 
                                                                andName:[GRKCONFIG facebookTaggedPhotosAlbumName]
                                                               andCount:[[result objectForKey:@"data"] count] 
                                                               andDates:nil];
            
            return taggedPhotosAlbum;
            
        } ];
        
        
        // Second query of the batch : the albums
        NSString * graphPath = @"me/albums";
        NSMutableDictionary * params = [NSMutableDictionary  dictionaryWithObjectsAndKeys:@"id,name,count,updated_time,created_time,location", @"fields", nil];
        
        NSNumber * offset = [NSNumber numberWithInt:(pageIndex * numberOfAlbumsPerPage )]; 
        // minus one : refer to the implementation details above
        
        [params setObject:[offset stringValue] forKey:@"offset"];	
        [params setObject:[NSString stringWithFormat:@"%d", numberOfAlbumsPerPage] forKey:@"limit"];
        
        [batchQuery addQueryWithGraphPath:graphPath withParams:params andName:@"albums"  andHandlingBlock:^id(GRKFacebookBatchQuery *query, id result, NSError *error) {
            
            // Build the array of GRKAlbum from the result, and return it. Or return the error if needed.
            
            if ( error ) {
                return error;
            }
            
            if ( ! [self isResultForAlbumsInTheExpectedFormat:result] ){

                // Create an error for "bad format result" and call the errorBlock
                NSError * badFormatError = [self errorForBadFormatResultForAlbumsOperation];
                
                return badFormatError;
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
         
            
            return albums;
            
        }];
        
        
        [self registerQueryAsLoading:batchQuery];
        [batchQuery performWithFinalBlock:^(GRKFacebookBatchQuery * batchQuery, id results) {

            // if the result is not in the expected format ...
            if ( [results objectForKey:@"taggedPhotos"] == nil 
                || [results objectForKey:@"albums"] == nil
            || [[results objectForKey:@"taggedPhotos"] isKindOfClass:[NSError class]] 
            || [[results objectForKey:@"albums"] isKindOfClass:[NSError class]]     
                ){
                if ( errorBlock != nil ) {
                    // Create an error for "bad format result" and call the errorBlock
                    NSError * error = [self errorForBadFormatResultForAlbumsOperation];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorBlock(error);
                    });
                }
                [self unregisterQueryAsLoading:batchQuery];
                batchQuery = nil;
                
                return;
            }
                
            // else, reorganize results and call the completion block
            NSMutableArray * albums = [NSMutableArray array];
            [albums addObject:[results objectForKey:@"taggedPhotos"]];
            [albums addObjectsFromArray:[results objectForKey:@"albums"]];
             
            if ( completeBlock != nil ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(albums);
                });
            }
            
            [self unregisterQueryAsLoading:batchQuery];
            batchQuery = nil;
            return;

            
        }];

        
    // asking for page above 1 ? 
    } else {
            
        
        NSMutableDictionary * params = [NSMutableDictionary  dictionaryWithObjectsAndKeys:@"id,name,count,updated_time,created_time,location", @"fields", nil];
        
        NSNumber * offset = [NSNumber numberWithInt:(pageIndex * numberOfAlbumsPerPage ) -1 ]; 
                    // minus one : refer to the implementation details above
            
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
    [params setObject:@"id,name,created_time,updated_time,images,height,width" forKey:@"fields"];    

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


-(void) fillCoverPhotoOfAlbums:(NSArray *)albums 
             withCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                andErrorBlock:(GRKErrorBlock)errorBlock {
    
    
    
    __block GRKFacebookBatchQuery * batchQuery = [[GRKFacebookBatchQuery alloc] init];

    //for each album
    for( GRKAlbum * album in albums ){
    
        // 1) build a subquery to retrieve album's cover photo id
        
        NSString * graphPathCoverPhotoId = album.albumId;
        
        NSString* queryNameCoverPhotoId = [NSString stringWithFormat:@"coverPhotoId_%@", album.albumId];
        
        NSMutableDictionary *paramsCoverPhotoId = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"cover_photo", @"fields",
                                          nil];
        
        [batchQuery addQueryWithGraphPath:graphPathCoverPhotoId 
                               withParams:paramsCoverPhotoId 
                                  andName:queryNameCoverPhotoId 
                         andHandlingBlock:^id(GRKFacebookBatchQuery *query, id result, NSError *error) {
                          
                             /*
                             if ( error != nil ){
                                 NSLog(@" error for album id %@", album.albumId);
                             } */
                             
                             return nil;
                         }]; // no need to store the result for this query
        
        
        // 2) build a second subquery, using result from the first one, to get cover photo's data

            // Specifying dependencies between queries in a batch request, thank you Facebook for implementing JSONPath :)
        NSString * graphPathCoverPhotoData = [NSString stringWithFormat:@"{result=%@:$.cover_photo}", queryNameCoverPhotoId]; 
        
        NSMutableDictionary * paramsCoverPhotoData = [NSMutableDictionary  dictionaryWithObjectsAndKeys:@"id,name,created_time,updated_time,images,height,width", @"fields", nil];    

        [batchQuery addQueryWithGraphPath:graphPathCoverPhotoData 
                               withParams:paramsCoverPhotoData 
                                  andName:[NSString stringWithFormat:@"coverPhotoData_%@", graphPathCoverPhotoId]  
                         andHandlingBlock:^id(GRKFacebookBatchQuery *query, id result, NSError *error) {

        
                             if (error !=nil ) {
                               
                                 //NSLog(@" error for cover data album %@", album.albumId);
                                 // don't return error. it just failed, the album won't have its cover updated
                                 return nil;
                             } else if ( result != nil ){
                                    
                                 GRKPhoto * coverPhoto = [self photoWithRawPhoto:result];
                                 [album setCoverPhoto:coverPhoto];
                                 
                             }
                             
                             return album;
            
                         }];
    }
    
    [self registerQueryAsLoading:batchQuery];
    [batchQuery performWithFinalBlock:^(GRKFacebookQuery *query, id results) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock([results allObjects]);    
        });

        [self unregisterQueryAsLoading:batchQuery];
        batchQuery = nil;
        
        
    }];
    
    return;
    
    
}


/* @see refer to GRKServiceGrabberProtocol documentation
 */
-(void) fillCoverPhotoOfAlbum:(GRKAlbum *)album 
             andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                andErrorBlock:(GRKErrorBlock)errorBlock {
    
    [self fillCoverPhotoOfAlbums:[NSArray arrayWithObject:album] 
                withCompleteBlock:completeBlock 
                   andErrorBlock:errorBlock];
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
 @return a GRKAlbum
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
 @return a GRKPhoto
 */
-(GRKPhoto *) photoWithRawPhoto:(NSDictionary*)rawPhoto;
{
    NSString * photoId = [rawPhoto objectForKey:@"id"];

	// on Facebook, the "name" value of a photo is its caption
    NSString * photoCaption = [rawPhoto objectForKey:@"name"]  ;
    
    NSMutableDictionary * dates = [NSMutableDictionary dictionary];
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    
    if ( [rawPhoto objectForKey:@"created_time"] != nil){
    
        // raw dates stored as strings in the FB result. 
        // they are ISO 8601 dates, looking like : 2010-09-08T21:11:25+0000
        NSString * dateCreatedDatetimeISO8601String = [rawPhoto objectForKey:@"created_time"];
        
        // convert the string dates to NSDate
        NSDate * dateCreated = [formatter dateFromString:dateCreatedDatetimeISO8601String];
    
        if (dateCreated != nil)
            [dates setObject:dateCreated forKey:kGRKPhotoDatePropertyDateCreated];
    }
    
    if ( [rawPhoto objectForKey:@"updated_time"] != nil ){
        
        NSString * dateUpdatedDatetimeISO8601String = [rawPhoto objectForKey:@"updated_time"];
        NSDate * dateUpdated = [formatter dateFromString:dateUpdatedDatetimeISO8601String];
        
        if (dateUpdated != nil) 
            [dates setObject:dateUpdated forKey:kGRKPhotoDatePropertyDateUpdated];
    }
    
    
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
 @return a GRKImage
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
