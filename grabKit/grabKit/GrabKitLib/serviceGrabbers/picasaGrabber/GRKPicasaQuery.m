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

#import "GRKPicasaQuery.h"
#import "GRKPicasaSingleton.h"

#import "NSDictionary+URLEncoding.h"

@interface GRKPicasaQuery()
- (void)ticket:(GDataServiceTicket *)ticket finishedWithFeed:(id)feed error:(NSError *)error;
@end


@implementation GRKPicasaQuery


-(id) initWithFeedURL:(NSURL *)_feedURL 
           andParams:(NSMutableDictionary *)_params
   withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
       andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    if ((self = [super init]) != nil){
        
        params = _params;

        [params setValue:@"https://picasaweb.google.com/data/" forKey:@"scope"];
        
        //Build proper URL with params here
        NSString * paramsString = [params URLEncodedString];
        
        NSString * feedLinkWithParams = nil;
        if ( ((NSRange)[[_feedURL absoluteString] rangeOfString:@"?"]).location == NSNotFound ){
            feedLinkWithParams = [NSString stringWithFormat:@"%@?%@",[_feedURL absoluteString], paramsString];
        } else feedLinkWithParams = [NSString stringWithFormat:@"%@&%@",[_feedURL absoluteString], paramsString];
        
        
        feedURL = [NSURL URLWithString:feedLinkWithParams];
        
        ticket = nil;
        
        handlingBlock = [_handlingBlock copy];
        errorBlock = [_errorBlock copy];        

    }
    
    return self;
    
}

+(GRKPicasaQuery*) queryWithFeedURL:(NSURL *)_feedURL 
			            andParams:(NSMutableDictionary *)_params
                withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
                    andErrorBlock:(GRKErrorBlock)_errorBlock;
{
    
    GRKPicasaQuery * queryToReturn = [[GRKPicasaQuery alloc] initWithFeedURL:_feedURL 
							                              andParams:_params
                                                 withHandlingBlock:_handlingBlock 
                                                       andErrorBlock:_errorBlock];
    
    return queryToReturn;
    
    
}


-(id) initWithQuery:(GDataQuery *)_query
  withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
      andErrorBlock:(GRKErrorBlock)_errorBlock; {
    
    self = [super init];
    if ( self ){
        
        query = _query;
        
        handlingBlock = [_handlingBlock copy];
        errorBlock = [_errorBlock copy];       
        
    }
    
    
    return self;    
}

+(GRKPicasaQuery*) queryWithQuery:(GDataQuery *)_query
                withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
                    andErrorBlock:(GRKErrorBlock)_errorBlock; {
    
    GRKPicasaQuery * queryToReturn = [[GRKPicasaQuery alloc] initWithQuery:_query 
                                                 withHandlingBlock:_handlingBlock 
                                                     andErrorBlock:_errorBlock];
    return queryToReturn;
    
}



-(void) perform {

    GDataServiceGooglePhotos * service = [GRKPicasaSingleton sharedInstance].service;
    
    if ( query == nil ){
	    
        ticket = [service fetchFeedWithURL:feedURL
                                  delegate:self
                         didFinishSelector:@selector(ticket:finishedWithFeed:error:)];
        
    } else {
        
        ticket = [service fetchFeedWithQuery:query
                                    delegate:self 
                           didFinishSelector:@selector(ticket:finishedWithFeed:error:)];
        
    }
     
}

- (void)ticket:(GDataServiceTicket *)_ticket finishedWithFeed:(id)feed error:(NSError *)error;
{

    if ( error ){
        if ( errorBlock != nil ){
            errorBlock(error);
        }
    } else if (handlingBlock != nil) {
        handlingBlock(self, feed);
    }
   
    return;
}



-(void) cancel {
    
    handlingBlock = nil;
    errorBlock = nil;
    [ticket cancelTicket];

}



@end
