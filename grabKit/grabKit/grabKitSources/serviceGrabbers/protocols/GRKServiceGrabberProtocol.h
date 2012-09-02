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

#import <Foundation/Foundation.h>
#import "GRKAlbum.h"

// do NOT change these constants
#define kGRKMaximumNumberOfAlbumsPerPage 500
#define kGRKMaximumNumberOfPhotosPerPage 500

// Block passed to a grabber and performed after a successful operation.
typedef void (^GRKServiceGrabberCompleteBlock)(id result);

// Block passed to a query and performed when it successes
typedef void (^GRKQueryResultBlock)(id query, id result);

// Block passed to a query performed in a queue or in a batch. 
//  This block is performed by the subquery and must return an object.
//  The results of all subqueries (i.e. each result returned by the GRKSubqueryResultBlock of each subquery)
//  are returned to the caller (typically a grabber)
typedef id (^GRKSubqueryResultBlock)(id queueOrBatchObject, id resultOrNil, NSError * errorOrNil);


// Generic error block. 
typedef void (^GRKErrorBlock)(NSError * error);

/**
 The GRKServiceGrabberProtocol protocol is adopted by an object that is responsible for :
 
 - retrieving data about albums and photos from the service 
 - build GRKAlbum, GRKPhoto and GRKImage objects
 - Fill GRKAlbum objects with their GRKPhoto
 - return them to the caller using blocks
 
 An object implementing this protocol is named "Grabber". 
 
 The naming conventions for a grabber for a specific service is :
 ***GRK + ServiceName + Grabber***
 
 examples : GRKFacebookGrabber, GRKFlickrGrabber, ...
 

 */
@protocol GRKServiceGrabberProtocol

@required

/** @name Getting GRKAlbum objects */

/**
 Asks the grabber to retrieve "numberOfAlbumsPerPage" albums from page "pageIndex". page index starts at ***zero***.
 
 Some services restrict the amount of albums you can retrieve in one call. (for example : Flickr limits to 500 albums per page).
 This is why this method limits numberOfAlbumsPerPage to 500; asking for a higher value will throw an error.
 Furthermore, it's recommended to ask for small amounts of data on mobile devices.

 
 As most of the grabbing operations are asynchronous, the grabber must keep a reference to each loading query, in order to stop them in the methods [GRKServiceGrabberProtocol cancelAll] and [GRKServiceGrabberProtocol cancelAllWithCompleteBlock:];
 
 If the grabber successes on retrieving the result, it must build an array of GRKAlbum objects from the raw data, and call the completeBlock with this array. (refer to the already existing grabbers).
  
 if an error occurs, the grabber must call the errorBlock with a NSError object containing the following informations :
 
 - a domain following the structure : com.grabKit.***grabberType***.***albums*** ( e.g. "com.grabKit.GRKFacebookGrabber.albums", ...)
 - as error code, use the same error code than the original error thrown by the service's sdk/library.
 - in the userInfo dictionary, add :
        - the original error thrown by the service's sdk/library with the key "originalError", if applicable
        - a drescription of the error

 @param pageIndex index of the page to start retrieving albums from. page index starts at ***zero***.
 @param numberOfAlbumsPerPage number of albums per page
 @param completeBlock a GRKServiceGrabberCompleteBlock  performed once the albums are retrieved.  
 @param errorBlock a GRKErrorBlock  performed if an error occured 
 
 
 
 @warning It's strongly recommended to call the completeBlock and errorBlock asynchronously on the main queue, like :
 
    dispatch_async(dispatch_get_main_queue(), ^{
        completeBlock(albumsResult);
    });

    // ...
 
    dispatch_async(dispatch_get_main_queue(), ^{
        errorBlock(error);
    });
 
 */
-(void) albumsOfCurrentUserAtPageIndex:(NSUInteger)pageIndex
              withNumberOfAlbumsPerPage:(NSUInteger)numberOfAlbumsPerPage
                       andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                          andErrorBlock:(GRKErrorBlock)errorBlock;



/** @name Filling a GRKAlbum with GRKPhoto objects */

