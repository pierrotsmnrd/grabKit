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

#import "GRKInstagramSingleton.h"
#import "GRKInstagramQuery.h"

#import "NSDictionary+URLEncoding.h"


@interface GRKInstagramQuery()
-(NSURL*) URLForEndpoint:(NSString *)_endpoint andParams:(NSDictionary*)_params;
@end

NSString * kInstagramApiEndpoint = @"https://api.instagram.com/v1";

@implementation GRKInstagramQuery


-(id) initWithEndpoint:(NSString *)_endpoint 
            withParams:(NSMutableDictionary *)_params
     withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
         andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    
    if ((self = [super init]) != nil){
        
        NSURLRequest * request = [NSURLRequest requestWithURL:[self URLForEndpoint:_endpoint andParams:_params]];
        cnx = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        data = [[NSMutableData alloc] init];
        
        endpoint = _endpoint;
        params = _params;
        
        handlingBlock = _handlingBlock;
        errorBlock = _errorBlock;
        
    }
    
    return self;

}


-(NSURL*) URLForEndpoint:(NSString *)_endpoint andParams:(NSDictionary*)_params;
{
    
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:_params];
    if ( [GRKInstagramSingleton sharedInstance].access_token != nil ){
        [allParams setObject:[GRKInstagramSingleton sharedInstance].access_token forKey:@"access_token"];
    }
    
    NSString * URLString = [NSString stringWithFormat:@"%@/%@?%@", kInstagramApiEndpoint, _endpoint, [allParams URLEncodedString] ];
    
    
    return [NSURL URLWithString:URLString];
    
}

+(GRKInstagramQuery*) queryWithEndpoint:(NSString *)_endpoint 
                            withParams:(NSMutableDictionary *)_params
                     withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
                         andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    
    GRKInstagramQuery * query = [[GRKInstagramQuery alloc] initWithEndpoint:_endpoint 
                                                                withParams:_params 
                                                         withHandlingBlock:_handlingBlock 
                                                              andErrorBlock:_errorBlock];
    
    return query;    
    
}


-(void) perform; 
{
    
    [cnx start];
    
    
}



-(void) cancel;
{
    [cnx cancel];
    
    errorBlock = nil;
    handlingBlock = nil;
    
}


#pragma mark NSURLConnectionDelegate methods

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData;
{
    [data appendData:receivedData];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection;
{

    // at this point, the collected data is a JSON chunk representing the actual data
     
    NSError * jsonDecodingError = nil;
    id result =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonDecodingError];
    
    if ( jsonDecodingError != nil ){
        
        if ( errorBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(jsonDecodingError);
            });
        }
        
        return;
    }
    
    
    if ( handlingBlock != nil ){
        dispatch_async(dispatch_get_main_queue(), ^{
                handlingBlock(self, result);
        });
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
    
    if ( errorBlock != nil ){
        dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock(error);
        });
    }
}



@end
