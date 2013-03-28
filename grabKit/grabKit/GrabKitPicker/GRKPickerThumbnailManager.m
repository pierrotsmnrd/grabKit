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


#import "GRKPickerThumbnailManager.h"
#import "GRKPickerViewController+privateMethods.h"
#import "AsyncURLConnection.h"
#import "UIImage+thumbnail.h"
#import "GRKPickerViewController.h"
#import "GRKPickerViewController+privateMethods.h"
#import <AssetsLibrary/AssetsLibrary.h>

#if DEBUG
    #define DEBUG_CACHE 0 //1
#else
    #define DEBUG_CACHE 0
#endif



// keys used in dictionaries used for queueing
NSString * thumbnailURLKey = @"thumbnailURL";
NSString * thumbnailSizeKey = @"thumbnailSize";
NSString * completeBlockKey = @"completeBlock";
NSString * errorBlockKey = @"errorBlock";

// A global NSCache instance, used to store the downloaded thumbnails
NSCache * sharedThumbnailCache = nil;

// Singleton of the current class
GRKPickerThumbnailManager * sharedGRKPickerThumbnailManager = nil;

NSUInteger maxNumberOfThumbnailsToDownloadSimultaneously = 5;

@interface GRKPickerThumbnailManager()
    -(void) downloadNextThumbnail;
    -(void) cancelAllConnections;
@end

@implementation GRKPickerThumbnailManager

+(GRKPickerThumbnailManager*)sharedInstance; {
    
    if ( sharedGRKPickerThumbnailManager == nil ){
        
        sharedGRKPickerThumbnailManager = [[GRKPickerThumbnailManager alloc] init];
    }
    
    return sharedGRKPickerThumbnailManager;
}


-(id) init {
    
    self = [super init];
    if ( self != nil ){
        
        #if DEBUG_CACHE
        cacheCount = 0;
        cacheCostCount = 0;
        #endif
        
        thumbnailsQueue = [[NSMutableArray alloc] init] ;
        connections =  [[NSMutableArray alloc] init];
    }
    
    return self;
}


+(NSCache *) cache {
    
    if ( sharedThumbnailCache == nil ){
        sharedThumbnailCache = [[NSCache alloc] init];
       // sharedThumbnailCache.countLimit = 100;
        sharedThumbnailCache.totalCostLimit = 1024 * 1024 * 2; // 2 MB cache size
        
        sharedThumbnailCache.delegate = [GRKPickerThumbnailManager sharedInstance];
    }
    
    return sharedThumbnailCache;
}



-(void) cacheThumbnail:(UIImage*)thumbnailImage forURL:(NSURL*)thumbnailURL andSize:(CGSize)size{
    
    NSData * thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0);
    
    int thumbnailCost = [thumbnailData length];
    
    [[GRKPickerThumbnailManager cache] setObject:thumbnailData // thumbnailImage
                                             forKey:[self cacheKeyForURL:thumbnailURL andSize:size]
                                               cost:thumbnailCost];
    
    
    #if DEBUG_CACHE
    cacheCount++;
    cacheCostCount += thumbnailCost;
    NSLog(@" cache count : %d, cost : %d", cacheCount, cacheCostCount );
    #endif
    
}

-(NSString *)cacheKeyForURL:(NSURL*)url andSize:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%fx%f", [url absoluteString], size.width, size.height];
}


-(UIImage*)cachedThumbnailForURL:(NSURL*)thumbnailURL andSize:(CGSize)thumbnailSize {
    
    UIImage * cachedThumbnail = nil;
    
    NSData * cachedThumbnailData = [[GRKPickerThumbnailManager cache] objectForKey:[self cacheKeyForURL:thumbnailURL andSize:thumbnailSize]];
    if ( cachedThumbnailData != nil ){
    
        cachedThumbnail = [UIImage imageWithData:cachedThumbnailData];
        
    }
    
    return cachedThumbnail;
    
    
}


