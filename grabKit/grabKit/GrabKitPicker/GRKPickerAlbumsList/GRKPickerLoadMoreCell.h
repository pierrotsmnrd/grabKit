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

@class GRKPickerLoadMoreCell;


/*  This protocol offers a method to notify a delegate that the user did touch the "load more" button. */
@protocol GRKPickerLoadMoreCellDelegate <NSObject>

@optional
-(void)cellDidReceiveTouchOnLoadMoreButton:(GRKPickerLoadMoreCell*)cell;

@end



/* This class is not meant to be used as-is by third-party developers. The comments are here just for eventual needs of customisation .
 
     This class is a subclass of UITableViewCell to display a "load more" button in the tableView of GRKPickerAlbumsList.
    
    The method setToRetry sets the button's label to "an error occured, please retry", according to the localization of the key GRK_LOAD_MORE_CELL_ERROR_RETRY.
 
    The method setToLoadMore sets the button's label to "Load More", according to the localization of the key GRK_LOAD_MORE_CELL_LOAD_MORE.
 
    These two methods both call updateButtonFrame to have a properly positioned button within the cell.
 
*/
@interface GRKPickerLoadMoreCell : UITableViewCell {
    
    
    IBOutlet UIButton * _loadMoreButton;
    IBOutlet UIActivityIndicatorView * _activityIndicator;
    __weak id<GRKPickerLoadMoreCellDelegate> delegate;
    
}

@property (nonatomic, weak) id<GRKPickerLoadMoreCellDelegate> delegate;

-(IBAction)didTouchLoadMoreButton:(id)sender;

-(void)setToRetry;
-(void)setToLoadMore;
-(void) updateButtonFrame;

@end
