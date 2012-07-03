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


#import "GRKFacebookConnector.h"
#import "GRKFacebookConstants.h"
#import "GRKFacebookQuery.h"

#import "GRKConnectorsDispatcher.h"
#import "GRKServiceGrabber.h"

#import "GRKFacebookSingleton.h"
#import "GRKTokenStore.h"

static NSString * accessTokenKey = @"AccessTokenKey";
static NSString * expirationDateKey = @"ExpirationDateKey";

@implementation GRKFacebookConnector

- (void)dealloc {
    
    [connectionIsCompleteBlock release];
    [connectionDidFailBlock release];
    
    [super dealloc];
}

-(id) initWithGrabberType:(NSString *)type;
{
    
    if ((self = [super initWithGrabberType:type]) != nil){
        
        connectionIsCompleteBlock = nil;
        connectionDidFailBlock = nil;
        
    }     
    
    return self;
}

-(Facebook *) configuredFacebookObject;
{
    Facebook * facebook = [[GRKFacebookSingleton sharedInstance] facebook];
    [[GRKFacebookSingleton sharedInstance] setSessionDelegate:self];

    NSString * token = [GRKTokenStore tokenWithName:accessTokenKey forGrabberType:grabberType];
    NSDate * expirationDate = [GRKTokenStore tokenWithName:expirationDateKey forGrabberType:grabberType];
    
    if (token != nil && expirationDate != nil ) {
        facebook.accessToken = token;
        facebook.expirationDate = expirationDate;    
    }
    
    return facebook;
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
    Facebook * facebook = [self configuredFacebookObject];    

    // The Facebook SDK keeps internal values allowing to test, at any moment, if the session is valid or not.   
    if ( ! [facebook isSessionValid]) {
        
            connectionIsCompleteBlock = [completeBlock copy];
            connectionDidFailBlock = [errorBlock copy];
            
            [[GRKConnectorsDispatcher sharedInstance] registerServiceConnectorAsConnecting:self];
            
            NSArray *permissions = [NSArray arrayWithObjects:
                                    @"user_photos", 
                                    
                                    // To access the account without limit of time. usefull to avoid the login process once a day :)
                                    @"offline_access", 
                                    nil];
            [facebook authorize:permissions];

        
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
   
    disconnectionIsCompleteBlock = [completeBlock copy];
    
    Facebook * facebook = [self configuredFacebookObject];
    [facebook logout];
    
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
     Facebook * facebook = [self configuredFacebookObject];
    
    // The Facebook SDK keeps internal values allowing to test, at any moment, if the session is valid or not.
    if ( ! [facebook isSessionValid]) {
        connectedBlock(NO);
    } else connectedBlock(YES);
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(BOOL) canHandleURL:(NSURL*)url;
{
    
    return ( [[url scheme] isEqualToString:[NSString stringWithFormat:@"fb%@",kGRKFacebookAppId]] ) ;
    
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) handleOpenURL:(NSURL*)url; 
{
    [[[GRKFacebookSingleton sharedInstance] facebook] handleOpenURL:url];
    
}


#pragma mark FBSessionDelegate methods

// Called when the user successfully logged in.
- (void)fbDidLogin {
    
    
    NSString * accessToken = [[[GRKFacebookSingleton sharedInstance] facebook] accessToken];
    NSDate * expirationDate = [[[GRKFacebookSingleton sharedInstance] facebook] expirationDate];
    
    [GRKTokenStore storeToken:accessToken withName:accessTokenKey forGrabberType:grabberType];
    [GRKTokenStore storeToken:expirationDate withName:expirationDateKey forGrabberType:grabberType];
    
    
    if ( connectionIsCompleteBlock != nil ){
    	connectionIsCompleteBlock(YES);
    }
    
}

// Called when the user dismissed the dialog without logging in.
- (void)fbDidNotLogin:(BOOL)cancelled;
{
    if( connectionDidFailBlock != nil ){
        connectionDidFailBlock(nil);
    }
}

/*
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt;
{
    NSDate * expirationDate = [[[GRKFacebookSingleton sharedInstance] facebook] expirationDate];
    [GRKTokenStore storeToken:accessToken withName:accessTokenKey forGrabberType:grabberType];
    [GRKTokenStore storeToken:expirationDate withName:expirationDateKey forGrabberType:grabberType];
    
}

/*
 * Called when the user logged out.
 */
- (void)fbDidLogout;
{
    [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
    [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];
    
    if ( disconnectionIsCompleteBlock != nil ){
        disconnectionIsCompleteBlock(YES);
    }
    
}

/*
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated;
{
	[GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
    [GRKTokenStore removeTokenWithName:expirationDateKey forGrabberType:grabberType];

}


#pragma mark FBDialogDelegate methods


/*
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog;
{

}

/*
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url;
{

}

/*
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;
{

}

/*
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog;
{

}

/*
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;
{

}

/*
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url;
{
    return YES;
    
}





@end