-(void) downloadThumbnailAtURL:(NSURL*)thumbnailURL forThumbnailSize:(CGSize)thumbnailSize withCompleteBlock:(GRKPickerThumbnailManagerCompleteBlock)completeBlock andErrorBlock:(GRKPickerThumbnailManagerErrorBlock)errorBlock {
    
    
    if ( thumbnailURL == nil ) {
        return;
    }
    
    
    UIImage * cachedThumbnail = [self cachedThumbnailForURL:thumbnailURL andSize:thumbnailSize];
    
    // If the thumbnail has already been cached
    if ( cachedThumbnail != nil ){
        
        if ( completeBlock != nil ){
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                    completeBlock(cachedThumbnail, YES);
                
            });
        
        }
        
        return;
    }
    

    // Special case for the assets images
    if ( [[thumbnailURL absoluteString] hasPrefix:@"assets-library://"] ){
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:thumbnailURL resultBlock:^(ALAsset *asset) {
            
            // You can also load a "fullResolutionImage", but it's heavy ...
            //CGImageRef imgRef = [asset aspectRatioThumbnail];
            CGImageRef imgRef = [asset thumbnail];
            UIImage * thumbnailImage = [UIImage imageWithCGImage:imgRef];
            
            [self cacheThumbnail:thumbnailImage forURL:thumbnailURL andSize:thumbnailSize];
            
            if ( completeBlock != nil ){
                
                completeBlock( thumbnailImage, NO );
                
            }
            
        } failureBlock:^(NSError *error) {
            
            if ( errorBlock != nil ){
                errorBlock(error);
            }
            
        }];
        
        return;
    }
        
    
    
    // else, store all the needed data, and add it to the queue
    NSMutableDictionary * nextThumbnail = [NSMutableDictionary dictionaryWithObjectsAndKeys:thumbnailURL, thumbnailURLKey,
                                                      [NSValue valueWithCGSize:thumbnailSize], thumbnailSizeKey, nil];
    
    if ( completeBlock != nil )
        [nextThumbnail setObject:completeBlock forKey:completeBlockKey];
    
    if ( errorBlock != nil )
        [nextThumbnail setObject:errorBlock forKey:errorBlockKey];
    
    
    
    [thumbnailsQueue addObject:nextThumbnail];
    
    [self downloadNextThumbnail];
    
}


-(void) downloadNextThumbnail {
    
    // Don't download too many thumbnails at the same time
    if ( [connections count] >= maxNumberOfThumbnailsToDownloadSimultaneously ) return;
    
    
    // if there is no images to download anymore, stop
    if ( [thumbnailsQueue count] == 0 ) {
        return;   
    }
    
    
    //retrieve the data of the next thumbnail to download
    
    NSDictionary * nextThumbnailToDownload = [thumbnailsQueue objectAtIndex:0];
    
    NSURL * nextThumbnailURL = [nextThumbnailToDownload objectForKey:thumbnailURLKey];
    
    NSValue * thumbnailSizeValue = [nextThumbnailToDownload objectForKey:thumbnailSizeKey];
    GRKPickerThumbnailManagerCompleteBlock completeBlock = [nextThumbnailToDownload objectForKey:completeBlockKey];
    GRKPickerThumbnailManagerErrorBlock errorBlock = [nextThumbnailToDownload objectForKey:errorBlockKey];
    
    __block AsyncURLConnection * connection = nil;
    
    if ( thumbnailSizeValue != nil && completeBlock != nil ){
        
    connection = [AsyncURLConnection connectionWithString:[nextThumbnailURL absoluteString]
                                             responseBlock:nil
                                             progressBlock:nil 
                                             completeBlock:^(NSData *data) {
                                               
                                               DECREASE_OPERATIONS_COUNT
                                                 
                                               CGSize thumbnailSize = [thumbnailSizeValue CGSizeValue];
                                                 
                                               UIImage * thumbnail = [[UIImage imageWithData:data] thumbnailImageWithSize:thumbnailSize];

                                                 // store the thumbnail in the cache
                                                 [self cacheThumbnail:thumbnail forURL:nextThumbnailURL andSize:thumbnailSize];
                                                 
                                                 if (completeBlock != nil ){
                                                     completeBlock( thumbnail, NO);
                                                 }

                                              
                                              [connections removeObject:connection];
                                              [self downloadNextThumbnail];
                                              connection = nil;
                                              
                                          } errorBlock:^(NSError *error) {
                                              
                                              DECREASE_OPERATIONS_COUNT
                                              
                                              NSLog(@" error while downloading content at url %@ :\n %@", nextThumbnailURL, error);
                                              
                                              // oops !
                                              if ( errorBlock != nil ){
                                                  errorBlock(error);
                                              }
                                              
                                              
                                              [connections removeObject:connection];
                                              [self downloadNextThumbnail];
                                              
                                              connection = nil;
                                          }];
    
        
        // remove the data after the creation of the request,
        // to let the block retain the var nextThumbnailURL, completeBlock, etc
        // Otherwise, these vars are released, and it makes the app crash.
        [thumbnailsQueue removeObjectAtIndex:0];
        
        
        [connections addObject:connection];
        INCREASE_OPERATIONS_COUNT
        [connection start];

        
    }

        
}

-(void) cancelAllConnections {
    
    
    for ( AsyncURLConnection * connection in connections ){
        [connection cancel];
        DECREASE_OPERATIONS_COUNT
    }
    
    [connections removeAllObjects];
}

-(void) removeAllURLsOfThumbnailsToDownload {

    [thumbnailsQueue removeAllObjects];
}


#if DEBUG_CACHE

#pragma mark NSCacheDelegate methods 

-(void) cache:(NSCache *)cache willEvictObject:(id)obj {
    
    NSLog(@" will evict obj with length : %d", [(NSData*)obj length] );
    
    cacheCount--;
    cacheCostCount -= [(NSData*)obj length];
    
    NSLog(@" cache count : %d, cost : %d", cacheCount, cacheCostCount );
    
}

#endif

@end
