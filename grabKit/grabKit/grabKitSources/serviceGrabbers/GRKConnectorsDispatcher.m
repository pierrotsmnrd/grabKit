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


#import "GRKConnectorsDispatcher.h"

static GRKConnectorsDispatcher * sharedConnectorsDispatcher = nil;

@implementation GRKConnectorsDispatcher


+ (GRKConnectorsDispatcher *)sharedInstance; 
{
    
    if ( sharedConnectorsDispatcher == nil ){
        
        sharedConnectorsDispatcher = [[GRKConnectorsDispatcher alloc] init];
        
    }
    
    return sharedConnectorsDispatcher;
}


- (id)init {
    
    if ((self = [super init]) != nil){
        
        serviceConnectorConnecting = nil;
        
    }
    
    return self;
    
}



- (void)applicationDidBecomeActive;
{
    if ( serviceConnectorConnecting != nil ){
        
        [serviceConnectorConnecting didNotCompleteConnection];
        [self unregisterServiceConnectorAsConnecting:serviceConnectorConnecting];
        
    }
    
}

- (void)registerServiceConnectorAsConnecting:(id)serviceConnector;
{
    if ( serviceConnector != serviceConnectorConnecting ){
    
        [self unregisterServiceConnectorAsConnecting:serviceConnectorConnecting];
        
        serviceConnectorConnecting = serviceConnector;
    }
}


- (void)unregisterServiceConnectorAsConnecting:(id)serviceConnector;
{
    serviceConnectorConnecting = nil;
}





- (BOOL)dispatchURLToConnectingServiceConnector:(NSURL *)url;
{
  
   
    if ( [serviceConnectorConnecting respondsToSelector:@selector(canHandleURL:)] ){

        if ( ! [(NSObject<GRKServiceConnectorProtocol> *)serviceConnectorConnecting canHandleURL:url] )
            return NO;
        
        
        if ( [serviceConnectorConnecting respondsToSelector:@selector(handleOpenURL:)] ){
            
            [(NSObject<GRKServiceConnectorProtocol> *)serviceConnectorConnecting handleOpenURL:url]; 
            [self unregisterServiceConnectorAsConnecting:serviceConnectorConnecting];
            return YES;
        }

    }
    
    
    return NO;
    
        
}





@end
