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

#import "GRKAlbum+modify.h"
#import "NSMutableArray+setObjectAtPosition.h"
#import "GRKPhoto+modify.h"

@implementation GRKAlbum (Modify)

#pragma mark -
#pragma photos setters

-(void) addPhoto:(GRKPhoto*)newPhoto atIndex:(NSUInteger)index;
{
    
	[_photosIds setObject:newPhoto.photoId atIndex:index fillWithObject:[NSNull null]];
	[_photos setObject:newPhoto forKey:newPhoto.photoId];
    
    newPhoto.album = self;
    
    // sometimes, some API returns a 'count' value lower than the actual number of photos. (happened with FlickR several times)
    if ( [_photos count] > _count ){
        
        [self willChangeValueForKey:@"count"];
        
        _count = [_photos count];
        
        [self didChangeValueForKey:@"count"];
    }
    
}

-(void) addPhotos:(NSArray *)newPhotos forPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;
{
    
    NSUInteger startIndex = pageIndex*numberOfPhotosPerPage;
    for ( GRKPhoto * newPhoto in newPhotos ){
        [self addPhoto:newPhoto atIndex:startIndex];
        startIndex++;
    }
    
    BOOL countDidChange = NO;
    
    // If we have added less photos that what was expected, then we can assume that the _count value is wrong.
    // let's update it.
    if ( [newPhotos count] < numberOfPhotosPerPage ){
        [self willChangeValueForKey:@"count"];
        
        
        // pierrotsmnrd  2013-03-19 : The following can work only if all the previous pages have been loaded,
        // i.e. if _photos already contains all the previous photos.
        // TODO : Rework this mechanism for more flexibility.
        _count = [_photos count];
        
        
        countDidChange = YES;
    }
    
    // sometimes, some API returns a 'count' value lower than the actual number of photos. (happened with FlickR several times)
    if ( [_photos count] > _count ) {
        
        if ( ! countDidChange ){
            [self willChangeValueForKey:@"count"];
        }
        _count = [_photos count];
        countDidChange = YES;
    }
    
    if (countDidChange ){
        
        [self didChangeValueForKey:@"count"];
    }
    
}


-(void)setCoverPhoto:(GRKPhoto*)coverPhoto; {
    
    _coverPhoto = coverPhoto;
    
}


#pragma mark -
#pragma dates setters

-(void) addDate:(NSDate*)newDate forProperty:(GRKAlbumDateProperty *)dateProperty;
{
    [_dates setObject:newDate forKey:dateProperty];
}



@end
