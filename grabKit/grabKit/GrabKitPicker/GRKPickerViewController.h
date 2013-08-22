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


#import <UIKit/UIKit.h>
#import "GRKPickerViewControllerDelegate.h"

#define INCREASE_OPERATIONS_COUNT [[GRKPickerViewController sharedInstance] increaseOperationsCount];
#define DECREASE_OPERATIONS_COUNT [[GRKPickerViewController sharedInstance] decreaseOperationsCount];
#define RESET_OPERATIONS_COUNT [[GRKPickerViewController sharedInstance] resetOperationsCount];

#define GRK_BUNDLE [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"GrabKitBundle" ofType:@"bundle"]]

#define GRK_i18n(key, default) NSLocalizedStringFromTableInBundle(key, @"GrabKitPicker", GRK_BUNDLE, default)


/** GRKPickerViewController is the main class you use to help your users pick their photos in social networks.
 
 It offers a singleton available through the method +[GRKPickerViewController sharedInstance].
 
 GRKPickerViewController features a delegate " pickerDelegate " with the protocol GRKPickerViewControllerDelegate.
 It helps you to be notified of each event generated by the user, like "The user selected Facebook", or "The user closed the picker with 3 images selected".

 
 You can configure the GRKPickerViewController through several options :
 
 * allowsSelection : If YES (the default), the user can select an image from the picker
 
 * allowsMultipleSelection : If YES, the user can select several images from the picker (default NO)
 
 * keepsSelection : If YES, when the user selects images and dismisses the picker, the images will still be selected when he uses the picker again.
 
 
 
 On iPhone, you can simply present the GKRPickerViewController from your own view controller using :
 
        GRKPickerViewController * grabkitPickerViewController = [GRKPickerViewController sharedInstance];
 
        [self presentViewController:grabkitPickerViewController animated:YES completion:^{

        }];
 
 
 On iPad, to present a fully functionnal picker to your user, use the method -[GRKPickerViewController presentInPopoverFromBarButtonItem:permittedArrowDirections:animated:].

        GRKPickerViewController * grabkitPickerViewController = [GRKPickerViewController sharedInstance];
        
        [grabkitPickerViewController presentInPopoverFromBarButtonItem:aBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
 

 
 @warning Do NOT build your own UIPopoverController to present the GRKPickerViewController within. GRKPickerViewController handles it for you, for technical reasons and a better user experience.
 
 
 
*/
@interface GRKPickerViewController : UINavigationController<UINavigationControllerDelegate> {
    
    BOOL __allowsSelection;
    
    BOOL __allowsMultipleSelection;
    
    BOOL __keepsSelection;
    
    UIPopoverController * _pickerPresentingPopover;
 
    __weak id<GRKPickerViewControllerDelegate> _pickerDelegate;
    
    // Selected photos, GRKPhoto objects
    NSMutableDictionary * _selectedPhotos;

    // Internal counter of running operations. operations can be simple queries or bigger tasks ;
    NSUInteger runningOperations;
    
}

@property (nonatomic, weak) id<GRKPickerViewControllerDelegate> pickerDelegate;


/** A Boolean value that indicates whether users can select an item in the list of photos (default YES)
 Changing the value of this property once the list of photos is displayed has no effect.
 */
@property (nonatomic ) BOOL allowsSelection;


/** A Boolean value that determines whether users can select more than one item in the list of photos (default NO)
  Changing the value of this property once the list of photos is displayed has no effect.
 */
@property (nonatomic ) BOOL allowsMultipleSelection;

/** A Boolean value that determines if the controller must keep the selection (YES), or clear it each time the controller is dismissed (NO, the default)
*/
@property (nonatomic ) BOOL keepsSelection;


/** returns the singleton of GRKPickerViewController */
+(GRKPickerViewController *) sharedInstance;

/** This methods builds a UIPopoverViewController and displays the GRKPickerViewController within. 

 
 @warning For technical reasons leading to a better user experience, you must use this method on iPad, instead of building your own UIPopoverViewController.
 
 @param item The bar button item on which to anchor the popover
 @param arrowDirections The arrow directions the popover is permitted to use
 @param animated Specify YES to animate the presentation of the popover or NO to display it immediately.
 
 @see [UIPopoverController presentPopoverFromBarButtonItem:permittedArrowDirections:animated:]
 
 */
-(void)presentInPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;


/** This methods builds a UIPopoverViewController and displays the GRKPickerViewController within.
 
 
 @warning For technical reasons leading to a better user experience, you must use this method on iPad, instead of building your own UIPopoverViewController.
 
 @param rect The rectangle in view at which to anchor the popover window.
 @param view The view containing the anchor rectangle for the popover.
 @param arrowDirections The arrow directions the popover is permitted to use
 @param animated Specify YES to animate the presentation of the popover or NO to display it immediately.
 
 @see [UIPopoverController presentPopoverFromBarButtonItem:permittedArrowDirections:animated:]
 
 */
-(void)presentInPopoverFromRect:(CGRect)rect inView:(UIView*)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;



@end
