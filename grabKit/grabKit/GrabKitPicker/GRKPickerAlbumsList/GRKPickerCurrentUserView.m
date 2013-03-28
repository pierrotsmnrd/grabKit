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
#import "GRKPickerCurrentUserView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GRKPickerCurrentUserView

@synthesize delegate = _delegate;

-(id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if ( self ){
        _imageViewProfilePicture.alpha = .0;
        _labelUsername.alpha = .0;
        _buttonLogout.alpha = .0;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)didTouchLogoutButton:(id)sender{

    if ( _delegate != nil){
        [_delegate headerViewDidTouchLogoutButton:self];
    }
    
}

-(void)showWithUsername:(NSString*)username andProfilePictureImage:(UIImage*)profileImage {
    
    
    _imageViewProfilePicture.image = profileImage;
    _labelUsername.text = username;
    
    _buttonLogout.text = GRK_i18n(@"GRK_USER_VIEW_LOGOUT", @"Log out");
    _buttonLogout.titleLabel.font = [UIFont boldSystemFontOfSize:12.];
    
    // Let's update the frame of the button according to the size of the localized text
    CGFloat padding = 20; // 10 px on each side of the label of the button
    
    // Size of the label according to the font.
    CGSize buttonTextSize = [_buttonLogout.text sizeWithFont:_buttonLogout.titleLabel.font];
    
    // 314 is the max right-edge of the button.
    //  y and h are fixed
    _buttonLogout.frame = CGRectMake(314 - (buttonTextSize.width+padding),
                                     10,
                                     buttonTextSize.width+padding,
                                     30);
    
    _buttonLogout.style = NVUIGradientButtonStyleBlackTranslucent;
    _buttonLogout.cornerRadius = 6;
    
    _buttonLogout.textShadowColor = [UIColor blackColor];
    CGFloat tintComponent = 0.26;
    _buttonLogout.tintColor = [UIColor colorWithRed:tintComponent green:tintComponent blue:tintComponent alpha:1.f];
    _buttonLogout.borderColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.f];
    _buttonLogout.highlightedBorderColor = _buttonLogout.borderColor;
    
    CGFloat highlightTintComponent = 0.16;
    _buttonLogout.highlightedTintColor = [UIColor colorWithRed:highlightTintComponent
                                                         green:highlightTintComponent
                                                          blue:highlightTintComponent
                                                         alpha:1.f];
    

    
    
    
    if ( gradient == nil ){

        // build and add a gradient at the bottom the of the view
        CGFloat layerHeight = 3;
    
        gradient = [CAGradientLayer layer];
        ((CAGradientLayer*)gradient).frame = CGRectMake(0,
                                                        self.bounds.size.height - layerHeight,
                                                        self.frame.size.width,
                                                        layerHeight);

        ((CAGradientLayer*)gradient).colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
        [self.layer insertSublayer:gradient atIndex:0];
        
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        _imageViewProfilePicture.alpha = 1.0;
        _labelUsername.alpha = 1.0;
        _buttonLogout.alpha = 1.0;
    }];
    
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat layerHeight = 3;
    
    ((CAGradientLayer*)gradient).frame = CGRectMake(0,
                                                    self.bounds.size.height - layerHeight,
                                                    self.frame.size.width,
                                                    layerHeight);
    
}

@end
