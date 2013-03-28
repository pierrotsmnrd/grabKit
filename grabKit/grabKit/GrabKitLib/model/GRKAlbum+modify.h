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

#import "GRKAlbum.h"
#import "GRKPhoto.h"

/** This category groups methods to modify a GRKAlbum object.

*/
@interface GRKAlbum (Modify)


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


-(void)setCoverPhoto:(GRKPhoto*)coverPhoto;


/** @name Setting Dates */

/**  Add a date to the album for the given property
 @param newDate the date to add
 @param dateProperty to date property to set. @see GRKAlbumDateProperty
 */
-(void) addDate:(NSDate*)newDate forProperty:(GRKAlbumDateProperty*)dateProperty;





@end
