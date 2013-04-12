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


#import "GRKServiceGrabber+usernameAndProfilePicture.h"
#import "GRKFacebookGrabber+usernameAndProfilePicture.h"
#import "GRKFacebookQuery.h"
#import "GRKConstants.h"
#import <FacebookSDK/FBError.h>

@implementation GRKFacebookGrabber (usernameAndProfilePicture)


#pragma mark - Internal processing methods

/** Check if the given result for the user's data is in the expected format.
 @param result the data to check.
 @return  a boolean value. if YES, the data is in the expected format.
 
 */
-(BOOL) isResultForUsernameAndProfilePictureInTheExpectedFormat:(id)result;
{
    
    // check if the result has the expected format
    if ( ! [result isKindOfClass:[NSDictionary class]] ){
		return NO;
    }
    
    if ( [(NSDictionary *)result objectForKey:@"name"] == nil ){
        return NO;
    }

    if ( [(NSDictionary *)result objectForKey:@"picture"] == nil ){
        return NO;
    }

    return YES;
}


#pragma mark usernameAndProfilePicture category methods



-(void)loadUsernameAndProfilePictureOfCurrentUserWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    __weak __block GRKFacebookQuery * userDataQuery = nil;
    userDataQuery = [GRKFacebookQuery queryWithGraphPath:@"me?fields=picture.width(88).height(88),name" // we need a large picture, for retina displays...
                                      withParams:nil
                               withHandlingBlock:^(GRKFacebookQuery *query, id result) {

                                   // Is the result in the expected format ?
                                   if ( ! [self isResultForUsernameAndProfilePictureInTheExpectedFormat:result] ){
                                       
                                       dispatch_async_on_main_queue(errorBlock,[self errorForBadFormatResultForUsernameAndProfilePictureOperation] );
                                       
                                       return;
                                   }
                                   
                                   if ( completeBlock != nil ){

                                       NSString * username = [result objectForKey:@"name"];
                                       NSString * profilePictureURLString = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                                       

                                       NSDictionary * blockResult = [NSDictionary dictionaryWithObjectsAndKeys:username, kGRKUsernameKey,
                                                                    profilePictureURLString, kGRKProfilePictureKey,
                                                                 nil];
                                   
                                       dispatch_async_on_main_queue(completeBlock, blockResult);
                                       
                                   }
                                   
                                   [self unregisterQueryAsLoading:userDataQuery];
                                   userDataQuery = nil;
                                   
                               } andErrorBlock:^(NSError *error) {
                                   
                                   // Before assuming the session is invalid, let's filter some network-related errors
                                   
                                   if ( errorBlock != nil ){
                                       
                                       // First, retrieve the original error
                                       NSDictionary *  userInfo = [error userInfo];
                                       NSError * originalError = [userInfo objectForKey:FBErrorInnerErrorKey];
                                       
                                       if ( originalError != nil ){
                                           
                                           // "The Internet connection appears to be offline."
                                           if ( originalError.code == kCFURLErrorNotConnectedToInternet ){
                                               
                                               dispatch_async_on_main_queue(errorBlock, originalError);
                                               return;
                                           }
                                           
                                       } else {
                                           
                                           dispatch_async_on_main_queue(errorBlock, error);
                                           
                                       }
                                       
                                   }
                                   
                                   [self unregisterQueryAsLoading:userDataQuery];
                                   userDataQuery = nil;
                                   
                               }];
    
    [self registerQueryAsLoading:userDataQuery];
    [userDataQuery perform];
    
}

@end
