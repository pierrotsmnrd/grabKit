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


#import "GRKConstants.h"
#import "GRKFacebookConnector.h"
#import "GRKFacebookQuery.h"

#import "GRKConnectorsDispatcher.h"
#import "GRKServiceGrabber.h"

#import "GRKFacebookSingleton.h"
#import "GRKTokenStore.h"

#import <FacebookSDK/FBSession.h>
#import <FacebookSDK/FBError.h>


static NSString * accessTokenKey = @"AccessTokenKey";
static NSString * expirationDateKey = @"ExpirationDateKey";


@implementation GRKFacebookConnector

-(id) initWithGrabberType:(NSString *)type;
{
    
    if ((self = [super initWithGrabberType:type]) != nil){
        
        connectionIsCompleteBlock = nil;
        connectionDidFailBlock = nil;
        
        _isConnecting = NO;
        
    }     
    
    return self;
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    FBSession * session = [GRKFacebookSingleton sharedInstance].facebookSession;
    
    connectionIsCompleteBlock = completeBlock;
    connectionDidFailBlock = errorBlock;
    
    // The Facebook SDK keeps internal values allowing to test, at any moment, if the session is valid or not.   
    if ( ! session.isOpen ) {
        
        
            [[GRKConnectorsDispatcher sharedInstance] registerServiceConnectorAsConnecting:self];
            _applicationDidEnterBackground = NO;
        
            [FBSession setDefaultAppID:[GRKCONFIG facebookAppId]];
            NSArray *permissions = [NSArray arrayWithObjects:@"user_photos", @"user_photo_video_tags", nil];
        
        
            // The "_isConnecting" flag is usefull to use the FBSession object in a different purpose than it was built for.
            //   The completionHandler below is executed each times the session changes, at any time.
            //   We only want to open the session once, we don't want to be notified all the time. this is what this flag is made for.
            _isConnecting = YES;
        
            // Maybe I'll change my mind later to have the benefit of completionHandler called at each state-change of the session. We'll see :)

            /* Here is the test scenario that helped me fixing a bug.
               Initial conditions :
                    _ First, comment the test on _isConnecting, below
                    _ The user has not yet added the FB application to his account, or he has removed it.
                    _ The user must have more albums on facebook than kNumberOfAlbumsPerPage (defined in GRKPickerAlbumsList.m)
             
                Steps :
                    _ Start the demo App, show the GRKPickerViewController, select Facebook
                    _ The app should tell you to login. do so.
                    _ Once the list of albums appeared, go to facebook, and revoke access to the FB App 
                    _ In the app, scroll down and click on the "load more" button : 
                         ==> BUG : the session is invalidated : the completion handler is called
             
                Fix : Add the _isConnecting flag
             
             */

        
        BOOL openSession =
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES 
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          
                                          if ( _isConnecting ) {
                                          
                                              _isConnecting = NO;
                                          
                                              // Unregister the connector here too.
                                              // In iOS 6, the app can be authorized without leaving the app, so we need to unregister the connector too.
                                              [[GRKConnectorsDispatcher sharedInstance] unregisterServiceConnectorAsConnecting:self];
                                              
                                              if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                                  
                                                  [GRKFacebookSingleton sharedInstance].facebookSession = session;
                                                  
                                                  
                                                  // The session seems to be open ? great. But call this method recursively, to make a test call to graphPath /me, to be sure the session is still valid.
                                                  [self connectWithConnectionIsCompleteBlock:completeBlock andErrorBlock:errorBlock];
                                                  
                                                  
                                                  //dispatch_async_on_main_queue(completeBlock, YES);

                                                  
                                              } else if (error) {
                                               
                                                  
                                                  // If the error that occured is that the user refused to log in
                                                  id loginFailedReason = [[error userInfo] objectForKey:FBErrorLoginFailedReason];
                                                  if ( [loginFailedReason isEqualToString:FBErrorLoginFailedReasonUserCancelledValue]
                                                  || [loginFailedReason isEqualToString:FBErrorLoginFailedReasonUserCancelledSystemValue]
                                                      ){
                                                      
                                                      if ( completeBlock != nil ){
                                                            completeBlock(NO);
                                                      }
                                                      
                                                      return;
                                                  }
                                                  
                                                  // else, if a real error occured
                                                  
                                                  [[FBSession activeSession] closeAndClearTokenInformation];

                                                  [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
                                                  [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];
                                                  
                                                  
                                                  
                                                  errorBlock(error);
                                               
                                                  
                                              }
                                              
                                              
                                          }
                                      }];
      
        
        NSLog(@" open session : %d", openSession);
        
    } else  {
        
        // session is supposed to be valid. let's test a simple query to check that, for example, the user removed the application on his settings on Facebook.
    
        GRKFacebookQuery * query = nil;
        query = [GRKFacebookQuery queryWithGraphPath:@"me" 
                                         withParams:nil 
                                  withHandlingBlock:^(GRKFacebookQuery *query, id result) {
        
                                      // Store the locale
                                      [GRKFacebookSingleton sharedInstance].userLocale = [result objectForKey:@"locale"];
                                      
                                      if (completeBlock != nil ){
    	                                  completeBlock(YES);
	                                  }
                                      
                                      [_queries removeObject:query];
                                      
                                  } andErrorBlock:^(NSError *error) {
                                      
                                     	// if we got an error trying to make a basic query, 
                                    	//  but as the session is supposed to be valid, 
                                      	// Then the user may have removed the application on Facebook.
                                  		
                                      // then, remove the store data about the session
                                      [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
                                      [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];

                                      errorBlock(error);
                                      
                                      [_queries removeObject:query];
                                  
                                  }];

        [_queries addObject:query];
        [query perform];

            
        
    }
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
   
    [[GRKFacebookSingleton sharedInstance].facebookSession closeAndClearTokenInformation];
    
    [self isConnected:^(BOOL connected) {
        if ( completeBlock != nil ){
            completeBlock(connected);
        }
    } errorBlock:^(NSError * error){
        if ( errorBlock != nil ){
            errorBlock(error);
        }
    }];
}

