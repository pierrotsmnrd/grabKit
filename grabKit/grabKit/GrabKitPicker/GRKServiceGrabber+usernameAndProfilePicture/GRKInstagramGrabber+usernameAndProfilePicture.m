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
#import "GRKInstagramGrabber+usernameAndProfilePicture.h"
#import "GRKInstagramQuery.h"
#import "GRKConstants.h"

@implementation GRKInstagramGrabber (usernameAndProfilePicture)



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
    
    if ( [(NSDictionary *)result objectForKey:@"data"] == nil ){
        return NO;
    }
    
    // Do we have enough data to build the profile picture's url ?
    if (   [[(NSDictionary *)result objectForKey:@"data"] objectForKey:@"profile_picture"] == nil ){
        return NO;
    }
    
    // Do we have enough data to show the user's name ?
    
    BOOL fullnameIsValid = ( [[(NSDictionary *)result objectForKey:@"data"] objectForKey:@"full_name"] != nil
                            && ! [[[result objectForKey:@"data"] objectForKey:@"full_name"] isEqualToString:@""] );
    
    BOOL usernameIsValid = ( [[(NSDictionary *)result objectForKey:@"data"] objectForKey:@"username"] != nil
                            && ! [[[result objectForKey:@"data"] objectForKey:@"username"] isEqualToString:@""] );
    
    
    
    if ( ! ( fullnameIsValid || usernameIsValid ) ){
        return NO;
    }
    
    
    return YES;
}


#pragma mark usernameAndProfilePicture category methods



-(void)loadUsernameAndProfilePictureOfCurrentUserWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{


        __block GRKInstagramQuery * userDataQuery = nil;

        NSString * endpoint = @"users/self";

        //#warning for dev only
        //endpoint = @"users/980434";

        userDataQuery = [GRKInstagramQuery queryWithEndpoint:endpoint
                                                withParams:nil
                                         withHandlingBlock:^(GRKInstagramQuery * query, id result){
                                             
                                             // Is the result in the expected format ? 
                                             if ( ! [self isResultForUsernameAndProfilePictureInTheExpectedFormat:result] ){

                                                 dispatch_async_on_main_queue(errorBlock, [self errorForBadFormatResultForUsernameAndProfilePictureOperation] );
                                                 
                                                 return;
                                             }

                                             
                                             
                                             NSString * username = @"";
                                             if ( ! [[[result objectForKey:@"data"] objectForKey:@"full_name"] isEqualToString:@""] ){
                                                 username = [[result objectForKey:@"data"] objectForKey:@"full_name"];
                                                 
                                             } else if ( ! [[[result objectForKey:@"data"] objectForKey:@"username"] isEqualToString:@""] ){
                                                 username = [[result objectForKey:@"data"] objectForKey:@"username"];
                                             }
                                             
                                             NSString * profilePictureURLString = [[result objectForKey:@"data"] objectForKey:@"profile_picture"];
                                             
                                             NSDictionary * blockResult = [NSDictionary dictionaryWithObjectsAndKeys:username, kGRKUsernameKey,
                                                                           profilePictureURLString, kGRKProfilePictureKey,
                                                                           nil];
                                       
                                             
                                             dispatch_async_on_main_queue(completeBlock, blockResult);

                                             [self unregisterQueryAsLoading:userDataQuery];
                                             userDataQuery = nil;
                                             
                                         }andErrorBlock:^(NSError * error){
                                            
                                             dispatch_async_on_main_queue(errorBlock, error);
                                             
                                             [self unregisterQueryAsLoading:userDataQuery];
                                             userDataQuery = nil;
                                             
                                         }];
        [self registerQueryAsLoading:userDataQuery];
        [userDataQuery perform];

}

@end
