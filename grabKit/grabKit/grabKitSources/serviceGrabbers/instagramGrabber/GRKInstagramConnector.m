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
#import "GRKInstagramConnector.h"
#import "GRKConnectorsDispatcher.h"
#import "GRKConstants.h"
#import "GRKInstagramSingleton.h"
#import "GRKInstagramQuery.h"
#import "GRKTokenStore.h"

@interface GRKInstagramConnector()
-(void) removeAccessTokenFromDefaults;
@end

@implementation GRKInstagramConnector

static NSString * accessTokenKey = @"AccessTokenKey";


-(id) initWithGrabberType:(NSString *)type;
{
    if ((self = [super initWithGrabberType:type]) != nil){
        connectionIsCompleteBlock = nil;
        connectionDidFailBlock = nil;
        
        _queries = [NSMutableArray array];
    }
    
    return self;
}


-(void) removeAccessTokenFromDefaults;
{
    [GRKTokenStore removeTokenWithName:accessTokenKey forGrabberType:grabberType];
    
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{   
    connectionIsCompleteBlock = [completeBlock copy];
    connectionDidFailBlock = [errorBlock copy];
    
    NSString * token = [GRKTokenStore tokenWithName:accessTokenKey forGrabberType:grabberType];
    
    if ( token != nil ){
        
        [GRKInstagramSingleton sharedInstance].access_token = token;
        
        __block GRKInstagramQuery * testLoginQuery = nil;
        testLoginQuery = [GRKInstagramQuery queryWithEndpoint:@"users/self" 
                                 withParams:nil 
                          withHandlingBlock:^(GRKInstagramQuery *query, id result){
                    
                              if ( ! [result isKindOfClass:[NSDictionary class]] || [result objectForKey:@"data"] == nil ){
                                  
                                  [self removeAccessTokenFromDefaults];
                                  [self connectWithConnectionIsCompleteBlock:completeBlock andErrorBlock:errorBlock];
                                  testLoginQuery = nil;
                                  return ;
                                  
                              }
                              
                              if ( connectionIsCompleteBlock != nil ){
                                  connectionIsCompleteBlock(YES);
                                  connectionIsCompleteBlock = nil;
                              }
                              testLoginQuery = nil;
                              
                          } andErrorBlock:^(NSError * error){

                              [self removeAccessTokenFromDefaults];
                              [self connectWithConnectionIsCompleteBlock:completeBlock andErrorBlock:errorBlock];
                              testLoginQuery = nil;
                              
                          }];
        
        [_queries addObject:testLoginQuery];
        [testLoginQuery perform];
        return;

    }
    
  
    
	NSString * authenticationUrlStr = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", [GRKCONFIG instagramAppId], [GRKCONFIG instagramRedirectUri] ];
    
    [[GRKConnectorsDispatcher sharedInstance] registerServiceConnectorAsConnecting:self];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authenticationUrlStr]];
    
}


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;
{
    
    // The user may still stay connected in safari, 
    // so next time it'll try to log in Instagram, he will be automatically logged and authorized.
    // to prevent this (and let to opportunity to the user to log with a different account), 
    // make the user open the following url in safari : https://instagram.com/accounts/logout/
    
    
    [self removeAccessTokenFromDefaults];
    
    if ( disconnectionIsCompleteBlock != nil ){
        disconnectionIsCompleteBlock(YES);
    }
    
    
}




/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{

    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    
    NSString * token = [GRKTokenStore tokenWithName:accessTokenKey forGrabberType:grabberType];
    
    if ( token != nil ){
        
        [GRKInstagramSingleton sharedInstance].access_token = token;
     
        __block GRKInstagramQuery * testLoginQuery = nil;
        testLoginQuery = [GRKInstagramQuery queryWithEndpoint:@"users/self" 
                                                   withParams:nil 
                                            withHandlingBlock:^(GRKInstagramQuery *query, id result){
                                                
                                                if ( ! [result isKindOfClass:[NSDictionary class]] || [result objectForKey:@"data"] == nil ){
                                                    connectedBlock(NO);
                                                    testLoginQuery = nil;
                                                    return ;
                                                }
                                                
                                                connectedBlock(YES);
                                                testLoginQuery = nil;
                                                
                                            } andErrorBlock:^(NSError * error){
                                                
                                                connectedBlock(NO);
                                                testLoginQuery = nil;
                                                
                                            }];
        [_queries addObject:testLoginQuery];
        [testLoginQuery perform];
        return;
        
    } else connectedBlock(NO);
    
    
}


-(void) cancelAll {
    
    connectionIsCompleteBlock = nil;
    connectionDidFailBlock = nil;
    
    for ( GRKInstagramQuery * query in _queries ){
        [query cancel];
    }
    
    [_queries removeAllObjects];
    
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
    return ( [[[url scheme] stringByAppendingString:@"://"] isEqualToString:[GRKCONFIG instagramRedirectUri]] );
    
}


/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) handleOpenURL:(NSURL*)url;
{
    
    /* If the user denies access to the application, the called url is like : 
            mygreatapplication://?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.
        So let's check for the occurence of "error" in the url
     */
    if ( ((NSRange)[[url absoluteString] rangeOfString:@"error"]).location != NSNotFound ){
        
        if ( connectionDidFailBlock != nil ){
            
            NSError * error = [NSError errorWithDomain:[NSString stringWithFormat:@"com.grabKit.%@.connectionDenied", grabberType]
                                                  code:0 userInfo:nil];
            connectionDidFailBlock(error);
        }
        
    
    /*  Else, if the user grants access to the application, the called url is like :
            myapplicationscheme://#access_token=11461188.68fb98a.e678eccd9be342b6b677a86cfda6ea99   */    
    }else {
        
        // let's remove the first part to retrieve the access_token
        NSString * stringToRemove = [NSString stringWithFormat:@"%@#access_token=", [GRKCONFIG instagramRedirectUri]];
        NSString * access_token = [[url absoluteString] stringByReplacingOccurrencesOfString:stringToRemove withString:@""];

        // save the access_token in TokenStore
        [GRKTokenStore storeToken:access_token withName:accessTokenKey forGrabberType:grabberType];
        
        
        // and assign the access_token to the GRKInstagramSingleton
        [GRKInstagramSingleton sharedInstance].access_token = access_token;

        if ( connectionIsCompleteBlock != nil ) {
            connectionIsCompleteBlock(YES);
            connectionIsCompleteBlock = nil;
        }
            
    }
    
    
    connectionIsCompleteBlock = nil;
    
    connectionDidFailBlock = nil;
    
}


@end