-(void) cancelAll {
    
    for ( GRKFacebookQuery * query in _queries ){
        [query cancel];
    }
    
    [_queries removeAllObjects];
    
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock errorBlock:(GRKErrorBlock)errorBlock;
{
    
    FBSession * session = [GRKFacebookSingleton sharedInstance].facebookSession;
    BOOL connected = (session.state == FBSessionStateCreatedTokenLoaded)
    || (session.state == FBSessionStateOpen)
    || (session.state == FBSessionStateOpenTokenExtended);
    
    
    if ( ! connected ){
    
        dispatch_async_on_main_queue(connectedBlock, connected);
        
        return;
    }
    
    // let's test the connection. The user may have revoked the access to the application from his facebook account,
    // or may have changed his password, thus invalidating the session.
    
    
    __weak __block GRKFacebookQuery * query = nil;
    query = [GRKFacebookQuery queryWithGraphPath:@"me?fields=locale" // let's ask for a restricted set of data ...
                                      withParams:nil
                               withHandlingBlock:^(GRKFacebookQuery *query, id result) {

                                   // Store the locale
                                   [GRKFacebookSingleton sharedInstance].userLocale = [result objectForKey:@"locale"];
                                   
                                   if (connectedBlock != nil ){
                                       connectedBlock(YES);
                                   }
                                   
                                   [_queries removeObject:query];
                                   query = nil;
                                   
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
                                               
                                               [_queries removeObject:query];
                                               query = nil;

                                               return;
                                           }
                                           
                                       }
                                       
                                   }
                                   
                                   // if we got an error trying to make a basic query,
                                   //  but as the session is supposed to be valid,
                                   // Then the user may have removed the application on Facebook.
                                   
                                   // then, remove the store data about the session
                                   [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
                                   [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];
                                   

                                   if (connectedBlock != nil ){
                                       connectedBlock(NO);
                                   }
                                   
                                   [_queries removeObject:query];
                                   query = nil;
                                   
                               }];
    
    [_queries addObject:query];
    [query perform];

    
}

-(void) applicationDidEnterBackground {
    
    _applicationDidEnterBackground = YES;
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) didNotCompleteConnection;{
   
    /*
        this method is called when the app becomes active.
        this code below needs to be performed only if the app entered background first.
        The app can "become active" without entering background first in one peculiar case :
            When de FB sdk attempts to log in from ACAccountStore, an UIAlertView is displayed 
            to ask the user if he allows to give access to his FB account.
            Whether the users allows or refuses, the [UIApplicationDelegate applicationDidBecomeActive] 
            method is called when the UIAlertView dissmisses.
     
    */

    if ( _applicationDidEnterBackground ){
    
        if (connectionIsCompleteBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                connectionIsCompleteBlock(NO);
                connectionIsCompleteBlock = nil;
            });
        
        }
    }
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(BOOL) canHandleURL:(NSURL*)url;
{
    
    return ( [[url scheme] isEqualToString:[NSString stringWithFormat:@"fb%@",[GRKCONFIG facebookAppId]]] ) ;
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) handleOpenURL:(NSURL*)url; 
{

    [FBSession.activeSession handleOpenURL:url];
    
}


@end
