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

#import <UIKit/UIKit.h>
#import "GRKServiceGrabber.h"


enum {
    GRKDemoAlbumsListStateInitial = 0,
    GRKDemoAlbumsListStateConnecting,
    GRKDemoAlbumsListStateConnected,
    GRKDemoAlbumsListStateGrabbing,
    GRKDemoAlbumsListStateAlbumsGrabbed,
    GRKDemoAlbumsListStateAllAlbumsGrabbed,
    GRKDemoAlbumsListStateError = 99
};
typedef NSUInteger GRKDemoAlbumsListState;


@interface GRKDemoAlbumsList : UITableViewController {


    GRKServiceGrabber * _grabber; // grabber used to show the list of albums
    
    NSString * _serviceName; // Name of the service, for UI only.
    
    NSMutableArray * _albums;        // array which will store the grabbed GRKAlbum objects 
    NSUInteger _lastLoadedPageIndex; // index of the last loaded page. initialized at 0
    
    BOOL allAlbumsGrabbed;            // Set at YES if all albums have been loaded
    
    GRKDemoAlbumsListState state; // state of the controller
}


-(id) initWithGrabber:(id)grabber andServiceName:(NSString *)serviceName;

@end
