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

#import "GRKPicasaConnector.h"
#import "GRKConstants.h"
#import "GRKPicasaSingleton.h"
#import "GRKPickerViewController.h"

// Subclass used to define the Bundle of the OAuth xib.
@interface GRKPicasaOAuth2ViewControllerTouch : GTMOAuth2ViewControllerTouch 
@end

@implementation GRKPicasaOAuth2ViewControllerTouch
+ (NSBundle *)authNibBundle {
    return GRK_BUNDLE;
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


/* @see refer to GRKServiceGrabberConnectionProtocol documentation
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock errorBlock:(GRKErrorBlock)errorBlock;
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
    
    
    _viewControllerToPresentAuthFrom = [GRKPickerViewController sharedInstance];
    BOOL isUsingACustomController = NO;
    BOOL shouldPresentModally = NO;
    UIViewController * viewControllerToPopToAfterAuth = [[GRKPickerViewController sharedInstance] topViewController];

    
    if ( [ ((id) [GRKConfiguration sharedInstance].configurator) respondsToSelector:@selector(customViewControllerToPresentPicasaAuthController)] ){
        
        UIViewController * customViewControllerToPresentAuthFrom = [GRKCONFIG customViewControllerToPresentPicasaAuthController];
        
        if ( customViewControllerToPresentAuthFrom != nil){
            
            _viewControllerToPresentAuthFrom = customViewControllerToPresentAuthFrom;
            isUsingACustomController = YES;
            
            if ( [customViewControllerToPresentAuthFrom isKindOfClass:[UINavigationController class]]
            && [ ((id) [GRKConfiguration sharedInstance].configurator) respondsToSelector:@selector(customViewControllerShouldPresentPicasaAuthControllerModally)]){
        
                shouldPresentModally = [GRKCONFIG customViewControllerShouldPresentPicasaAuthControllerModally];
                if ( ! shouldPresentModally ){
                    viewControllerToPopToAfterAuth = [(UINavigationController*)_viewControllerToPresentAuthFrom topViewController];
                }
                
            } else {
            
                shouldPresentModally = YES;
            }
        }
    }
    
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

                     
                     
                     double delayInSeconds = 0.666; // 666, because the Devil is in the details.
                     
                     if ( error ) {
                         
                         // errors -1000 and -1001 are thrown when the user refuses the connection (respectively before and after being logged in )
                         if ( error.code == -1000 || error.code == -1001 ) {
                             
                             // remove the authentication controller.
                             if ( shouldPresentModally ){
                                 // When is configured to be presented "modally"
                                 [_viewControllerToPresentAuthFrom dismissViewControllerAnimated:YES completion:nil];

                             } else if ( isUsingACustomController ){
                                 // When using a custom controller that is an instance of UINavigationController
                                 [(UINavigationController*)_viewControllerToPresentAuthFrom popToViewController:viewControllerToPopToAfterAuth animated:YES];
                             } else {
                                 // Or when using the picker ...
                                 [(UINavigationController*)_viewControllerToPresentAuthFrom popToRootViewControllerAnimated:YES];
                             }
                             
                             
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 completeBlock(NO);
                                 _viewControllerToPresentAuthFrom = nil;
                             });

                             
                             
                         } else {
                         
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 errorBlock(error);
                                 _viewControllerToPresentAuthFrom = nil;
                             });

                         }
                         
                     }else {
                      
                         
                         // remove the authentication controller.
                         if ( shouldPresentModally ){
                             // When is configured to be presented "modally"
                             [_viewControllerToPresentAuthFrom dismissViewControllerAnimated:YES completion:nil];
                             
                         } else {
                             // When using a custom controller that is an instance of UINavigationController, or when using the picker ...
                             [(UINavigationController*)_viewControllerToPresentAuthFrom popToViewController:viewControllerToPopToAfterAuth animated:YES];
                         }
                         
                         
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             completeBlock(YES);
                             _viewControllerToPresentAuthFrom = nil;
                         });
                        
                     }
                     
                     
                 }];
    

    // Present the auth controller according to the config : modally, or pushed in the navigation hierarchy
    if (shouldPresentModally ){
        
        // Wrap the Auth controller in a navigationController to show the navigation bar, featuring a "Cancel" button
        
        UINavigationController * wrappingNavigationController = [[UINavigationController alloc] initWithRootViewController:authController];

        authController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAuthController)];
        
        [_viewControllerToPresentAuthFrom presentViewController:wrappingNavigationController animated:YES completion:nil];
        
        
    } else {
        
        [(UINavigationController*)_viewControllerToPresentAuthFrom pushViewController:authController animated:YES];
    }
    
    
}
-(void)dismissAuthController {

    [_viewControllerToPresentAuthFrom dismissViewControllerAnimated:YES completion:^{
        
    }];
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


-(void) disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;
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

    // in the future, handle errors if needed
    
}


@end
