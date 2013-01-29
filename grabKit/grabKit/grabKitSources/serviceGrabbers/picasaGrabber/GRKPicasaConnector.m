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
#import "GRKConstants.h"
#import "GRKPicasaSingleton.h"

// Subclass used to define the Bundle of the OAuth xib.
@interface GRKPicasaOAuth2ViewControllerTouch : GTMOAuth2ViewControllerTouch 
@end

@implementation GRKPicasaOAuth2ViewControllerTouch
+ (NSBundle *)authNibBundle {
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"GrabKitBundle" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

@end




@implementation GRKPicasaConnector

NSString * keychainItemName = @"GoogleOAuth2Keychain";

-(id) initWithGrabberType:(NSString *)type;
{
    
    if ((self = [super initWithGrabberType:type]) != nil){
        
    }     
    
    return self;
}


-(BOOL) isLoggedIn {
    
   
	GTMOAuth2Authentication *auth = [GRKPicasaOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                          clientID:[GRKCONFIG picasaClientId]
                                                      clientSecret:[GRKCONFIG picasaClientSecret]];
    
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
    
    connectionIsCompleteBlock = [completeBlock copy];
	
    GRKPicasaOAuth2ViewControllerTouch * authController = nil;
    
    
    authController = [GRKPicasaOAuth2ViewControllerTouch controllerWithScope:scope
                                                              clientID:[GRKCONFIG picasaClientId]
                                                          clientSecret:[GRKCONFIG picasaClientSecret]
                                                      keychainItemName:keychainItemName
                                                     completionHandler:
                 ^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error){
                     
                    
                     [GRKPicasaOAuth2ViewControllerTouch 
                      saveParamsToKeychainForName:keychainItemName
                      authentication:auth];
                     
                     [[GRKPicasaSingleton sharedInstance] setUserEmailAdress:auth.userEmail];
                     [[[GRKPicasaSingleton sharedInstance] service] setAuthorizer:auth];

                     
                     if ( error ) {
                         
                         // errors -1000 and -1001 are thrown when the user refuses the connection (respectively before and after being logged in )
                         if ( error.code == -1000 || error.code == -1001 ) {
                             
                             [presentingViewController dismissViewControllerAnimated:YES completion:^{
                                 if ( completeBlock != nil ){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                            completeBlock(NO);
                                     });
                                 }
                             }];
                             
                         } else {
                         
                             [presentingViewController dismissViewControllerAnimated:YES completion:^{
                                 if ( errorBlock != nil ){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         errorBlock(error);
                                     });
                                 }
                             }];
                             
                         }
                         
                     }else {
                      
                         [presentingViewController dismissViewControllerAnimated:YES completion:^{
                             if ( completeBlock != nil ){
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completeBlock(YES);
                                 });
                             }
                         }];
                     
                     }
                     
                     
                 }];
    

    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:authController];
    
    
    authController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didNotCompleteConnection)];
    
    
    [presentingViewController presentViewController:navController animated:YES completion:nil];
 
    
}


/*  @see refer to GRKServiceConnectorProtocol documentation
 */
-(void) didNotCompleteConnection;
{
    
    UIViewController * presentingViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    [presentingViewController dismissViewControllerAnimated:YES completion:^{

        if ( connectionIsCompleteBlock != nil ){
            dispatch_async(dispatch_get_main_queue(), ^{
                connectionIsCompleteBlock(NO);
                connectionIsCompleteBlock = nil;
            });
        }

        
    }];
    
}


-(void) disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)completeBlock;
{
    
    
    GTMOAuth2Authentication *auth = [GRKPicasaOAuth2ViewControllerTouch authForGoogleFromKeychainForName:keychainItemName
                                                                                          clientID:[GRKCONFIG picasaClientId]
                                                                                      clientSecret:[GRKCONFIG picasaClientSecret]];

    [GRKPicasaOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    [GRKPicasaOAuth2ViewControllerTouch removeAuthFromKeychainForName:keychainItemName];
    
    [[GRKPicasaSingleton sharedInstance] setUserEmailAdress:nil];
    [[[GRKPicasaSingleton sharedInstance] service] setAuthorizer:nil];

    
    if ( completeBlock != nil ){
        
        completeBlock(YES);
        
    }

    
}


@end
