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


#import <Foundation/Foundation.h>
#import "GDataQuery.h"
#import "GRKPicasaQuery.h"
#import "GRKServiceGrabberProtocol.h"


/** GRKPicasaQueriesQueue is an object allowing to perform a queue of queries on Picasa, and to perform a block once all the queries have run.
 
 Picasa's webservices offers the feature of batch requests (which would be very helpflup and optimized to use here), 
 but as Google hire masturbators instead of qualified programmers :
 1) The documentation is unreadable.
 2) The class diagram is HIGHLY over-engineered and presents unexpected and surprising patterns. That prevents from trying to understand by reading the code.
 3) From what I've read in the "documentation", the batchs "feed" of the API are made first for delete/insert/alter operations, I did not find any way to perform several QUERY operations (...)
 
So, the only thing I expect from YOU, who are reading these comments, is that you prove me I'm wrong :
        Tell me how to perform several queries on a Picasa's batch feed.

The best example to perform a batch query would be for the queries of "fillCoverPhotoOfAlbum:" methods of the GRKPicasaGrabber, where we need something like "the first image in several sizes of several albums".
 
 */
@interface GRKPicasaQueriesQueue : NSObject {
    
    
    NSMutableArray * _queries;
    NSMutableArray * _runningQueries;
    
    NSMutableDictionary * _results;
    
    GRKQueryResultBlock _finalHandlingBlock;

    
}


-(void)addQuery:(GDataQuery*)query
       withName:(NSString*)name
andHandlingBlock:(GRKSubqueryResultBlock)handlingBlock;

-(void)performWithFinalBlock:(GRKQueryResultBlock)handlingBlock;
-(void)cancel;


@end
