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
#import "GRKImage.h"


// constants for the dates of a photo. see GRKPhoto.dates property for more details
typedef NSString GRKPhotoDateProperty;

// @constant GRKPhoto Constants Represent the date creation 
extern GRKPhotoDateProperty * const kGRKPhotoDatePropertyDateCreated;
// @constant GRKPhoto Constants Represent the date when the photo has been last updated 
extern GRKPhotoDateProperty * const kGRKPhotoDatePropertyDateUpdated;
// @constant GRKPhoto Constants Represent the date when the photo has been taken on the camera
extern GRKPhotoDateProperty * const kGRKPhotoDatePropertyDateTaken;




/**
 A GRKPhoto object represent a photo in an album.
 
 It stores properties like the name of the photo (e.g. "P10000042.JPG"), its caption (or title), the photo's images (versions of the photo) and dates.
 
 A GRKPhoto contains zero or more GRKImage objects. It's the responsibility of a GRKServiceGrabber to build the GRKPhoto with GRKImage objects.
 
 At least one GRKImage of a GRKPhoto is the original. you can access it by the method [GRKPhoto originalImage].
 
 A GRKPhoto contains zero or more dates. These dates are stored in a NSDictionary indexed with three possible constants :
 
 - kGRKPhotoDatePropertyDateCreated : represents the date of the creation of the photo.
 - kGRKPhotoDatePropertyDateUpdated : represents the date of last update of the photo.
 - kGRKPhotoDatePropertyDateTaken : represents the date when the photo was taken on the camera
 
 You can access these dates using the method dates, or dateForProperty: .
 
 The dates stored in a GRKPhoto may vary according to the service : 
 
 
 Service	|	available dates	|	key						
 -----------|-------------------|-----------
 Facebook 	|	date created	|	kGRKPhotoDatePropertyDateCreated		
            |   date updated	|	kGRKPhotoDatePropertyDateUpdated	
 FlickR     |	date created	|	kGRKPhotoDatePropertyDateCreated		
            |   date updated	|	kGRKPhotoDatePropertyDateUpdated		
            |   date taken      |   kGRKPhotoDatePropertyDateTaken
 Instagram	|	date created    |   kGRKPhotoDatePropertyDateCreated		
 Picasa		|	date taken      |	kGRKPhotoDatePropertyDateUpdated		
 Device		|	date taken      |   kGRKPhotoDatePropertyDateTaken
 
 However, there is no guarantee that the dates listed above are each time available.
 
 */
@interface GRKPhoto : NSObject {
    
    NSString * _photoId; // id of the image on the service 
    
    NSString * _name;    // name (or title) of the photo on the service
    
    NSString * _caption; // caption (i.e. description) of the photo on the service
    
    NSMutableArray * _images;   // array of GRKImage 
    
    NSMutableDictionary * _dates; // Dictionary of NSDate, representing various dates for the photo (date of creation, date of the last update, date when the photo was taken, ...). 
    
}


/** @name  Properties */

/** id of the photo, according to the service. */ 
@property (nonatomic, strong, readonly) NSString * photoId;
/** name of the photo, according to the service. 
 
 The name of the photo is the name of the file as uploaded on the service, for example "P10000042.JPG" or "my dog.jpg".
 
  @warning This property is ***not*** available on every services
 */ 
@property (nonatomic, strong, readonly) NSString * name;
/** Caption (or description) of the photo, according to the service.  */
@property (nonatomic, strong, readonly) NSString * caption;
/** NSArray of GRKImage objects, containing the different versions of the photo. */
@property (nonatomic, strong, readonly) NSArray * images;




/** @name Creating a GRKPhoto */

/** Creates and returns a GRKPhoto object with the given parameters
 *
 * 
 * @param photoId string representing the id of the photo, as indicated by the service. 
 * @param caption string representing the caption (or description) of the photo, as indicated by the service.
 * @param name string representing the name of the photo, as indicated by the service.
 * @param images NSArray containing all the images for the photo
 * @param dates NSDictionary of NSDate indexed by GRKPhotoDateProperty constants.
 * @return an initialized GRKPhoto.
 */
+(id) photoWithId:(NSString*)photoId andCaption:(NSString *)caption andName:(NSString *)name andImages:(NSArray *)images andDates:(NSDictionary*)dates;

/** Returns a GRKPhoto object initialized with the given parameters. 
 *
 * 
 * @param photoId string representing the id of the photo, as indicated by the service. 
 * @param caption string representing the caption (or description) of the photo, as indicated by the service.
 * @param name string representing the name of the photo, as indicated by the service.
 * @param images NSArray containing all the images for the photo
 * @param dates NSDictionary of NSDate indexed by GRKPhotoDateProperty constants.
 * @return an initialized GRKPhoto.
 */
-(id) initWithId:(NSString*)photoId andCaption:(NSString *)caption andName:(NSString *)name andImages:(NSArray *)images andDates:(NSDictionary*)dates;

/** @name Adding images */

/** add an image to the photo
 @param newImage the image to add
 */
-(void) addImage:(GRKImage*)newImage;

/** add an NSArray of GRKImage to the photo
 @param newImages the NSArray of images to add
 */
-(void) addArrayOfImages:(NSArray*)newImages;

/** @name images getters */

/** Get all the images
 @return an NSArray containing all the images
 */
-(NSArray*)images;

/** Get all the images sorted by ascending height
 @return an NSArray containing all the images, sorted by ascending height
 */
-(NSArray*)imagesSortedByHeight;

/** Get all the images sorted by ascending width
 @return an NSArray containing all the images, sorted by ascending width
 */
-(NSArray*)imagesSortedByWidth;

/** Get the original image of the GRKPhoto
 @return a GRKImage representing the original image of th ephoto
 */
-(GRKImage*)originalImage;



/** @name Setting Dates */

/**  Add a date to the album for the given property 
 @param newDate the date to add
 @param dateProperty to date property to set. @see GRKPhotoDateProperty
 */
-(void) addDate:(NSDate*)newDate forProperty:(GRKPhotoDateProperty*)dateProperty;





/** @name Getting Dates */

/**  Returns the date for the given property 
 @param dateProperty to date property to set. @see GRKPhotoDateProperty
 @return the date for the property, or nil if not found
 */
-(NSDate*) dateForProperty:(GRKPhotoDateProperty*)dateProperty;

/** Returns all the dates of the photo in a NSDictionary
 @return a NSDictionary containing all the dates of the photo
 */
-(NSDictionary*) dates;

@end
