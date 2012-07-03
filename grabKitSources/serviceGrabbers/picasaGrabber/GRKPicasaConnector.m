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

#import "GRKPicasaConnector.h"
#import "GTMOAuth2ViewControllerTouch.h"

#import "GRKPicasaConstants.h"
#import "GRKPicasaSingleton.h"

@implementation GRKPicasaConnector

NSString * keychainItemName = @"GoogleOAuth2Keychain";

-(id) initWithGrabberType:(NSString *)type;
{
    
    if ((self = [super initWithGrabberType:type]) != nil){
        
    }     
    
    return self;
}


-(BOOL) isLoggedIn {
    
   
	GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                          clientID:kGRKPicasaClientId
                                                      clientSecret:kGRKPicasaClientSecret];
    
    [[GRKPicasaSingleton sharedInstance] setUserEmailAdress:auth.userEmail];
    [[[GRKPicasaSingleton sharedInstance] service] setAuthorizer:auth];

	return auth.canAuthorize;
}


-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;
{
    if ( connectedBlock == nil ) @throw NSInvalidArgumentException;
    connectedBlock([self isLoggedIn]);
    
}

-(void) connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
{
    
	if ( [self isLoggedIn] ){
        
        if ( completeBlock != nil ){
            completeBlock(YES);
        }
		return;
	}
    
    NSString * scope = @"https://photos.googleapis.com/data/";
    
    UIViewController * presentingViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    
	
    GTMOAuth2ViewControllerTouch * authController = nil;
    
    
    authController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                              clientID:kGRKPicasaClientId
                                                          clientSecret:kGRKPicasaClientSecret
                                                      keychainItemName:keychainItemName
                                                     completionHandler:
                 ^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error){
                     
                    
                     [GTMOAuth2ViewControllerTouch 
                      saveParamsToKeychainForName:keychainItemName
                      authentication:auth];
                     
                     [[GRKPicasaSingleton sharedInstance] setUserEmailAdress:auth.userEmail];
                     [[[GRKPicasaSingleton sharedInstance] service] setAuthorizer:auth];

                     
                     if ( error ) {
                         
                         NSLog(@" Error %@", error);
                         if ( errorBlock != nil ){
                             errorBlock(error);
                         }
                         
                     }else {
                      
                         [presentingViewController dismissModalViewControllerAnimated:YES];
                         if ( completeBlock != nil ){
                             completeBlock(YES);
                         }
                     }
                     
                     
                 }];
    

    
    [presentingViewController presentViewController:authController animated:YES completion:nil];
 
    
}

-(void) disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)completeBlock;
{
    
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                                                          clientID:kGRKPicasaClientId
                                                                                      clientSecret:kGRKPicasaClientSecret];

    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    
    [[GRKPicasaSingleton sharedInstance] setUserEmailAdress:nil];
    [[[GRKPicasaSingleton sharedInstance] service] setAuthorizer:nil];

    
    if ( completeBlock != nil ){
        
        completeBlock(YES);
        
    }

    
}


@end
