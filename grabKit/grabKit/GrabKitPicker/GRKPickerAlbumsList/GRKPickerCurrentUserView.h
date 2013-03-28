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
#import "NVUIGradientButton.h"

@class GRKPickerCurrentUserView;

/*  This protocol offers a method to notify a delegate that the user did touch the "log out" button. */
@protocol GRKPickerCurrentUserViewDelegate
-(void)headerViewDidTouchLogoutButton:(GRKPickerCurrentUserView*)headerView;
@end


/* This class is not meant to be used as-is by third-party developers. The comments are here just for eventual needs of customisation .

 This class handles the display of a user logged in a service.
  It displays a UIImageView for the user's profile picture, a UILabel for the user's name, and a button to let the user log out.
 
 The interactions with the logout button are sent to this class' delegate.
 
 */
@interface GRKPickerCurrentUserView : UIView {
    
    IBOutlet UIImageView * _imageViewProfilePicture;
    
    IBOutlet UILabel * _labelUsername;
    
    IBOutlet NVUIGradientButton * _buttonLogout;

    __weak id<GRKPickerCurrentUserViewDelegate> _delegate;
    
    id gradient;
    
}

@property (nonatomic, weak) id<GRKPickerCurrentUserViewDelegate> delegate;

-(IBAction)didTouchLogoutButton:(id)sender;
-(void)showWithUsername:(NSString*)username andProfilePictureImage:(UIImage*)profileImage;


@end
