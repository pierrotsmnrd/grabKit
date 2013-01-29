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

#import "GrabKitDemoAppDelegate.h"
#import "GRKDemoServicesList.h"

// in your own appDelegate, add these imports :
#import "GRKConnectorsDispatcher.h"
#import "GRKConfiguration.h"

// Also import your custom class to configure GrabKit
#import "myGrabKitConfigurator.h"

@implementation GrabKitDemoAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GRKConfiguration initializeWithConfiguratorClassName:@"myGrabKitConfigurator"];
    // You can also initialize GRKConfiguration with an instance of your configurator :
   // [GRKConfiguration initializeWithConfigurator:[[GRKDemoConfigurator alloc] init]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    GRKDemoServicesList * servicesList = [[GRKDemoServicesList alloc] initWithNibName:@"GRKDemoServicesList" bundle:nil];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:servicesList];
    
    [self.window setRootViewController:navigationController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
    BOOL urlHasBeenHandledByDispatcher = [[GRKConnectorsDispatcher sharedInstance] dispatchURLToConnectingServiceConnector:url];
    
    if ( urlHasBeenHandledByDispatcher  ) return YES;
    
    // If you have specific URL schemes to handle for you application, 
    //  the GRKConnectorDispatcher won't handle the URL. 
    // Then, you can handle here your own URL schemes.
        
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
 
    [[GRKConnectorsDispatcher sharedInstance] applicationDidBecomeActive];
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
