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

#import <Foundation/Foundation.h>
#import "GRKServiceGrabberProtocol.h"
#import "GRKServiceQueryProtocol.h"


/** GRKInstagramQuery is an object conforming to GRKServiceQueryProtocol, used by a GRKInstagraGrabber, representing a single call to Instagram's webservices.
 */
@interface GRKInstagramQuery : NSObject <GRKServiceQueryProtocol> {
    

    NSURLConnection * cnx;
    NSMutableData * data;
    
    NSString * endpoint;
    NSMutableDictionary * params;
    
    GRKQueryResultBlock handlingBlock;
    GRKErrorBlock errorBlock;
	
}


-(id) initWithEndpoint:(NSString *)_endpoint 
			 withParams:(NSMutableDictionary *)_params
      withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
          andErrorBlock:(GRKErrorBlock)_errorBlock;


+(GRKInstagramQuery*) queryWithEndpoint:(NSString *)_endpoint 
                            withParams:(NSMutableDictionary *)_params
                     withHandlingBlock:(GRKQueryResultBlock)_handlingBlock
                         andErrorBlock:(GRKErrorBlock)_errorBlock;



@end
