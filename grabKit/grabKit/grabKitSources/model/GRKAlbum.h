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
#import "GRKPhoto.h"


// constants for the dates of an album. see GRKAlbum.dates property for more details 
typedef NSString GRKAlbumDateProperty;

/** @constant GRKAlbum Constants Represent the date creation */
extern GRKAlbumDateProperty * const kGRKAlbumDatePropertyDateCreated;
/** @constant GRKAlbum Constants Represent the date when the album has been last updated */
extern GRKAlbumDateProperty * const kGRKAlbumDatePropertyDateUpdated;

/**
 A GRKAlbum object represent a photo album.
 
 It stores properties like the name of the album, its id (albumId), the total number of photos (count), album's photos and dates.
 
 A GRKAlbum contains zero or more GRKPhoto objects. It's the responsibility of a GRKServiceGrabber to fill the GRKAlbum with GRKPhoto objects.
 
 GRKAlbum allows you to access the photos by pages. For example, you can ask for the 4th page of photos, with 20 photos per page.
 
 Pages start at ***zero***.
 
 According to the method you use to access photos, the NSArray result can be filled with NSNull objects for missing (not yet loaded) photos.
  
 A GRKAlbum contains zero or more dates. These dates are stored in a NSDictionary indexed with two possible constants :
 
 - kGRKAlbumDatePropertyDateCreated : represents the date of the creation of the album.
 - kGRKAlbumDatePropertyDateUpdated : represents the date of last update of the album.
 
 You can access these dates using the method dates, or dateForProperty: .
 
 The dates stored in a GRKAlbum may vary according to the service : 
 
 
 Service	|	available dates	|	key						
 -----------|-------------------|-----------
 Facebook 	|	date created	|	kGRKAlbumDatePropertyDateCreated		
            |   date updated	|	kGRKAlbumDatePropertyDateUpdated	
 FlickR     |	date created	|	kGRKAlbumDatePropertyDateCreated		
            |   date updated	|	kGRKAlbumDatePropertyDateUpdated		
 Instagram	|	(none)          |   (none)
 Picasa		|	date updated	|	kGRKAlbumDatePropertyDateUpdated		
 Device		|	(none)          |   (none)
 
 However, there is no guarantee that the dates listed above are each time available.
 
 
*/
@interface GRKAlbum : NSObject {
    
    NSString * _albumId;

    NSString * _name;
    
    NSUInteger _count; 
    
    // Mutable array containing the ids of the Album's GRKPhoto, ordered according to the service
    NSMutableArray * _photosIds;
    
    // Mutable Dictionary of GRKPhoto, indexed by photoId
    NSMutableDictionary * _photos; 
    
    // Mutable Dictionary of NSDate, representing various dates for the Album (date of creation, date of the last update, ...). 
    NSMutableDictionary * _dates; 
   
    // Cover photo of the album. is nil when not loaded yet 
    GRKPhoto * _coverPhoto;
}


/** @name  Properties */

/** id of the album, according to the service. */ 
@property (nonatomic, readonly) NSString * albumId;

/** Name of the Album, as indicated by the service */ 
@property (nonatomic, readonly) NSString * name;


/** Total number of photos for this Album, as indicated by the service
 
 Services indicates how much photos an Album contains. This value is stored in this property.
 @warning Some services may indicate a **wrong** count, mainly because services cache data. Relying on this value is not safe. 
 You can use KVO to be notified of changes.
 */ 
@property (nonatomic, readonly) NSUInteger count;

/** Cover photo of the album 
 
 This property is nil as long as the cover photo has not been loaded.
 */
@property (nonatomic, strong) GRKPhoto * coverPhoto;

/** @name Creating a GRKAlbum */

