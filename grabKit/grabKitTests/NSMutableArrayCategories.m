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
#import "NSMutableArrayCategories.h"

#import "NSMutableArray+setObjectAtPosition.h"

@implementation NSMutableArrayCategories

// All code under test must be linked into the Unit Test bundle

-(void)testNSMutableArraySetObjectAtPosition {
    
    NSMutableArray * testArray = [NSMutableArray arrayWithObjects: @"0", @"1", @"2", @"3",  @"4", nil];
    
    
    NSString * objectToAdd = @"9";
    
    [testArray setObject:objectToAdd atIndex:9 fillWithObject:[NSNull null]];
    
    STAssertEquals([testArray count],  (NSUInteger)10, @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't add the proper number of objects ");

    STAssertNoThrow([testArray objectAtIndex:9], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] seems to have NOT added the proper number of objects ");
    
    STAssertEquals(objectToAdd, [testArray objectAtIndex:9], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't set the proper object at the proper index");
    
    for ( int i = 5; i < 9; i++){
        
        STAssertEquals( [testArray objectAtIndex:i], [NSNull null], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't fill properly (object at rank %d is %@", i,[testArray objectAtIndex:i] );
    }
    
    NSString * anotherObjectToAdd = @"6";
    [testArray setObject:anotherObjectToAdd atIndex:6 fillWithObject:[NSNull null]];
    
    STAssertEquals([testArray count],  (NSUInteger)10, @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't add the proper number of objects ");
    
    STAssertNoThrow([testArray objectAtIndex:9], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] seems to have NOT added the proper number of objects ");

    STAssertEquals(anotherObjectToAdd, [testArray objectAtIndex:6], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't set the proper object at the proper index");
    
    STAssertEquals(objectToAdd, [testArray objectAtIndex:9], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't set the proper object at the proper index");
    
    
    int i = 5;
    STAssertEquals( [testArray objectAtIndex:i], [NSNull null], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't fill properly (object at rank %d is %@", i,[testArray objectAtIndex:i] );
    i = 7;
    STAssertEquals( [testArray objectAtIndex:i], [NSNull null], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't fill properly (object at rank %d is %@", i,[testArray objectAtIndex:i] );
    i = 8;
    STAssertEquals( [testArray objectAtIndex:i], [NSNull null], @"The category method [NSMutableArray setObject:atPosition:fillWithObject:] doesn't fill properly (object at rank %d is %@", i,[testArray objectAtIndex:i] );

    
}

@end
