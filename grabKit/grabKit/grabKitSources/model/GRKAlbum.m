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

#import "GRKAlbum.h"

#import "NSIndexSet+pagination.h"
#import "NSMutableArray+setObjectAtPosition.h"

GRKAlbumDateProperty * const kGRKAlbumDatePropertyDateCreated = @"kGRKAlbumDatePropertyDateCreated"; 
GRKAlbumDateProperty * const kGRKAlbumDatePropertyDateUpdated = @"kGRKAlbumDatePropertyDateUpdated"; 


@implementation GRKAlbum

@synthesize albumId = _albumId;
@synthesize name = _name;
@synthesize count = _count; 
@synthesize coverPhoto = _coverPhoto;

#pragma mark -
#pragma Constructors


+(id) albumWithId:(NSString*)albumId andName:(NSString*)name andCount:(NSUInteger)count andDates:(NSDictionary*)dates;
{
 	GRKAlbum * album = [[GRKAlbum alloc] initWithId:albumId andName:name andCount:count andDates:dates];
    return album;
}

-(id) initWithId:(NSString*)albumId andName:(NSString*)name andCount:(NSUInteger)count andDates:(NSDictionary*)dates;
{
    if ((self = [super init]) != nil){
       
        _albumId = albumId ;
        _name = name;

        _count = count;

        _photos = [NSMutableDictionary dictionaryWithCapacity:_count];
		_photosIds = [NSMutableArray arrayWithCapacity:_count];
        
    	_dates = [NSMutableDictionary dictionaryWithDictionary:dates];

    } 
    
    return self;
}


#pragma mark -
#pragma photos setters

-(void) addPhoto:(GRKPhoto*)newPhoto atIndex:(NSUInteger)index;
{

	[_photosIds setObject:newPhoto.photoId atIndex:index fillWithObject:[NSNull null]];
	[_photos setObject:newPhoto forKey:newPhoto.photoId];
    
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



#pragma mark -
#pragma photos getters


// returns an array containing the GRKPhoto already loaded, and containing [NSNull null] for photos not loaded yet
// Objects in the returned array follow the order in which they have been added to the album
-(NSArray*) orderedPhotos;
{
    NSMutableArray * orderedPhotos = [NSMutableArray array];
    
    for ( id photoId in _photosIds ){
        
        // if the photo has not been loaded yet, i.e. if the id is NSNull ..
        if ( [photoId isKindOfClass:[NSNull class]] ){
            // ... then add a NSNull to the result
            [orderedPhotos addObject:[NSNull null]];
        } else {
            // else, add the photo
            [orderedPhotos addObject:[_photos objectForKey:photoId]];
        }
    }
        
    return [NSArray arrayWithArray:orderedPhotos];
}

// returns an array containing all the GRKPhoto already loaded.
// Objects in the returned array follow the order in which they have been added to the album
-(NSArray*) orderedPhotosWithoutBlanks;	
{
    NSMutableArray * orderedPhotos = [NSMutableArray array];
    
    for ( id photoId in _photosIds ){
        
        if ( ! [photoId isKindOfClass:[NSNull class]] ){
            [orderedPhotos addObject:[_photos objectForKey:photoId]];
        }
    }
    
    return [NSArray arrayWithArray:orderedPhotos];
}

// returns an array containing all the GRKPhoto already loaded, without specific order
-(NSArray*) photos;
{
	return [_photos allValues];    
    
}

// returns an array containing the GRKPhoto for the given page index, with the given number of photos per page. 
// Objects in the returned array follow the order in which they have been added to the album
// the returned array is filled with NSNull objects if some photos in the album has not been totally filled
-(NSArray*) photosAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;
{
    
    NSArray * photosIdsForThisPage = [self photosIdsAtPageIndex:pageIndex withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    NSArray * photosAtThisPage = [_photos objectsForKeys:photosIdsForThisPage notFoundMarker:[NSNull null]];
    
    return photosAtThisPage;
    
}

// returns an array containing the ids of the GRKPhoto for the given page number, with the given number of photos per page. 
// Objects in the returned array follow the order in which they have been added to the album
-(NSArray*) photosIdsAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;
{
    
    // first, check that we don't ask for photos ids out of the range of already grabbed photos.
    // If the first photo of the desired page is further than the last photo,
    // return an array filled with NSNull.
    if(  pageIndex*numberOfPhotosPerPage >= [_photosIds count] ){

        /*NSMutableArray * result = [NSMutableArray arrayWithCapacity:numberOfPhotosPerPage];
        while ([result count] < numberOfPhotosPerPage )
            [result addObject:[NSNull null]];
        
        return [NSArray arrayWithArray:result];*/
        return [NSArray array];
    }
    
    
    
    
    // create a NSIndexSet for the desired page (N photos starting at page PN)
    NSIndexSet * indexSetForThisPage = [NSIndexSet indexSetForPageIndex:pageIndex withNumberOfItemsPerPage:numberOfPhotosPerPage];
    
    
    // If the last photo of the desired page is further than the last photo, 
    // we have to change the indexSet to fit : first photo of the page -> last photo 
    // (because we use the method [NSArray objectsAtIndexes], which throws NSException for out of bounds indexes...)
    if ( pageIndex*numberOfPhotosPerPage + numberOfPhotosPerPage > [_photosIds count] ){
    
        NSUInteger correctedNumberOfPhotosPerPage = [_photosIds count] - pageIndex*numberOfPhotosPerPage;
        
        indexSetForThisPage = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(pageIndex*numberOfPhotosPerPage, correctedNumberOfPhotosPerPage)];
        
    }
    
	
    // Ask for the photos ids at these indexes
	NSMutableArray * keysForThisPage = nil;
    @try {
        keysForThisPage = [NSMutableArray arrayWithArray:[_photosIds objectsAtIndexes:indexSetForThisPage]];
    }
    @catch (NSException *exception) {

        keysForThisPage = [NSArray array];
        
        // method [NSArray objectsAtIndexes:] may throw a NSRangeException
		NSLog(@" error : %@", exception);
		return nil;
    }
    
    // If there are less keys for this page than what was asked, fill with NSNull.
    // This can happen when numberOfPhotosPerPage has been corrected 
    //while ( [keysForThisPage count] < numberOfPhotosPerPage ){
    //    [keysForThisPage addObject:[NSNull null]];
    //}
    
    
	return [NSArray arrayWithArray:keysForThisPage];    
}




#pragma mark -
#pragma dates setters and getters

-(void) addDate:(NSDate*)newDate forProperty:(GRKAlbumDateProperty *)dateProperty;
{
    [_dates setObject:newDate forKey:dateProperty];
}

-(NSDate *) dateForProperty:(GRKAlbumDateProperty *)dateProperty;
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
        if ( [dateKey isEqualToString:kGRKAlbumDatePropertyDateCreated])
            [datesDescription appendFormat:@"Created:%@", [_dates objectForKey:dateKey]];
        else if ( [dateKey isEqualToString:kGRKAlbumDatePropertyDateUpdated])
        	[datesDescription appendFormat:@"Updated:%@", [_dates objectForKey:dateKey]];
        
        if ( [[_dates allKeys] lastObject] != dateKey ){
            [datesDescription appendString:@","];
        }
    }

    [datesDescription appendString:@">"];

    return [NSString stringWithFormat:@"<%@: %p albumId:'%@' name:'%@' count:%d actual photos count:%d %@>", [self class], self, _albumId, _name, _count, [_photos count], datesDescription];
    
}

@end
