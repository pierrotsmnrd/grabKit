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
#import "GRKServiceGrabberProtocol.h"


/** GRKServiceGrabber is the parent class for all grabbers. 
 
GRKServiceGrabber conforms to GRKServiceGrabberProtocol, but all the methods must be masked by subclassing classes.
 

 GRKServiceGrabber offer methods usefull for subclassing grabbers, like methods to register/unregister queries as loading, or getting NSError objects.
 
 
*/
@interface GRKServiceGrabber : NSObject <GRKServiceGrabberProtocol> {
    
    NSString * _serviceName;
    
    
    NSMutableArray * _queries; // mutable array containing the queries loading
    
}

/** @name properties */

/** serviceName : name of the service implemented by the grabber */
@property (nonatomic, readonly) NSString * serviceName;

/** @name Initializing a GRKServiceGrabber */

/** Returns a GRKServiceGrabber object initialized with the given service name. 
 *
 * @param serviceName a string representing the service's name
 * @return an instance of GRKServiceGrabber
 */
-(id) initWithServiceName:(NSString *)serviceName;


/** @name  Managing queries */

/** Register a query as loading. 
 
 Many grabbers uses queries to load data. GRKServiceGrabber offers a standard way to store objects representing those loading queries.
 Once a query has finished loading, the GRKServiceGrabber must call unregisterQuery: .
 
 Grabber can also implement their own way to store queries, as long as calling the GRKServiceGrabberProtocol methods cancelAll and cancelAllWithCompleteBlock really cancel the queries.
 
 @param query The query object to register as loading
 */
-(void) registerQueryAsLoading:(id)query;

/** Unregister a query as loading. 
 
   @param query The query object to unregister as loading
 */
-(void) unregisterQueryAsLoading:(id)query;    


/** @name Generating errors */

/** Returns a NSError for an "albums" operation, with the current grabber's type in the domain, and the given error in the userInfo dictionary
 
 @param originalError the original error
 */
-(NSError *)errorForAlbumsOperationWithOriginalError:(NSError *)originalError;


/** Returns a "bad format result" error for an "albumsOfCurrentUserAtPageIndex..." operation.
 The error's domain is built with the grabber's type and the "albums" operation.
 The error's userInfo dictionary contains its localized description (with the key NSLocalizedDescriptionKey)
 */
-(NSError *)errorForBadFormatResultForAlbumsOperation;

/** Returns a "bad format result" error for an "albumsOfCurrentUserAtPageIndex..." operation.
 The error's domain is built with the grabber's type and the "albums" operation.
 The error's userInfo dictionary contains its localized description (with the key NSLocalizedDescriptionKey), and the original error (with the key kGRKErrorOriginalErrorKey)
 
  @param originalError the original error
 */
-(NSError *)errorForBadFormatResultForAlbumsOperationWithOriginalError:(NSError *)originalError;


/** Returns a NSError for a "fill album" operation, with the current grabber's type in the domain, and the given error in the userInfo dictionary
 
  @param originalError the original error
 */
-(NSError *)errorForFillAlbumOperationWithOriginalError:(NSError *)originalError;

/** Returns a "bad format result" error for a "fillAlbum..." operation.
 The error's domain is built with the grabber's type and the "albums" operation.
 The error's userInfo dictionary contains its localized description (with the key NSLocalizedDescriptionKey), and the original album (with the key kGRKErrorOriginalAlbumKey)
 
  @param originalAlbum the original album on which the error occured
 */
-(NSError *)errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:(GRKAlbum*)originalAlbum;


/** Returns a "bad format result" error for a "fillAlbum..." operation.
 The error's domain is built with the grabber's type and the "albums" operation.
 The error's userInfo dictionary contains its localized description (with the key NSLocalizedDescriptionKey), the original album (with the key kGRKErrorOriginalAlbumKey), and the original error (with the key kGRKErrorOriginalErrorKey)

 @param originalAlbum the original album on which the error occured
 @param originalError the original error 
 */
-(NSError *)errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:(GRKAlbum*)originalAlbum andOriginalError:(NSError *) originalError;

@end



