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
#import "GRKAlbum.h"


enum {
    GRKPickerPhotosListStateInitial = 0,
    
    GRKPickerPhotosListStateConnecting,
    GRKPickerPhotosListStateConnected,
    
    GRKPickerPhotosListStateGrabbing,
    GRKPickerPhotosListStatePhotosGrabbed,
    GRKPickerPhotosListStateAllPhotosGrabbed,
    GRKPickerPhotosListStateGrabbingFailed,
    
    GRKPickerPhotosListStateError = 99
};
typedef NSUInteger GRKPickerPhotosListState;



/* This class is not meant to be used as-is by third-party developers. The comments are here just for eventual needs of customisation .
 
 This class represents and displays a collection of photos for the given album.
 
 All the UI updates are made using the setState: method.
 
 It features several UI elements :
 
 _ a UICollectionView
 
 _ Two UIBarButtonItem, a "Done" and a "Cancel" one, according to the selection of the user.
 
 
 */
@interface GRKPickerPhotosList : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate > {
    
    UICollectionView * _collectionView;

    UIBarButtonItem * _cancelButton;
    UIBarButtonItem * _doneButton;
    
    
    GRKServiceGrabber * _grabber;
    GRKAlbum * _album;
    
    GRKPickerPhotosListState state;

    
    BOOL _needToReloadDataBecauseAlbumCountChanged; // at least, this is explicit 
    
    NSMutableArray * _indexesOfLoadingPages; // indexes of loaded pages.
    NSMutableArray * _indexesOfLoadedPages; // indexes of loaded pages.
    
    NSMutableArray * _indexesOfPagesToLoad; // Indexes of pages to load, for grabbers that can't load photos pages discontinuously
    
}

@property (nonatomic, readonly) GRKAlbum * album;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGrabber:(GRKServiceGrabber*)grabber andAlbum:(GRKAlbum*)album;

@end
