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
#import "FBRequest+GRKAdditions.h"

@implementation GRKFacebookQuery

-(void) dealloc {
    
    [request release];
    [graphPath release];
    [params release];
    [handlingBlock release];
    [errorBlock release];
    
    [super dealloc];
    
}

-(id) initWithGraphPath:(NSString *)_graphPath 
			 withParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKFacebookQueryHandlingBlock)_handlingBlock
          andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    if ((self = [super init]) != nil){
        
        request = nil;
        
        graphPath = [_graphPath retain];
        params = [_params retain];

        handlingBlock = [_handlingBlock copy];
        errorBlock = [_errorBlock copy];        
        
    }
    
    return self;

}


+(GRKFacebookQuery*) queryWithGraphPath:(NSString *)_graphPath 
            withParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKFacebookQueryHandlingBlock)_handlingBlock
         andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    
    GRKFacebookQuery * query = [[[GRKFacebookQuery alloc] initWithGraphPath:_graphPath 
                                                              withParams:_params 
                                                       withHandlingBlock:_handlingBlock 
                                                           andErrorBlock:_errorBlock] autorelease];
    

    return query;
    
    
}

-(void) perform;
{
    
    request = [[[GRKFacebookSingleton sharedInstance] facebook] requestWithGraphPath:graphPath andParams:params andDelegate:self];
    [request retain];

    
}

-(void) cancel {
    [request cancel];
}


#pragma mark FBRequestDelegate methods


- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
    
};



/*
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)_request didFailWithError:(NSError*)error{
    
	if ( errorBlock != nil ) {
        @synchronized(self) {
        	errorBlock(error);
        }
    }


};


/*
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on the format of the API response.
 */
- (void)request:(FBRequest*)_request didLoad:(id)result{
	
	if ( handlingBlock != nil ){
        @synchronized(self) {
	    	handlingBlock(self, result);
        }
    }
	
};






@end
