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
#import "GRKServiceGrabber.h"
#import "GRKPickerCurrentUserView.h"
#import "GRKPickerLoadMoreCell.h"


enum {
    GRKPickerAlbumsListStateInitial = 0,
    
    GRKPickerAlbumsListStateNeedToConnect,
    GRKPickerAlbumsListStateConnecting,
    GRKPickerAlbumsListStateConnected,
    GRKPickerAlbumsListStateDidNotConnect,
    GRKPickerAlbumsListStateConnectionFailed,
    
    GRKPickerAlbumsListStateGrabbing,
    GRKPickerAlbumsListStateAlbumsGrabbed,
    GRKPickerAlbumsListStateAllAlbumsGrabbed,
    GRKPickerAlbumsListStateGrabbingFailed,
    
    GRKPickerAlbumsListStateDisconnecting,
    GRKPickerAlbumsListStateDisconnected,
    
    GRKPickerAlbumsListStateError = 99
};
typedef NSUInteger GRKPickerAlbumsListState;


/* This class is not meant to be used as-is by third-party developers. The comments are here just for eventual needs of customisation .
 
 This class represents and displays a list of albums (UITableView) for the given service and grabber.
 
 All the UI updates are made using the setState: method.
 
 It features several UI elements :
 
    _ a UITableView
 
    _ a headerView, to display the name and profile picture of the user, and a logout button. This view is used as headerView of the UITableView.
 
    _ a footer, to display a "load more" button or a message when all the albums are loaded. This view is used as footerView of the UITableView
 
    _   _needToConnectView, a view to let the user login, and display an error message if it fails.
 
 */
@interface GRKPickerAlbumsList : UIViewController <UITableViewDataSource, UITableViewDelegate, GRKPickerCurrentUserViewDelegate, GRKPickerLoadMoreCellDelegate> {

    IBOutlet UITableView * _tableView;
    GRKPickerCurrentUserView * _headerView;
    UIView * _footer;
    
    IBOutlet UIView * _needToConnectView;
    IBOutlet UILabel * _needToConnectLabel;
    IBOutlet UIButton * _connectButton;
    
    GRKServiceGrabber * _grabber; // grabber used to show the list of albums
    
    NSString * _serviceName; // Name of the service, for UI only.
    
    NSMutableArray * _albums;        // array which will store the grabbed GRKAlbum objects 
    NSUInteger _lastLoadedPageIndex; // index of the last loaded page. initialized at 0
    
    BOOL allAlbumsGrabbed;            // Set at YES if all albums have been loaded
    
    GRKPickerAlbumsListState state; // state of the controller
}

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, readonly) NSString * serviceName;

-(id) initWithGrabber:(id)grabber andServiceName:(NSString *)serviceName;

@end
