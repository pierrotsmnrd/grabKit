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

#import "GRKServiceGrabber.h"
#import "GRKServiceGrabberProtocol.h"
#import "GRKErrorsConstants.h"

@implementation GRKServiceGrabber

@synthesize serviceName = _serviceName;



-(id) initWithServiceName:(NSString *)serviceName {
    
    if ((self = [super init]) != nil){
        
        _serviceName = [serviceName copy];
        
        _queries = [[NSMutableArray alloc] init];
        
    }     
    
    return self;
}


-(void) registerQueryAsLoading:(id)query {
    
    if ( query != nil ){
        [_queries addObject:query];
    }
    
}

-(void) unregisterQueryAsLoading:(id)query {
    [_queries removeObject:query];
}
    

-(NSError *) errorWithOriginalError:(NSError *)originalError forOperation:(NSString *)operation{
    
    NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.%@", _serviceName, operation];
    NSDictionary * userInfo = nil;
    if ( originalError != nil ) {
        [NSDictionary dictionaryWithObjectsAndKeys:originalError, kGRKErrorOriginalErrorKey,
                                nil];
    }
    NSError * error = [NSError errorWithDomain:errorDomain code:kGRKBadFormatResultErrorCode userInfo:userInfo];
    
    return error;
  
}



-(NSError *)errorForAlbumsOperationWithOriginalError:(NSError *)originalError {
    return [self errorWithOriginalError:originalError forOperation:@"albums"];
}

-(NSError *)errorForBadFormatResultForAlbumsOperation {
    
    NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.albums", _serviceName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:kGRKBadFormatResultErrorLocalizedDescription forKey:NSLocalizedDescriptionKey];
    NSError * error = [NSError errorWithDomain:errorDomain code:kGRKBadFormatResultErrorCode userInfo:userInfo];
    
    return error;
    
}

-(NSError *)errorForBadFormatResultForAlbumsOperationWithOriginalError:(NSError *) originalError {
    
    if ( originalError == nil ) {
        return [self errorForBadFormatResultForAlbumsOperation];
    }
    
    NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.albums", _serviceName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:kGRKBadFormatResultErrorLocalizedDescription, NSLocalizedDescriptionKey,
                                                                        originalError, kGRKErrorOriginalErrorKey,
                               nil];
    NSError * error = [NSError errorWithDomain:errorDomain code:kGRKBadFormatResultErrorCode userInfo:userInfo];
    
    return error;
    
}



-(NSError *)errorForFillAlbumOperationWithOriginalError:(NSError *)originalError {
    return [self errorWithOriginalError:originalError forOperation:@"fillAlbum"];
}

-(NSError *)errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:(GRKAlbum*)originalAlbum {
    
    NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.fillAlbum", _serviceName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:kGRKBadFormatResultErrorLocalizedDescription, NSLocalizedDescriptionKey,
                                                                        originalAlbum, kGRKErrorOriginalAlbumKey,
                               nil];
    
    NSError * error = [NSError errorWithDomain:errorDomain code:kGRKBadFormatResultErrorCode userInfo:userInfo];
    
    return error;
    
}


-(NSError *)errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:(GRKAlbum*)originalAlbum andOriginalError:(NSError *) originalError {
    
    if ( originalError == nil ) {
        return [self errorForBadFormatResultForFillAlbumOperationWithOriginalAlbum:originalAlbum];
    }
    
    NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.fillAlbum", _serviceName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:kGRKBadFormatResultErrorLocalizedDescription, NSLocalizedDescriptionKey,
                                                                            originalError, kGRKErrorOriginalErrorKey,
                               nil];
    NSError * error = [NSError errorWithDomain:errorDomain code:kGRKBadFormatResultErrorCode userInfo:userInfo];
    
    return error;
    
}

#pragma mark - GRKServiceGrabberProtocol methods. 

/* /!\ ALL the following methods MUST be overriden by the subclassing objects */


/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) albumsOfCurrentUserAtPageIndex:(NSUInteger)pageIndex
             withNumberOfAlbumsPerPage:(NSUInteger)numberOfAlbumsPerPage
                      andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                         andErrorBlock:(GRKErrorBlock)errorBlock {
    
    NSAssert(false, @" the object %@ doesn't mask the method [%@ albumsOfCurrentUserAtPageIndex:withNumberOfAlbumsPerPage:andCompleteBlock:andErrorBlock:]", self, [self class]);
    
}

/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) fillAlbum:(GRKAlbum *)album
withPhotosAtPageIndex:(NSUInteger)pageIndex
withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage
 andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
    andErrorBlock:(GRKErrorBlock)errorBlock {

    NSAssert(false, @" the object %@ doesn't mask the method [%@ fillAlbum:withPhotosAtPageIndex:withNumberOfPhotosPerPage:andCompleteBlock:andErrorBlock:]", self, [self class]);
}


/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) fillCoverPhotoOfAlbums:(NSArray *)albums 
             withCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                andErrorBlock:(GRKErrorBlock)errorBlock {
    
    NSAssert(false, @" the object %@ doesn't mask the method [%@ fillCoverPhotoOfAlbums:withCompleteBlock:andErrorBlock:]", self, [self class]);
    
}


/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) fillCoverPhotoOfAlbum:(GRKAlbum *)album 
             andCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock 
                andErrorBlock:(GRKErrorBlock)errorBlock {
    
    NSAssert(false, @" the object %@ doesn't mask the method [%@ fillCoverPhotoOfAlbum:andCompleteBlock:andErrorBlock:]", self, [self class]);
    
}





/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) cancelAll {

    NSAssert(false, @" the object %@ doesn't mask the method [%@ cancelAll]", self, [self class]);
    
}


/** As GRKServiceGrabber is the parentClass of all grabbers, this method must be subclassed.
 * Refer to GRKServiceGrabberProtocol documentation.
 */
-(void) cancelAllWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock {

    NSAssert(false, @" the object %@ doesn't mask the method [%@ cancelAllWithCompleteBlock:]", self, [self class]);
}


@end
