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


#import "GRKFacebookBatchQuery.h"


#import <FacebookSDK/FBSession.h>
#import <FacebookSDK/FBRequest.h>

@interface GRKFacebookBatchQuery()
-(void) performFinalBlocksIfNeeded;
@end


@implementation GRKFacebookBatchQuery

-(void)dealloc {
    _finalHandlingBlock = nil;
}

-(id)init {
    
    self = [super init];
    
    if ( self ){
        
        _requestConnection = [[FBRequestConnection alloc] init];
        _results = [NSMutableDictionary dictionary];
        
        _numberOfAddedRequests = 0;
        _numberOfRunningRequests = 0;

        didCancelFlag = NO;
    }
    
    
    return self;
}




-(void)addQueryWithGraphPath:(NSString *)graphPath 
                  withParams:(NSMutableDictionary *)params
                     andName:(NSString*)name
            andHandlingBlock:(GRKSubqueryResultBlock)handlingBlock {
    
    FBRequest * request =  [[FBRequest alloc] initWithSession:FBSession.activeSession 
                                                       graphPath:graphPath 
                                                      parameters:params 
                                                      HTTPMethod:@"GET"];

    
    if ( name == nil || [name length] == 0 ){
        name = [NSString stringWithFormat:@"%p", request];
    }

    
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {
        
        _numberOfRunningRequests--;
        
        
        // When a FBRequest is canceled, this request handler is called with an error "The operation could not be completed"
        // So if the user did cancel, don't call the handling block.
        if ( error != nil && didCancelFlag ){
            return;
        }
        
        if ( handlingBlock != nil ){
            id handledResult = handlingBlock(self, result, error);
       
            if ( handledResult != nil ){
                [_results setObject:handledResult forKey:name];
            }
            
        }
        
        [self performFinalBlocksIfNeeded];
        
        
    };

    
    [_requestConnection addRequest:request completionHandler:handler batchEntryName:name];
    _numberOfAddedRequests++;
    
}

-(void) performFinalBlocksIfNeeded {
    
    if ( _numberOfRunningRequests == 0  && _finalHandlingBlock != nil ){
    
        dispatch_async(dispatch_get_main_queue(), ^{
            _finalHandlingBlock(self, _results);
        });
        
        _requestConnection = nil;   
        
    }
    
}

-(void)performWithFinalBlock:(GRKQueryResultBlock)handlingBlock {
    
    _finalHandlingBlock = [handlingBlock copy];
        
    _numberOfRunningRequests = _numberOfAddedRequests;
    
    [_requestConnection start];
    
}



-(void) cancel {

    didCancelFlag = YES;
    
    _finalHandlingBlock = nil;
    [_requestConnection cancel];
    _requestConnection = nil;
}


@end
