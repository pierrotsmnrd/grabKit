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

#import "GRKPhoto.h"

NSString * const kGRKPhotoDatePropertyDateCreated = @"kGRKPhotoDatePropertyDateCreated"; 
NSString * const kGRKPhotoDatePropertyDateUpdated = @"kGRKPhotoDatePropertyDateUpdated"; 
NSString * const kGRKPhotoDatePropertyDateTaken = @"kGRKPhotoDatePropertyDateTaken"; 



@implementation GRKPhoto

@synthesize photoId = _photoId;
@synthesize name = _name;
@synthesize caption = _caption;
@synthesize images = _images;


-(id) initWithId:(NSString*)photoId andCaption:(NSString *)caption andName:(NSString *)name andImages:(NSArray *)images andDates:(NSDictionary*)dates;
{
    if ((self = [super init]) != nil){

        _photoId = photoId;
        _name = name;
        _caption = caption;
        _images = [[NSMutableArray alloc] initWithArray:images];
        _dates = [[NSMutableDictionary alloc] initWithDictionary:dates];
    }
    
    
    return self;
}

+(id) photoWithId:(NSString*)photoId andCaption:(NSString *)caption andName:(NSString *)name andImages:(NSArray *)images andDates:(NSDictionary*)dates;
{
    
    GRKPhoto * photo = [[GRKPhoto alloc] initWithId:photoId andCaption:caption andName:name andImages:images andDates:dates];
    
    return photo;
}

#pragma mark -
#pragma images setters and getters

-(void) addImage:(GRKImage*)newImage {
    [_images addObject:newImage];
}

-(void) addArrayOfImages:(NSArray*)newImages {
    [_images addObjectsFromArray:newImages];
}


-(NSArray*)images;
{
    // return an immutable NSArray containing the images
    return [NSArray arrayWithArray:_images];
    
}

-(NSArray*)imagesSortedByHeight;
{
    // Create a temporary NSMutableArray that will be sorted
    NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:self.images];
    
    // sort the temporary NSMutableArray
    [tmpArray sortUsingComparator:^(id image1, id image2){
        
        // If for some reasons the array contains other objects than GRKImage, let skip them
        if ( ! [image1 isKindOfClass:[GRKImage class]] || ! [image2 isKindOfClass:[GRKImage class]] ){
            return (NSComparisonResult)NSOrderedSame;
        }
        
        // compare heights of images and return a NSComparisonResult
        if (  ((GRKImage*)image1).height > ((GRKImage*)image2).height ){
              return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (  ((GRKImage*)image1).height < ((GRKImage*)image2).height ){
            return (NSComparisonResult)NSOrderedAscending;
        }    
        
        return (NSComparisonResult)NSOrderedSame;            
            
        
    }];
    
    // return a sorted NSArray
    return [NSArray arrayWithArray:tmpArray];
    
}

-(NSArray*)imagesSortedByWidth;
{
    // Create a temporary NSMutableArray that will be sorted
    NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:self.images];
    
    // sort the temporary NSMutableArray
    [tmpArray sortUsingComparator:^(id image1, id image2){
        
        // If for some reasons the array contains other objects than GRKImage, let skip them
        if ( ! [image1 isKindOfClass:[GRKImage class]] || ! [image2 isKindOfClass:[GRKImage class]] ){
            return (NSComparisonResult)NSOrderedSame;
        }
        
        // compare widths of images and return a NSComparisonResult
        if (  ((GRKImage*)image1).width > ((GRKImage*)image2).width ){
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (  ((GRKImage*)image1).width < ((GRKImage*)image2).width ){
            return (NSComparisonResult)NSOrderedAscending;
        }    
        
        return (NSComparisonResult)NSOrderedSame;            
        
        
    }];
    
    // return a sorted NSArray
    return [NSArray arrayWithArray:tmpArray];

    
}

-(GRKImage*)originalImage;
{
    __block GRKImage * result = nil;
	[_images indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
       
        
        // if we are parsing the original image, 
        if ( [obj isKindOfClass:[GRKImage class]] && [(GRKImage*)obj isOriginal] ){
            // stop the parsing and return YES
            *stop = YES;  
            result = obj;
            return YES;
        }
        return NO;
    }];
    
    return result;
}




#pragma mark -
#pragma dates setters and getters

-(void) addDate:(NSDate*)newDate forProperty:(GRKPhotoDateProperty *)dateProperty;
{
    [_dates setObject:newDate forKey:dateProperty];
}

-(NSDate *) dateForProperty:(GRKPhotoDateProperty *)dateProperty;
{
    return [_dates objectForKey:dateProperty];
}

-(NSDictionary *) dates;
{
    return [NSDictionary dictionaryWithDictionary:_dates];
}



-(NSString *)description;
{
    NSMutableString * datesDescription = [NSMutableString stringWithString:@"Dates:<"];
    for( NSString * dateKey in _dates ){
        if ( [dateKey isEqualToString:kGRKPhotoDatePropertyDateCreated])
            [datesDescription appendFormat:@"Created:%@", [_dates objectForKey:dateKey]];
        else if ( [dateKey isEqualToString:kGRKPhotoDatePropertyDateUpdated])
        	[datesDescription appendFormat:@"Updated:%@", [_dates objectForKey:dateKey]];
        else if ( [dateKey isEqualToString:kGRKPhotoDatePropertyDateTaken])
        	[datesDescription appendFormat:@"Taken:%@", [_dates objectForKey:dateKey]];
        
        if ( [[_dates allKeys] lastObject] != dateKey ){
            [datesDescription appendString:@","];
        }
    }
    
    [datesDescription appendString:@">"];
    
    NSUInteger indexForSubstringCaption = 15;
    
	if ( [_caption length] == 0 ) indexForSubstringCaption = 0;
    else if ([_caption length] < indexForSubstringCaption+1 ) indexForSubstringCaption = [_caption length] -1;

    
    return [NSString stringWithFormat:@"<%@: %p photoId:'%@' name:'%@' caption:'%@' actual images count:%d >", [self class], self, _photoId, _name, [_caption substringToIndex:indexForSubstringCaption], [_images count]];
    
}


@end
