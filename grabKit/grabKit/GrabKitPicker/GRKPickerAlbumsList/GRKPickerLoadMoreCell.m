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
#import "GRKPickerLoadMoreCell.h"

@implementation GRKPickerLoadMoreCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    //[_activityIndicator stopAnimating];
    [self setToLoadMore];
    
}

-(IBAction)didTouchLoadMoreButton:(id)sender; {
    
    if ( self.delegate != nil && [delegate respondsToSelector:@selector(cellDidReceiveTouchOnLoadMoreButton:)] ){
        
        //[_activityIndicator startAnimating];
        [self.delegate cellDidReceiveTouchOnLoadMoreButton:self];
        
    }
    
}


-(void) updateButtonFrame {
    
    CGFloat W = self.frame.size.width;
    CGFloat w = MIN(_loadMoreButton.frame.size.width, W-10);
    
    CGFloat H = self.frame.size.height;
    CGFloat h = _loadMoreButton.frame.size.height;
    
    
    _loadMoreButton.frame = CGRectMake( (W-w)/2, (H-h)/2, w, h);

    
}

-(void)setToRetry {
    //[_activityIndicator stopAnimating];
    
    [_loadMoreButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_loadMoreButton setTitle:GRK_i18n(@"GRK_LOAD_MORE_CELL_ERROR_RETRY", @"An error occured. Please retry.") forState:UIControlStateNormal];
    [_loadMoreButton sizeToFit];
    
    [self updateButtonFrame];
    
}

-(void)setToLoadMore {
    // [_activityIndicator stopAnimating];
    
    [_loadMoreButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_loadMoreButton setTitle:GRK_i18n(@"GRK_LOAD_MORE_CELL_LOAD_MORE", @"Load more") forState:UIControlStateNormal];

    [_loadMoreButton sizeToFit];
    
    [self updateButtonFrame];
    
}


@end
