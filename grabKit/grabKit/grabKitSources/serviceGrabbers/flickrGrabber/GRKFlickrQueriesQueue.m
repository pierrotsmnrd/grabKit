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

#import "GRKFlickrQueriesQueue.h"
#import "GRKConstants.h"

@interface GRKFlickrQueriesQueue()
-(void) performNextQuery;
@end

@implementation GRKFlickrQueriesQueue

-(id)init {
    
    self = [super init];
    if ( self ){
        
        _queries = [NSMutableArray array];
        _runningQueries = [NSMutableArray array] ;
        
        _results = [NSMutableDictionary dictionary];
        

    }
    
    return self;    
}

-(void)addQueryWithMethod:(NSString *)_method 
                andParams:(NSMutableDictionary *)_params
                  andName:(NSString*)name
         andHandlingBlock:(GRKSubqueryResultBlock)handlingBlock  {

    
    if ( name == nil || [name length] == 0 ){
        name = [NSString stringWithFormat:@"%@%p", _method, _params];
    }

    GRKFlickrQuery * queryToAdd = nil;
    
    GRKQueryResultBlock queryHandlingBlock = ^(id query, id result) {
        
        if ( handlingBlock != nil ){
            
            id handledResult = handlingBlock(self, result, nil);
            
            if ( handledResult != nil ){
                [_results setObject:handledResult forKey:name];
            }
            
        }
        
        [_runningQueries removeObject:query];
        [self performNextQuery];
        
    };
    
    GRKErrorBlock errorBlock = ^(NSError *error) {
        
        if ( handlingBlock != nil ){
            
            id handledResult = handlingBlock(self, nil, error);
            
            if ( handledResult != nil ){
                [_results setObject:handledResult forKey:name];
            }
            
        }
        
        [_runningQueries removeObject:queryToAdd];
        [self performNextQuery];
        
    };
    
   queryToAdd = [GRKFlickrQuery queryWithMethod:_method andParams:_params withHandlingBlock:queryHandlingBlock andErrorBlock:errorBlock];
     
     
    [_queries addObject:queryToAdd];
    
    
}

-(void)performWithFinalBlock:(GRKQueryResultBlock)handlingBlock  {
    
    
    _finalHandlingBlock = [handlingBlock copy];
    
    [self performNextQuery];
    
}


-(void) performNextQuery {
    
    if ( [_runningQueries count] >= kMaximumSimultaneousQueriesForFlickrQueriesQueue ){
        return;
    }
    
    if ( [_queries count] == 0 ){

        // If all the running queries have finished
        if ( [_runningQueries count] == 0 ){
            
            // perform final blocks
            if ( _finalHandlingBlock != nil ){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _finalHandlingBlock(self, _results);
                });
                
                
            }
        }
        
        
        return;
    }
    
    GRKFlickrQuery * nextQueryToRun = [_queries objectAtIndex:0];
    [nextQueryToRun perform];
    
    [_runningQueries addObject:nextQueryToRun];
    [_queries removeObject:nextQueryToRun];
    
    [self performNextQuery];
    
}

-(void)cancel {
    
    _finalHandlingBlock = nil;
    [_results removeAllObjects];
    
    [_runningQueries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
        if ( [obj respondsToSelector:@selector(cancel)] ){
            [obj cancel];
        }
        
    }];

    [_queries removeAllObjects];
    [_runningQueries removeAllObjects];
    
     
}



@end
