/*
 * This file is part of the GrabKit package.
 * Copyright (c) 2013 Pierre-Olivier Simonard <pierre.olivier.simonard@gmail.com>
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


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/* GRKPickerThumbnailManagerCompleteBlock is a block performed once a thumbnail has been downloaded or retrieved from the cache.
 */
typedef void (^GRKPickerThumbnailManagerCompleteBlock)(UIImage * thumbnail, BOOL retrievedFromCache);

typedef void (^GRKPickerThumbnailManagerErrorBlock)(NSError * error);


/** GRKPickerThumbnailManager is the class responsible for managing a queue of thumbnails to download, and caching them.
 
 The GRKPickerThumbnailManager singleton is available via the method +[GRKPickerThumbnailManager sharedInstance].
 
 For each given thumbnail, if it has not been cached yet, GRKPickerThumbnailManager :
        _ downloads the thumbnail
        _ resize it to the given size
        _ stores the image's data in cache for the given URL and the given size
        _ call the given completeBlock
 
 If it has been cached for the given size, GRKPickerThumbnailManager retrieves the data and call the completeBlock.

 Specific case :
    the URLs of photos from the Device starts with "assets-library://". For these URLs, there is no download needed. The image is retrieved from the ALAssetsLibrary instead.
 
 
*/
@interface GRKPickerThumbnailManager : NSObject <NSCacheDelegate> {
    
    
    NSMutableArray * thumbnailsQueue;
    NSMutableArray * connections;
    
    #if DEBUG_CACHE
    int cacheCount;
    int cacheCostCount;
    #endif
}

/** Returns the singleton 

 @return a singleton GRKPickerThumbnailManager
 */
+(GRKPickerThumbnailManager*)sharedInstance;

/** Returns the cached UIImage for the given URL and Size, or nil if there is no cache matching.
 
 @param thumbnailURL URL of the requested thumbnail
 @param thumbnailSize Size of the requested thumbnail
 @return an UIImage if found in cache, or nil
 */
-(UIImage*)cachedThumbnailForURL:(NSURL*)thumbnailURL andSize:(CGSize)thumbnailSize;

/** Download the data at the given url, or retrieves it from cache if it has been previously cached.
 Once the data is available, it is stored in the cache for the given size, and the completeBlock is performed.
 
 @param thumbnailURL URL of the thumbnail to download
 @param thumbnailSize dimension of the thumbnail to resize to, and to store in cache.
 @param completeBlock block to perform with the thumbnail's data
 @param errorBlock error block

 */
-(void) downloadThumbnailAtURL:(NSURL*)thumbnailURL
          forThumbnailSize:(CGSize)thumbnailSize
         withCompleteBlock:(GRKPickerThumbnailManagerCompleteBlock)completeBlock
             andErrorBlock:(GRKPickerThumbnailManagerErrorBlock)errorBlock;


/** Empties the downloads queue
*/
-(void) removeAllURLsOfThumbnailsToDownload;

/** Stops all the current download
 */
-(void) cancelAllConnections;


@end
