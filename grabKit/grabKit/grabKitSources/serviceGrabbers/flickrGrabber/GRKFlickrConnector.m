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

#import <UIKit/UIKit.h>
#import "GRKFlickrConnector.h"
#import "GRKConstants.h"
#import "GRKConnectorsDispatcher.h"
#import "GRKFlickrSingleton.h"
#import "GRKFlickrQuery.h"
#import "GRKAlbum.h"
#import "OFUtilities.h"
#import "GRKTokenStore.h"

@interface GRKFlickrConnector()
-(void) removeAccessTokenAndSecretFromTokenStore;
-(NSURL *)callbackURL;
@end


static NSString * accessTokenKey = @"AccessTokenKey";
static NSString * secretKey = @"SecretKey";


@implementation GRKFlickrConnector


-(id) initWithGrabberType:(NSString *)type;
{
    if ((self = [super initWithGrabberType:type]) != nil){

        oAuthRequest = nil;
        connectionIsCompleteBlock = nil;
        connectionDidFailBlock = nil;
        _queries = [NSMutableArray array];
    }
    
    return self;
}

-(NSURL*) callbackURL;
{
	return [NSURL URLWithString:[GRKCONFIG flickrRedirectUri]];
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
 
    NSString * accessToken = [GRKTokenStore tokenWithName:accessTokenKey forGrabberType:grabberType];
    NSString * secret = [GRKTokenStore tokenWithName:secretKey forGrabberType:grabberType];
    
    if ( accessToken != nil &&  secret != nil) {
        
        
        [[GRKFlickrSingleton sharedInstance].context setOAuthToken:accessToken];
        [[GRKFlickrSingleton sharedInstance].context setOAuthTokenSecret:secret];
        
        __block GRKFlickrConnector * selfForBlocks = self;
        
        __block GRKFlickrQuery * testLoginQuery = nil;
        
        testLoginQuery = [GRKFlickrQuery queryWithMethod:@"flickr.test.login" 
                                                              andParams:nil 
                                                      withHandlingBlock:^(GRKFlickrQuery * query, id result){

                                                          if ( ! [result isKindOfClass:[NSDictionary class]] ){

                                                              // invalidate the stored token

                                                              [self removeAccessTokenAndSecretFromTokenStore];
                                                              
                                                              [selfForBlocks  connectWithConnectionIsCompleteBlock:completeBlock 
                                                                                       andErrorBlock:errorBlock];
                                                              
                                                              testLoginQuery = nil;
                                                              return;
                                                          }
                                                          
                                                          if ( [[result objectForKey:@"stat"] isEqualToString:@"ok"] ){
                                                              
                                                              if ( completeBlock != nil ){
                                                                  @synchronized(selfForBlocks) {
                                                                      completeBlock(YES);
                                                                  }
                                                              }
                                                          }
                                                         
                                                          testLoginQuery = nil;
                                                          
                                                      } andErrorBlock:^(NSError * error){
                                                      
                                                          
                                                          [self removeAccessTokenAndSecretFromTokenStore];                                                          
                                                          [[GRKFlickrSingleton sharedInstance].context setOAuthToken:nil];
                                                          [[GRKFlickrSingleton sharedInstance].context setOAuthTokenSecret:nil];

                                                          
                                                          
                                                          [selfForBlocks  disconnectWithDisconnectionIsCompleteBlock:nil];
                                                        
                                                          [selfForBlocks  connectWithConnectionIsCompleteBlock:completeBlock 
                                                                                                 andErrorBlock:errorBlock];
                                                          
                                                          testLoginQuery = nil;
                                                      }];
        [_queries addObject:testLoginQuery];
        [testLoginQuery perform];
        
        return;
    }
    
    
    
    connectionIsCompleteBlock = [completeBlock copy];
    connectionDidFailBlock = [errorBlock copy];
    
    [[GRKConnectorsDispatcher sharedInstance] registerServiceConnectorAsConnecting:self];
    

	oAuthRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[GRKFlickrSingleton sharedInstance].context ];
    oAuthRequest.delegate = self;
    
    [oAuthRequest  fetchOAuthRequestTokenWithCallbackURL:[self callbackURL]];
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;
{
    
    [self removeAccessTokenAndSecretFromTokenStore];
    
    [GRKFlickrSingleton sharedInstance].context.OAuthToken = nil;
    [GRKFlickrSingleton sharedInstance].context.OAuthTokenSecret = nil;
    
    if ( disconnectionIsCompleteBlock != nil ){
        disconnectionIsCompleteBlock(YES);
    }
    
}

