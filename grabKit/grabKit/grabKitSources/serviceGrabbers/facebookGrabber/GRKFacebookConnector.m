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

#import "GRKConstants.h"
#import "GRKFacebookConnector.h"
#import "GRKFacebookQuery.h"

#import "GRKConnectorsDispatcher.h"
#import "GRKServiceGrabber.h"

#import "GRKFacebookSingleton.h"
#import "GRKTokenStore.h"

#import <FacebookSDK/FBSession.h>

static NSString * accessTokenKey = @"AccessTokenKey";
static NSString * expirationDateKey = @"ExpirationDateKey";

@implementation GRKFacebookConnector

-(id) initWithGrabberType:(NSString *)type;
{
    
    if ((self = [super initWithGrabberType:type]) != nil){
        
        connectionIsCompleteBlock = nil;
        connectionDidFailBlock = nil;
        
    }     
    
    return self;
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    FBSession * session = [GRKFacebookSingleton sharedInstance].facebookSession;
    
    // The Facebook SDK keeps internal values allowing to test, at any moment, if the session is valid or not.   
    if ( ! session.isOpen ) {
        
        
        [[GRKConnectorsDispatcher sharedInstance] registerServiceConnectorAsConnecting:self];
            
        
            connectionIsCompleteBlock = completeBlock;
        
            [FBSession setDefaultAppID:[GRKCONFIG facebookAppId]];
            NSArray *permissions = [NSArray arrayWithObjects:@"user_photos", @"user_photo_video_tags", nil];
        
            [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES 
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                              
                                              [GRKFacebookSingleton sharedInstance].facebookSession = session;
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                    connectionIsCompleteBlock(YES);
                                                    connectionIsCompleteBlock = nil;
                                              });
                                              
                                              
                                          }else if (error) {
                                              
                                              errorBlock(error);
                                              
                                          }
                                      }];
      
        
    } else  {
        
        // session is supposed to be valid. let's test a simple query to check that, for example, the user removed the application on his settings on Facebook.
    
        GRKFacebookQuery * query = nil;
        query = [GRKFacebookQuery queryWithGraphPath:@"me" 
                                         withParams:nil 
                                  withHandlingBlock:^(GRKFacebookQuery *query, id result) {
        
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

                                      // and retry to connect
                                      [self connectWithConnectionIsCompleteBlock:completeBlock andErrorBlock:errorBlock];
                                      [_queries removeObject:query];
                                  
                                  }];

        [_queries addObject:query];
        [query perform];

            
        
    }
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)completeBlock;
{
   
    [[GRKFacebookSingleton sharedInstance].facebookSession closeAndClearTokenInformation];
    
    [self isConnected:^(BOOL connected) {
        completeBlock(connected);
    }];
//    disconnectionIsCompleteBlock( ! [GRKFacebookSingleton sharedInstance].facebookSession.isOpen  );
    
}

-(void) cancelAll {
    
    for ( GRKFacebookQuery * query in _queries ){
        [query cancel];
    }
    
    [_queries removeAllObjects];
    
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{
    
    FBSession * session = [GRKFacebookSingleton sharedInstance].facebookSession;
    BOOL connected = (session.state == FBSessionStateCreatedTokenLoaded)
    || (session.state == FBSessionStateOpen)
    || (session.state == FBSessionStateOpenTokenExtended);
    
    
    if ( ! connected ){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            connectedBlock( connected );
        });
        
        return;
    }
    
    // let's test the connection. The user may have revoked the access to the application from his facebook account,
    // or may have changed his password, thus invalidating the session
    
    GRKFacebookQuery * query = nil;
    query = [GRKFacebookQuery queryWithGraphPath:@"me?fields=timezone" // let's ask for a tiny bit of data ...
                                      withParams:nil
                               withHandlingBlock:^(GRKFacebookQuery *query, id result) {
                                   
                                   if (connectedBlock != nil ){
                                       connectedBlock(YES);
                                   }
                                   
                                   [_queries removeObject:query];
                                   
                               } andErrorBlock:^(NSError *error) {
                                   
                                   // if we got an error trying to make a basic query,
                                   //  but as the session is supposed to be valid,
                                   // Then the user may have removed the application on Facebook.
                                   
                                   // then, remove the store data about the session
                                   [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
                                   [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];
                                   
                                   // and retry to connect
                                   if (connectedBlock != nil ){
                                       connectedBlock(NO);
                                   }
                                   [_queries removeObject:query];
                                   
                               }];
    
    [_queries addObject:query];
    [query perform];

    
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) didNotCompleteConnection;{
   
    if ( connectionIsCompleteBlock != nil ){
        dispatch_async(dispatch_get_main_queue(), ^{
            connectionIsCompleteBlock(NO);
            connectionIsCompleteBlock = nil;
        });
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
