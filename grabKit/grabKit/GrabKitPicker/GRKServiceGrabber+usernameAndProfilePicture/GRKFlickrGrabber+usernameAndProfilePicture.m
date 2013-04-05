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
#import "GRKFlickrGrabber+usernameAndProfilePicture.h"
#import "GRKFlickrQuery.h"
#import "GRKFlickrSingleton.h"
#import "GRKConstants.h"

@implementation GRKFlickrGrabber (usernameAndProfilePicture)


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
    
    if ( [(NSDictionary *)result objectForKey:@"person"] == nil ){
        return NO;
    }
    
    // Do we have enough data to build the profile picture's url ? 
    if (   [[(NSDictionary *)result objectForKey:@"person"] objectForKey:@"iconfarm"] == nil
    ||     [[(NSDictionary *)result objectForKey:@"person"] objectForKey:@"iconserver"] == nil ){
        return NO;
    }

    // Do we have enough data to show the user's name ?
    id username = [[[(NSDictionary *)result objectForKey:@"person"] objectForKey:@"username"] objectForKey:@"_text"];
    BOOL usernameIsValid = ( username != nil &&  ! [username isEqualToString:@""] );

    id realname =  [[[(NSDictionary *)result objectForKey:@"person"] objectForKey:@"realname"] objectForKey:@"_text"];
    BOOL realnameIsValid = ( realname != nil && ! [realname isEqualToString:@""] );
    

    if (  ! ( usernameIsValid || realnameIsValid ) ){
        return NO;
    }

    
    return YES;
}


#pragma mark usernameAndProfilePicture category methods



-(void)loadUsernameAndProfilePictureOfCurrentUserWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    NSString * userId = [GRKFlickrSingleton sharedInstance].userID;
    
    // #warning for dev only
    //userId = @"35591378@N03";
    
    //#warning for demo only
    //userId = @"86078191@N00";
    
    if ( userId == nil ){
        
        NSString * errorDomain = [NSString stringWithFormat:@"com.grabKit.%@.usernameAndProfilePicture", _serviceName];
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"invalid User ID", NSLocalizedDescriptionKey,
                                   nil];
        NSError * error = [NSError errorWithDomain:errorDomain code:0 userInfo:userInfo];
        
        dispatch_async_on_main_queue(errorBlock, error);

        return;
    }
    
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:userId, @"user_id", nil];
    
    __block GRKFlickrQuery * userDataQuery = nil;
    
    userDataQuery = [GRKFlickrQuery queryWithMethod:@"flickr.people.getInfo"
                                           andParams:params
                                   withHandlingBlock:^(GRKFlickrQuery * query, id result){
                                       
                                       // Is the result in the expected format ?
                                       if ( ! [self isResultForUsernameAndProfilePictureInTheExpectedFormat:result] ){
                                           
                                           dispatch_async_on_main_queue(errorBlock, [self errorForBadFormatResultForUsernameAndProfilePictureOperation]);
                                           
                                           return;
                                       }
                                       
                                       
                                       // build the string representing the url of the profile picture
                                       NSString * iconfarm = [[result objectForKey:@"person"] objectForKey:@"iconfarm"];
                                       NSString * iconserver = [[result objectForKey:@"person"] objectForKey:@"iconserver"];
                                       
                                       NSString * profilePictureURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg", iconfarm, iconserver, userId];

                                       // according to http://www.flickr.com/services/api/misc.buddyicons.html
                                       // if the icon server is 0, then the user has a default profile picture
                                       if ( [iconserver isEqualToString:@"0"]) {
                                           profilePictureURLString = @"http://www.flickr.com/images/buddyicon.gif";
                                           
                                       }
                                       
                                        
                                       NSString * username = @"";
                                       if ( [[[result objectForKey:@"person"] objectForKey:@"realname"] objectForKey:@"_text"] != nil ){
                                           username = [[[result objectForKey:@"person"] objectForKey:@"realname"] objectForKey:@"_text"] ;
                                           
                                       } else if ( [[[result objectForKey:@"person"] objectForKey:@"username"] objectForKey:@"_text"]!= nil ){
                                           username = [[[result objectForKey:@"person"] objectForKey:@"username"] objectForKey:@"_text"] ;
                                       }
                                       
                                       
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
