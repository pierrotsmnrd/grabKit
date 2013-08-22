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


#import "GRKPickerViewController.h"



/* This category implements private methods of GRKPickerViewController.

 These methods are meant to be called by some controllers only, and must NOT be called by your own code.
 
 */
@interface GRKPickerViewController (privateMethods)


/* Returns YES if the picker is presented in a popover, i.e. on iPad, or NO. */
-(BOOL)isPresentedInPopover;

/* Returns an array of the GRKPhoto objects selected by the user */
-(NSArray *) selectedPhotos;

/* Returns an array of NSString representing the photoIds of the GRKPhoto selected by the user */
-(NSArray *) selectedPhotosIds;


/* Called to notify the GRKPickerViewController that the user highlighted (touched down) a photo */
-(void)didHighlightPhoto:(GRKPhoto*)highlightedPhoto;


/* Called to notify the GRKPickerViewController that the user unhighlighted (touched up) a photo */
-(void)didUnhighlightPhoto:(GRKPhoto*)unhighlightedPhoto;

/* Calls the delegate to determine if the photo should be selected or not. */
-(BOOL) shouldSelectPhoto:(GRKPhoto*)deselectedPhoto;

/* Calls the delegate to determine if the photo should be deselected or not. */
-(BOOL) shouldDeselectPhoto:(GRKPhoto*)deselectedPhoto;


/* Called to notify the GRKPickerViewController that the user selected a photo */
-(void) didSelectPhoto:(GRKPhoto*)selectedPhoto;

/* Called to notify the GRKPickerViewController that the user deselected a photo */
-(void) didDeselectPhoto:(GRKPhoto*)deselectedPhoto;


/* Increases, decreases, or rests the internal counter of running operations, and updates the value of
 networkActivityIndicatorVisible
 */
-(void)increaseOperationsCount;
-(void)decreaseOperationsCount;
-(void)resetOperationsCount;


/* Called when the user touches the "Done"/"Cancel" button of the picker. this method is also responsible for calling some delegate methods. */
-(void)dismiss;

@end
