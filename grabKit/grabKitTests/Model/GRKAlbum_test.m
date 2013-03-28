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

#import "GRKAlbum_test.h"

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";


@implementation GRKAlbum_test

#pragma - Helpers

// source : http://stackoverflow.com/questions/2633801/generate-a-random-alphanumeric-string-in-cocoa
-(NSString *) randomStringWithLength: (int) len;
{
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
    }
    
    return randomString;
}



-(GRKPhoto*) randomPhoto;
{
    NSString * randomToken = [self randomStringWithLength:6];
    NSString * photoId = [NSString stringWithFormat:@"id_random%@", randomToken];
    NSString * photoName = [NSString stringWithFormat:@"name_random%@", randomToken];
    
    GRKPhoto * photo = [GRKPhoto photoWithId:photoId
                                   andCaption:nil 
                                   andName:photoName
                                 andImages:nil 
                                  andDates:nil];
    return photo;
}


-(GRKPhoto*) randomPhotoWithIdAndName:(NSString*)idAndName;
{

    GRKPhoto * photo = [GRKPhoto photoWithId:idAndName
                                   andCaption:nil 
                                   andName:idAndName
                                 andImages:nil 
                                  andDates:nil];
    return photo;
}



@end