/** Asks the grabber to retrieve "numberOfPhotosPerPage" photos from page "pageIndex", build an array of GRKPhoto from the raw result, fill the given album with these GRKPhoto, and call the completeBlock with the array.
 
 Each GRKPhoto must be built with their GRKImage objects. If the service doesn't offer the possibility to build GRKPhoto and GRKImages in one call, the grabber must perform as many calls as necessary.
 
 Some services restrict the amount of photos you can retrieve in one call. (for example : Flickr limits to 500 photos per page)
 In that case, the grabber must performs as many calls as needed to return the expected number of photos.
 
 As most of the grabbing operations are asynchronous, the grabber must keep a reference to each loading query, in order to stop them in the methods [GRKServiceGrabberProtocol cancelAll] and [GRKServiceGrabberProtocol cancelAllWithCompleteBlock:];
 
 If the grabber successes on retrieving the result, it must :

 - build an array of GRKPhoto objects from the raw data
 - fill the given GRKAlbum with them, using [GRKalbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:]
 - call the completeBlock with this array. (refer to the already existing grabbers).
 
 
 if an error occurs, the grabber must call the errorBlock with a NSError object containing the following informations :
 
 - a domain following the structure : com.grabKit.***grabberType***.***fillAlbum*** ( e.g. "com.grabKit.GRKFacebookGrabber.fillAlbum", ...)
 - as error code, use the same error code than the original error thrown by the service's sdk/library.
 - in the userInfo dictionary, add :
    - the original error thrown by the service's sdk/library with the key "originalError"
    - the given album object with the key "originalAlbum"
 
 
 
 @param album GRKAlbum object to fill
 @param pageIndex rank of the page to start retrieving photos from. starts at zero.
 @param numberOfPhotosPerPage number of albums per page
 @param completeBlock a GRKServiceGrabberCompleteBlock  performed once the albums are retrieved.  
 @param errorBlock a GRKErrorBlock  performed if an error occured 
 */
-(void) fillAlbum:(GRKAlbum *)album
   withPhotosAtPageIndex:(NSUInteger)pageIndex
withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage
         andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
            andErrorBlock:(GRKErrorBlock)errorBlock;



/** @name Setting the cover of a GRKAlbum */

/** Asks the grabber to retrieve the cover of a GRKAlbum. The cover of an album is an instance of GRKPhoto.
 The cover can be a specific photo or the first photo of the album, according to the service.

 @param album GRKAlbum object to fill the cover of
 @param completeBlock a GRKServiceGrabberCompleteBlock  performed once the cover is retrieved. the GRKPhoto result is given to that block
 @param errorBlock a GRKErrorBlock  performed if an error occured 
 */
-(void) fillCoverPhotoOfAlbum:(GRKAlbum *)album
            andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
               andErrorBlock:(GRKErrorBlock)errorBlock;

/** Asks the grabber to retrieve the cover of several GRKAlbum. 
 
 The cover of an album is an instance of GRKPhoto.
 The cover can be a specific photo or the first photo of the album, according to the service.

 The goal of this method is to be implemented using batch methods of the service. 
 If the service doesn't offer a proper batch method, this method must then implement a queue to perform the calls.
 
 @param albums NSArray array of GRKAlbum to fill the cover of
 @param completeBlock a GRKServiceGrabberCompleteBlock  performed once the covers are retrieved. 
        A NSArray containing the updated GRKAlbum objects are given to that block.
 @param errorBlock a GRKErrorBlock  performed if an error occured 
 */
-(void) fillCoverPhotoOfAlbums:(NSArray *)albums 
              withCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                 andErrorBlock:(GRKErrorBlock)errorBlock;

/**
 Asks the grabber to retrieve the cover for the given GRKAlbum. 
 Basically, this method must call [self fillCoverPhotoOfAlbums:withCompleteBlock:andErrorBlock], giving a NSArray containing the given album as first parameter
 
 @param album GRKAlbum album to fill the cover of
 @param completeBlock a GRKServiceGrabberCompleteBlock  performed once the cover is retrieved. the GRKPhoto result is given to that block
 @param errorBlock a GRKErrorBlock  performed if an error occured  
*/
-(void) fillCoverPhotoOfAlbum:(GRKAlbum *)album 
             andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                andErrorBlock:(GRKErrorBlock)errorBlock;


/** @name Manage the loading queries */


/** Ask the grabber to cancel all the queries still loading.
 */
-(void) cancelAll;


/** Ask the grabber to cancel all the queries still loading, and then to execute the block
 
@param completeBlock a GRKServiceGrabberCompleteBlock to perform once all the queries are canceled. The GRKServiceGrabberCompleteBlock takes one parameter, the grabber must call this block with a nil parameter
 */
-(void) cancelAllWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock;




@end
