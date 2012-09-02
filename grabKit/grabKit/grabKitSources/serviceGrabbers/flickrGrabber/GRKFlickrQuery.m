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

#import "GRKFlickrQuery.h"
#import "GRKFlickrSingleton.h"


@implementation GRKFlickrQuery


-(id) initWithMethod:(NSString *)_method 
			 andParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
          andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    if ((self = [super init]) != nil){
      
        method = _method;
        params = _params;
        
        handlingBlock = _handlingBlock;
        errorBlock = _errorBlock;
    }
    
    return self;
    
}


+(GRKFlickrQuery*) queryWithMethod:(NSString *)_method 
                        andParams:(NSMutableDictionary *)_params
                 withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
                     andErrorBlock:(GRKErrorBlock)_errorBlock;
{
   
    GRKFlickrQuery * query = [[GRKFlickrQuery alloc] initWithMethod:_method 
                                                           andParams:_params
                                                   withHandlingBlock:_handlingBlock 
                                                       andErrorBlock:_errorBlock];
    return query;
    
    
}


-(void) perform {
    
	request = [[OFFlickrAPIRequest alloc] initWithAPIContext:[GRKFlickrSingleton sharedInstance].context ];
	
	if ( [params objectForKey:@"requestTimeoutInterval"] != nil ) {
        
		//default is 10.0
		[request setRequestTimeoutInterval:[[params objectForKey:@"requestTimeoutInterval"] doubleValue]];
		[params removeObjectForKey:@"requestTimeoutInterval"];
	}
	
	// The request's delegate is an assign property.
    // if the GRKFlickrQuery is autoreleased, it'll be released before the request achieves.
	[request setDelegate:self]; 

	
    
	[request callAPIMethodWithGET:method arguments:params];	
	
    
}


-(void) cancel {
    
    [request cancel];
    handlingBlock = nil;
    errorBlock = nil;
    
}

#pragma mark OFFlickrAPIRequestDelegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	
	if (handlingBlock != nil ){
        @synchronized(self) {
	        handlingBlock(self, inResponseDictionary);
        }
    }

}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)error {
    
	if ( errorBlock != nil ){
        @synchronized(self) {
	        errorBlock(error);
        }
    }
   
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes {
    

}


@end