/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{
  

    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    
    
    
    // restore accessToken and secret if they were previously stored
    NSString * accessToken = [GRKTokenStore tokenWithName:accessTokenKey forGrabberType:grabberType];
    NSString * secret = [GRKTokenStore tokenWithName:secretKey forGrabberType:grabberType];
    
    if ( accessToken != nil &&  secret != nil) {
        
        [[GRKFlickrSingleton sharedInstance].context setOAuthToken:accessToken];
        [[GRKFlickrSingleton sharedInstance].context setOAuthTokenSecret:secret];
        
    }
    
    __block GRKFlickrQuery * testLoginQuery = nil;
    
    testLoginQuery = [GRKFlickrQuery queryWithMethod:@"flickr.test.login" 
                                           andParams:nil 
                                   withHandlingBlock:^(GRKFlickrQuery * query, id result){
                                       
                                       if ( ! [result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"stat"] != nil){
                                           
                                           connectedBlock(NO);                                                      
                                           testLoginQuery = nil;
                                           
                                           return;
                                       }
                                       
                                       if ( [[result objectForKey:@"stat"] isEqualToString:@"ok"] ){
                                           connectedBlock(YES);                                           
                                       } else connectedBlock(NO);
                                       
                                       testLoginQuery = nil;
                                       
                                   } andErrorBlock:^(NSError * error){
                                       
                                       connectedBlock(NO);
                                       testLoginQuery = nil;
                                       
                                   }];
    [_queries addObject:testLoginQuery];
    [testLoginQuery perform];
    
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
    return ( [[NSString stringWithFormat:@"%@://",  [url scheme]] isEqualToString:[GRKCONFIG flickrRedirectUri]] );
}

/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) handleOpenURL:(NSURL*)url;
{
    NSString * outRequestToken = nil;
 	NSString * outVerifier = nil;
    OFExtractOAuthCallback(url, [self callbackURL], &outRequestToken, &outVerifier);
    
    [oAuthRequest fetchOAuthAccessTokenWithRequestToken:outRequestToken verifier:outVerifier];
        
}


-(void) removeAccessTokenAndSecretFromTokenStore {
    
	[GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
	[GRKTokenStore removeTokenWithName:secretKey forGrabberType:grabberType];
    
}


-(void) cancelAll {
    
    [oAuthRequest cancel];
    
    for ( GRKFlickrQuery * query in _queries ){
        [query cancel];
    }
    
    [_queries removeAllObjects];

    
}


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret;
{
    
    [GRKFlickrSingleton sharedInstance].context.OAuthToken = inRequestToken;
    [GRKFlickrSingleton sharedInstance].context.OAuthTokenSecret = inSecret;
    
    NSURL * userAuthorizationURL = [[GRKFlickrSingleton sharedInstance].context userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrReadPermission];
    
    [[UIApplication sharedApplication] openURL:userAuthorizationURL];
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError;
{
    if ( connectionDidFailBlock != nil ){
        connectionDidFailBlock(inError);
    }

}



- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID;
{

    [GRKTokenStore storeToken:inAccessToken withName:accessTokenKey forGrabberType:grabberType];
    [GRKTokenStore storeToken:inSecret withName:secretKey forGrabberType:grabberType];
    
    [[GRKFlickrSingleton sharedInstance].context setOAuthToken:inAccessToken];
    [[GRKFlickrSingleton sharedInstance].context setOAuthTokenSecret:inSecret];
    
    if ( connectionIsCompleteBlock != nil ){
        connectionIsCompleteBlock(YES);
        connectionIsCompleteBlock = nil;
    }
    
    
}





@end
