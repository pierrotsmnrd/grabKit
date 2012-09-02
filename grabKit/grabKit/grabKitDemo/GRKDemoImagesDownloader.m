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


#import "GRKDemoImagesDownloader.h"
#import "AsyncURLConnection.h"
#import <AssetsLibrary/AssetsLibrary.h>


// A global NSCache instance, used to store the downloaded images
NSCache * sharedDemoCache = nil;

// Singleton of the current class
GRKDemoImagesDownloader * sharedGRKDemoImagesDownloader = nil;

NSUInteger maxNumberOfImagesToDownloadSimultaneously = 5;

@interface GRKDemoImagesDownloader()
    -(void) downloadNextImage;
    -(void) cancelAllConnections;
@end

@implementation GRKDemoImagesDownloader

+(GRKDemoImagesDownloader*)sharedInstance; {
    
    if ( sharedGRKDemoImagesDownloader == nil ){
        
        sharedGRKDemoImagesDownloader = [[GRKDemoImagesDownloader alloc] init];
    }
    
    return sharedGRKDemoImagesDownloader;
}


-(id) init {
    
    self = [super init];
    if ( self != nil ){
        
       // numberOfImagesDownloading = 0;
        urlsOfImagesToDownload = [[NSMutableArray alloc] init] ;
        connections =  [[NSMutableArray alloc] init];
    }
    
    return self;
}


+(NSCache *) cache {
    
    if ( sharedDemoCache == nil ){
        sharedDemoCache = [[NSCache alloc] init];
        sharedDemoCache.countLimit = 100;
        sharedDemoCache.totalCostLimit = 1024*1024; // 1 MB cache size
    }
    
    return sharedDemoCache;
}


-(void) downloadImageAtURL:(NSURL*)imageURL forThumbnail:(GRKDemoThumbnail*)thumbnail {
    
    
    NSData * cachedData = [[GRKDemoImagesDownloader cache] objectForKey:imageURL];
    
    // If the image has already been cached
    if ( cachedData != nil ){
         
        [thumbnail updateThumbnailWithData:cachedData];
        return;
    }

    
    // Special case for the assets images
    if ( [[imageURL absoluteString] hasPrefix:@"assets-library://"] ){
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:imageURL resultBlock:^(ALAsset *asset) {
            
            // You can also load a "fullResolutionImage", but it's heavy ...
            CGImageRef imgRef = [asset aspectRatioThumbnail];
            
            UIImage * thumbnailImage = [UIImage imageWithCGImage:imgRef];

            
            int height = thumbnailImage.size.height;
            int width = thumbnailImage.size.width;
            int bytesPerRow = 4*width;
            if (bytesPerRow % 16)
                bytesPerRow = ((bytesPerRow / 16) + 1) * 16;
            int thumbnailCost = height*bytesPerRow;

            
            [[GRKDemoImagesDownloader cache] setObject:UIImagePNGRepresentation(thumbnailImage)
                                                forKey:imageURL
                                                  cost:thumbnailCost];
            
            [thumbnail updateThumbnailWithImage:thumbnailImage];
            
        } failureBlock:^(NSError *error) {
            
            [thumbnail setBackgroundColor:[UIColor redColor]];
            
        }];
        
        return;
    }
    
    
    
    
    
    // else, store it with its thumbnail and download the next image
    NSDictionary * nextImageURLAndThumbnail = [NSDictionary dictionaryWithObjectsAndKeys:imageURL, @"url",
                                            thumbnail, @"imageView", nil];
    
    [urlsOfImagesToDownload addObject:nextImageURLAndThumbnail];
    
    [self downloadNextImage];

}



-(void) downloadNextImage {
    
    // Don't download too many images at the same time
    //    if ( numberOfImagesDownloading >= maxNumberOfImagesToDownloadSimultaneously ) return;
    
    if ( [connections count] >= maxNumberOfImagesToDownloadSimultaneously ) return;
    
    
    // if there is no images to download anymore, stop
    if ( [urlsOfImagesToDownload count] == 0 ) {
        return;   
    }
    
    
    //retrieve the next URL and the imageView to fill
    
    NSURL * nextImageURL = [[urlsOfImagesToDownload objectAtIndex:0] objectForKey:@"url"];
    GRKDemoThumbnail * thumbnail = [[urlsOfImagesToDownload objectAtIndex:0] objectForKey:@"imageView"];

    
    __block AsyncURLConnection * connection = nil;
    
    connection = [AsyncURLConnection connectionWithString:[nextImageURL absoluteString] 
                                             responseBlock:nil
                                             progressBlock:nil 
                                             completeBlock:^(NSData *data) {
                                              
                                              // store the data in the cache
                                              [[GRKDemoImagesDownloader cache] setObject:data forKey:nextImageURL cost:[data length]];

                                                 
                                                [thumbnail updateThumbnailWithData:data];
                                              // update the image view

                                              
                                              //numberOfImagesDownloading--;
                                              [connections removeObject:connection];
                                              [self downloadNextImage];
                                              connection = nil;
                                              
                                          } errorBlock:^(NSError *error) {
                                              
                                              
                                              NSLog(@" error while downloading content at url %@ :\n %@", nextImageURL, error);
                                              
                                              // oops !
                                              [thumbnail setBackgroundColor:[UIColor redColor]];
                                              
                                             // numberOfImagesDownloading--;
                                              [connections removeObject:connection];                                              
                                              [self downloadNextImage];
                                              
                                              connection = nil;
                                          }];
    
    
    // remove the data after the creation of the request, 
    // to let the block retain the var nextImageURL and imageView.
    // Otherwise, these vars are released, and it makes the app crash...
    [urlsOfImagesToDownload removeObjectAtIndex:0];
    
   // numberOfImagesDownloading++;
    [connections addObject:connection];
    [connection start];
    
}

-(void) cancelAllConnections {
    
    
    for ( AsyncURLConnection * connection in connections ){
        [connection cancel];
    }
    
    [connections removeAllObjects];
}

-(void) removeAllURLsOfImagesToDownload {

    [urlsOfImagesToDownload removeAllObjects];
}

@end
