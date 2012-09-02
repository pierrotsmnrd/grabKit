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


#import "GRKFacebookQuery.h"
#import "GRKFacebookSingleton.h"

#import <FacebookSDK/FBSession.h>

@interface GRKFacebookQuery()
-(void) requestConnectionCompleted:(FBRequestConnection *)connection withResult:(id)result orError:(NSError*)error;
@end


@implementation GRKFacebookQuery


-(id) initWithGraphPath:(NSString *)_graphPath 
			 withParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
          andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    if ((self = [super init]) != nil){
        
        requestConnection = nil;
        request = nil;

        graphPath = _graphPath;
        params = _params;
        
        handlingBlock = _handlingBlock;
        errorBlock = _errorBlock;        

    }
    
    return self;

}


+(GRKFacebookQuery*) queryWithGraphPath:(NSString *)_graphPath 
            withParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
         andErrorBlock:(GRKErrorBlock)_errorBlock;
{

    GRKFacebookQuery * query = [[GRKFacebookQuery alloc] initWithGraphPath:_graphPath 
                                                                 withParams:_params 
                                                          withHandlingBlock:_handlingBlock 
                                                              andErrorBlock:_errorBlock];
    
    return query;
    
    
}

-(void) perform;
{
    
    // create the connection object
    requestConnection = [[FBRequestConnection alloc] init];
    
    FBRequestHandler handler = ^(FBRequestConnection *connection, id result, NSError *error) {

        [self requestConnectionCompleted:connection withResult:result orError:error];
    };

    
    request =  [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
    [requestConnection addRequest:request completionHandler:handler];
    
    [requestConnection start];

    
}

-(void) cancel {
    
    handlingBlock = nil;
    errorBlock = nil;
    [requestConnection cancel];

}


#pragma mark Completion handler method

-(void) requestConnectionCompleted:(FBRequestConnection *)connection withResult:(id)result orError:(NSError*)error {
    
    if (error != nil && errorBlock != nil ) {
        @synchronized(self) {
             errorBlock(error);
        }
    
    } else if ( result != nil && handlingBlock != nil ){
        @synchronized(self) {
	    	handlingBlock(self, result);
        }
    }
    
}



@end