/** Creates and returns a GRKAlbum object with the given parameters
*
* 
* 
* @param albumId string representing the id of the album, as indicated by the service. 
* @param name string representing the name of the album, as indicated by the service.
* @param count Total number of photos for this Album, as indicated by the service.
* @param dates NSDictionary of NSDate indexed by GRKAlbumDateProperty constants.
* @return an initialized GRKAlbum.
*/
+(id) albumWithId:(NSString*)albumId andName:(NSString*)name andCount:(NSUInteger)count andDates:(NSDictionary*)dates;


/** @name Initializing a GRKAlbum */

/** Returns a GRKAlbum object initialized with the given parameters. 
 * @param albumId string representing the id of the album, as indicated by the service. 
 * @param name string representing the name of the album, as indicated by the service.
 * @param count Total number of photos for this Album, as indicated by the service.
 * @param dates NSDictionary of NSDate indexed by GRKAlbumDateProperty constants. 
 * @return an initialized GRKAlbum.
 */
-(id) initWithId:(NSString*)albumId andName:(NSString*)name andCount:(NSUInteger)count andDates:(NSDictionary*)dates;


/** @name Setting photos */

/** Add a photo to the album, at the given index.
 
 @param newPhoto the GRKPhoto object to add
 @param index the index where to add the photo
 */
-(void) addPhoto:(GRKPhoto*)newPhoto atIndex:(NSUInteger)index;


/** Add an array of photo to the album, at the given page, with the given number of photos per page
 
 @param newPhotos the array of GRKPhoto objects to add
 @param pageIndex the index of the page where to add the new photos at
 @param numberOfPhotosPerPage the number of photos per page. We don't rely on newPhotos' size, because some grabbers can return a number of photo lower than what was expected, mainly when grabbing the end of an album.
 */
-(void) addPhotos:(NSArray *)newPhotos forPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;


/** @name Getting photos */

/** returns an array containing the GRKPhoto already loaded, and containing [NSNull null] for photos not loaded yet
 Objects in the returned array follow the order in which they have been added to the album
 
 @return an array containing GRKPhoto objects, or NSNull.
 */
-(NSArray*) orderedPhotos;	

/** returns an array containing the GRKPhoto already loaded
 Objects in the returned array follow the order in which they have been added to the album
 
 @return an array containing GRKPhoto objects.
 */
-(NSArray*) orderedPhotosWithoutBlanks;	

/** returns an array containing all the GRKPhoto already loaded, without specific order 
 
 */
-(NSArray*) photos; 

/** returns an array containing the GRKPhoto for the given page index, with the given number of photos per page. 
 Objects in the returned array follow the order in which they have been added to the album
 the returned array is filled with NSNull objects if some photos in the album has not been totally filled
 
 @param pageIndex index of the wanted page 
 @param numberOfPhotosPerPage number of photos per page.
 @return an array containing GRKPhoto objects.
*/
-(NSArray*) photosAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;

/** returns an array containing the ***ids*** of the GRKPhoto for the given page index, with the given number of photos per page. 
 Objects in the returned array follow the order in which they have been added to the album
 The result array is filled with NSNull at indexes of items not loaded yet.
 
 @param pageIndex index of the wanted page 
 @param numberOfPhotosPerPage number of photos per page.
 @return an array containing GRKPhoto objects. 
*/
-(NSArray*) photosIdsAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;



/** @name Setting Dates */

/**  Add a date to the album for the given property 
 @param newDate the date to add
 @param dateProperty to date property to set. @see GRKAlbumDateProperty
 */
-(void) addDate:(NSDate*)newDate forProperty:(GRKAlbumDateProperty*)dateProperty;

/** @name Getting Dates */

/**  Returns the date for the given property 
 @param dateProperty to date property to set. @see GRKAlbumDateProperty
 @return the date for the property, or nil if not found
 */
-(NSDate*) dateForProperty:(GRKAlbumDateProperty*)dateProperty;

/** Returns all the dates of the album in a NSDictionary
 @return a NSDictionary containing all the dates of the album
 */
-(NSDictionary*) dates;

@end
