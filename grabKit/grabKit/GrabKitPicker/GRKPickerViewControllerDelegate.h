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
#import "GRKPhoto.h"

@class GRKPickerViewController;

/** Objects implementing the GRKPickerViewControllerDelegate protocol will be responsible for being notified of events happening in a GRKPickerViewController.
 */
@protocol GRKPickerViewControllerDelegate <NSObject>


@optional


/** This method is called when the user selects a photo in the picker
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker that had a photo selected
 @param photo the selected photo
*/
-(void)picker:(GRKPickerViewController*)picker didSelectPhoto:(GRKPhoto*)photo;



/** This method is called when the user deselects a photo in the picker
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker that had a photo deselected
 @param photo the deselected photo
 */
-(void)picker:(GRKPickerViewController*)picker didDeselectPhoto:(GRKPhoto*)photo;



/** This method is called when the user selects a photo in the picker. 
 
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]

 @return  If it returns YES, the picker will call the delegate method picker:didSelectPhoto: .
 If it returns NO, nothing happens : the photo is not selected, the method  picker:didSelectPhoto:  will not be called on the delegate
 
 If the delegate doesn't implement this method, the picker will consider it can select the photo.

 
 @param picker the picker that had a photo selected
 @param photo the selected photo
 */
-(BOOL)picker:(GRKPickerViewController*)picker shouldSelectPhoto:(GRKPhoto*)photo;



/** This method is called when the user deselects a photo in the picker

 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 @return  If it returns YES, the picker will call the delegate method picker:didDeselectPhoto: .
 If it returns NO, nothing happens : the photo is not deselected, the method picker:didDeselectPhoto: will not be called on the delegate
 
 If the delegate doesn't implement this method, the picker will consider it can deselect the photo.

 
 @param picker the picker that had a photo deselected
 @param photo the deselected photo
 */
-(BOOL)picker:(GRKPickerViewController*)picker shouldDeselectPhoto:(GRKPhoto*)photo;




/** This method is called when the user highlights a photo in the picker (i.e. when he makes a "touch down" it)
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 In this method implementation, you can push your own viewController if you need.
 
    CustomViewController * myController = [[CustomViewController alloc] initWithPhoto:photo];
    [[GRKPickerViewController sharedInstance] pushViewController:myController animated:YES];
 
 The viewController will be pushed BEFORE the image is selected, thus no call to the delegate method picker:didSelectPhoto: is made.
 

 @param picker the picker that had a photo highlighted
 @param photo the highlighted photo
 */
-(void)picker:(GRKPickerViewController*)picker didHighlightPhoto:(GRKPhoto*)photo;


/** This method is called when the user unhighlights a photo in the picker (i.e. when he removes his/her finger from it)
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 In this method implementation, you can push your own viewController if you need.
 
    CustomViewController * myController = [[CustomViewController alloc] initWithPhoto:photo];
    [[GRKPickerViewController sharedInstance] pushViewController:myController animated:YES];
 
 The viewController will be pushed after the image is selected (or deselected, according to its previous state), thus a call to the delegate method picker:didSelectPhoto: ( or picker:didDeselectPhoto: ) has been made.
 
 
 @param picker the picker that had a photo unhighlighted
 @param photo the unhighlighted photo
 */
-(void)picker:(GRKPickerViewController*)picker didUnhighlightPhoto:(GRKPhoto*)photo;


/** This method is called when the user did finish using the picker, i.e. closes the picker by touching "cancel" or "done".
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the dismissed picker
 @param selectedPhotos the selected photos, an array of GRKPhoto objects
 */
-(void)picker:(GRKPickerViewController*)picker didDismissWithSelectedPhotos:(NSArray*)selectedPhotos;



/** This method is called when the GRKPickerViewController is displayed, and is about to show the list of services.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the displayed picker
 */
-(void)pickerWillShowServicesList:(GRKPickerViewController*)picker;


/** This method is called when the GRKPickerViewController is displayed, and to show the list of services is shown.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the displayed picker
 */
-(void)pickerDidShowServicesList:(GRKPickerViewController*)picker;


/** This method is called when the GRKPickerViewController is about to show the albums for a given service, i.e. when the user did select a service.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker
 @param serviceName the name of the selected service ("Facebook", "Instagram" ...)
 */
-(void)picker:(GRKPickerViewController*)picker willShowAlbumsListForServiceName:(NSString *)serviceName;

/** This method is called when the GRKPickerViewController shows the albums for a given service, i.e. when the user did select a service.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker
 @param serviceName the name of the selected service ("Facebook", "Instagram" ...)
 */
-(void)picker:(GRKPickerViewController*)picker didShowAlbumsListForServiceName:(NSString *)serviceName;


/** This method is called when the GRKPickerViewController is about to show the photos for a given album, i.e. when the user did select an album.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker
 @param album the chosen album
 */
-(void)picker:(GRKPickerViewController*)picker willShowPhotosListForAlbum:(GRKAlbum *)album;


/** This method is called when the GRKPickerViewController shows the photos for a given album, i.e. when the user did select an album.
 @note remember the picker is a singleton available through the method +[GRKPickerViewController sharedInstance]
 
 @param picker the picker
 @param album the chosen album
 */
-(void)picker:(GRKPickerViewController*)picker didShowPhotosListForAlbum:(GRKAlbum *)album;


@end
