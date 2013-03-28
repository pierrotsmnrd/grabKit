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

#import "GRKTokenStoreTest.h"
#import "GRKTokenStore.h"


@implementation GRKTokenStoreTest


- (void)testDefinedTokenStore
{

    // For 2 different grabbers, store a string token and a NSDate token
    // ( Some lib requires to store NSDate, like Facebook with its expirationDate. )
    
    NSString * grabberTypeForService1 = @"grabberTypeForService1";
	NSString * grabberTypeForService2 = @"grabberTypeForService2";
    
    // key to store the string tokens, and the tokens
    NSString * stringTokenKey = @"stringTokenKey";
    NSString * stringTokenValueForService1 = @"stringTokenValue1";
    NSString * stringTokenValueForService2 = @"stringTokenValue2";    

    
	// key to store the date tokens, and the dates
    NSString * dateTokenKey = @"dateTokenKey";
    
    NSDate * now = [NSDate date];
    NSDate * dateTokenValueForService1 = [now dateByAddingTimeInterval:-60*60*2];
    NSDate * dateTokenValueForService2 = [now dateByAddingTimeInterval:-60*60];    
    
    
    
    // store the tokens and the dates
    [GRKTokenStore storeToken:stringTokenValueForService1 withName:stringTokenKey forGrabberType:grabberTypeForService1];
    [GRKTokenStore storeToken:stringTokenValueForService2 withName:stringTokenKey forGrabberType:grabberTypeForService2];    

    [GRKTokenStore storeToken:dateTokenValueForService1 withName:dateTokenKey forGrabberType:grabberTypeForService1];
    [GRKTokenStore storeToken:dateTokenValueForService2 withName:dateTokenKey forGrabberType:grabberTypeForService2];    

    
    // retrieve them
    NSString * supposedStringTokenValueForService1 = [GRKTokenStore tokenWithName:stringTokenKey forGrabberType:grabberTypeForService1];
    NSString * supposedStringTokenValueForService2 = [GRKTokenStore tokenWithName:stringTokenKey forGrabberType:grabberTypeForService2];    
    
    NSDate * supposedDateTokenValueForService1 = [GRKTokenStore tokenWithName:dateTokenKey forGrabberType:grabberTypeForService1];
    NSDate * supposedDateTokenValueForService2 = [GRKTokenStore tokenWithName:dateTokenKey forGrabberType:grabberTypeForService2];    
    
    STAssertEquals(supposedStringTokenValueForService1, stringTokenValueForService1, @"The default storeToken doesn't store (string) token properly ");
    STAssertEquals(supposedStringTokenValueForService2, stringTokenValueForService2, @"The default storeToken doesn't store (string) token properly ");
    
    STAssertEquals([supposedDateTokenValueForService1 compare:dateTokenValueForService1], NSOrderedSame, @"The default storeToken doesn't store (date)  token properly ");
    STAssertEquals([supposedDateTokenValueForService2 compare:dateTokenValueForService2], NSOrderedSame, @"The default storeToken doesn't store (date)  token properly ");
    
    
    
    // remove the tokens for service1, and ask for them again. 
    // test that the results are nil, and that the tokens for service2 remain unchanged
    
    [GRKTokenStore removeTokenWithName:stringTokenKey forGrabberType:grabberTypeForService1];
    [GRKTokenStore removeTokenWithName:dateTokenKey forGrabberType:grabberTypeForService1];    

    supposedStringTokenValueForService1 = [GRKTokenStore tokenWithName:stringTokenKey forGrabberType:grabberTypeForService1];
    supposedStringTokenValueForService2 = [GRKTokenStore tokenWithName:stringTokenKey forGrabberType:grabberTypeForService2];    
    supposedDateTokenValueForService1 = [GRKTokenStore tokenWithName:dateTokenKey forGrabberType:grabberTypeForService1];
    supposedDateTokenValueForService2 = [GRKTokenStore tokenWithName:dateTokenKey forGrabberType:grabberTypeForService2];    
    
    STAssertTrue(supposedStringTokenValueForService1 == nil, @"The default storeToken doesn't remove (string) token properly ");
    STAssertEquals(supposedStringTokenValueForService2, stringTokenValueForService2, @"The default storeToken doesn't remove (string) token properly ");
    
    STAssertTrue(supposedDateTokenValueForService1 == nil, @"The default storeToken doesn't remove (date) token properly ");
    STAssertEquals([supposedDateTokenValueForService2 compare:dateTokenValueForService2], NSOrderedSame, @"The default storeToken doesn't remove (date) token properly ");
    
    
	
    
    
}

@end
