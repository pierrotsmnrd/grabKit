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


#import "GRKPicasaSingleton.h"
#import "GDataFeedPhotoUser.h"
#import "GDataServiceGooglePhotos.h"
#import "GRKServiceGrabber+usernameAndProfilePicture.h"
#import "GRKPicasaGrabber+usernameAndProfilePicture.h"
#import "GRKPicasaQuery.h"
#import "GRKConstants.h"

@implementation GRKPicasaGrabber (usernameAndProfilePicture)



#pragma mark - Internal processing methods

/** Check if the given result for the user's data is in the expected format.
 @param result the data to check.
 @return  a boolean value. if YES, the data is in the expected format.
 
 */
-(BOOL) isResultForUsernameAndProfilePictureInTheExpectedFormat:(id)result;
{
    
    // check if the result has the expected format
    if ( ! [result isKindOfClass:[GDataFeedPhotoUser class]] ){
		return NO;
    }
    
    if ( [(GDataFeedPhotoUser *)result nickname] == nil
        || [[(GDataFeedPhotoUser *)result nickname] isEqualToString:@""] ){
        return NO;
    }

    if ( [(GDataFeedPhotoUser *)result thumbnail] == nil
        || [[(GDataFeedPhotoUser *)result thumbnail] isEqualToString:@""] ){
        return NO;
    }
    
    
    return YES;
}


#pragma mark usernameAndProfilePicture category methods



-(void)loadUsernameAndProfilePictureOfCurrentUserWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
 
    NSString * userId = [GRKPicasaSingleton sharedInstance].userEmailAdress;
    
    if ( userId == nil || [userId isEqualToString:@""]) {
        
        NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.usernameAndProfilePicture", _serviceName];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"invalid User ID", NSLocalizedDescriptionKey,
                                   nil];
        NSError * error = [NSError errorWithDomain:errorDomain code:0 userInfo:userInfo];
        
        dispatch_async_on_main_queue(errorBlock, error);

        return;
    }
    
    
    NSURL *albumsBaseFeedURL = [GDataServiceGooglePhotos photoContactsFeedURLForUserID:userId];
    
    __block GRKPicasaQuery * albumsQuery = nil;
    
    albumsQuery = [GRKPicasaQuery queryWithFeedURL:albumsBaseFeedURL
                                         andParams:[NSMutableDictionary dictionary]
                                 withHandlingBlock:^(GRKPicasaQuery *query, id result) {
                                     
                                     // Is the result in the expected format ?
                                     if ( ! [self isResultForUsernameAndProfilePictureInTheExpectedFormat:result] ){
                                         
                                         dispatch_async_on_main_queue(errorBlock, [self errorForBadFormatResultForUsernameAndProfilePictureOperation]);
                                         
                                         return;
                                     }

                                     
                                     if ( completeBlock != nil ){
                                         
                                         NSString * username = [(GDataFeedPhotoUser *)result nickname];
                                         
                                         NSString * profilePictureURLString = [(GDataFeedPhotoUser *)result thumbnail];
                                         
                                         NSDictionary * blockResult = [NSDictionary dictionaryWithObjectsAndKeys:username, kGRKUsernameKey,
                                                                       profilePictureURLString, kGRKProfilePictureKey,
                                                                       nil];
                                         
                                         dispatch_async_on_main_queue(completeBlock, blockResult);
                                         
                                     }
                                     
                                     [self unregisterQueryAsLoading:albumsQuery];
                                     albumsQuery = nil;
                                     
                                 } andErrorBlock:^(NSError *error) {
                                     
                                     dispatch_async_on_main_queue(errorBlock, error);

                                     [self unregisterQueryAsLoading:albumsQuery];
                                     albumsQuery = nil;
                                     
                                 }];
    [self registerQueryAsLoading:albumsQuery];
    [albumsQuery perform];
    
}



@end
