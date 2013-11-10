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

#import "GRKPickerPhotosList.h"
#import "GRKPickerPhotosListThumbnail.h"
#import "GRKPickerThumbnailManager.h"
#import "GRKPickerViewController.h"
#import "GRKPickerViewController+privateMethods.h"


// How many photos the grabber can load at a time
NSUInteger kNumberOfPhotosPerPage = 32;

NSUInteger kCellWidth = 75;
NSUInteger kCellHeight = 75;

@interface GRKPickerPhotosList()
    -(void) setState:(GRKPickerPhotosListState)newState;
    -(void) loadPage:(NSUInteger)pageIndex;
    -(void) markPageIndexAsLoading:(NSUInteger)pageIndex;
    -(void) markPageIndexAsLoaded:(NSUInteger)pageIndex;
    -(GRKPhoto*) photoForCellAtIndexPath:(NSIndexPath*)indexPath;
@end

@implementation GRKPickerPhotosList

@synthesize album = _album;

-(void)dealloc{
    
    [_album removeObserver:self forKeyPath:@"count"];
}


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGrabber:(GRKServiceGrabber*)grabber  andAlbum:(GRKAlbum*)album{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self != nil ){
        
        _grabber = grabber;
        _album = album;

        _indexesOfLoadingPages = [NSMutableArray array];
        _indexesOfLoadedPages = [NSMutableArray array];
        _indexesOfPagesToLoad = [NSMutableArray array];
        
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTouchDoneButton)];
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didTouchDoneButton)];
        

        // Sometimes, the grabbers return an erroneous number of photos for a given album.
        // This bug can be related to cache, to privacy settings, etc ...
        // But the datasource of the collectionView relies on the property _album.count to return the number of items.
        // SO this is why we need to observe the count property : if it's updated, then we need to reload the collectionView.
        [_album addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
        _needToReloadDataBecauseAlbumCountChanged = NO;
        
        [self setState:GRKPickerPhotosListStateInitial];
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(kCellWidth, kCellHeight)];
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:4.0f];
    [flowLayout setSectionInset:UIEdgeInsetsMake(4, 4, 4, 4)];

    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    
    // set multipleSelection according to configuration of [GRKPickerViewController sharedInstance]
    _collectionView.allowsSelection = [GRKPickerViewController sharedInstance].allowsSelection;
    _collectionView.allowsMultipleSelection = [GRKPickerViewController sharedInstance].allowsMultipleSelection;
   
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_collectionView registerClass:[GRKPickerPhotosListThumbnail class] forCellWithReuseIdentifier:@"pickerPhotosCell"];



    // If the navigation bar is translucent, it'll recover the top part of the tableView
    // Let's add some inset to the tableView to avoid this
    // Nevertheless, we don't need to do it when the picker is in a popover, because the navigationBar is not visible
    if ( ! [[GRKPickerViewController sharedInstance] isPresentedInPopover] && self.navigationController.navigationBar.translucent ){
        
        _collectionView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);

    }
    

    [self.view addSubview:_collectionView];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = _album.name;
    
    [self updateRightBarButtonItem];

}

-(void) loadPage:(NSUInteger)pageIndex; {
    
    if ( [_indexesOfLoadingPages containsObject:[NSNumber numberWithInt:pageIndex]] )
        return;
    
    if ( [_indexesOfLoadedPages containsObject:[NSNumber numberWithInt:pageIndex]] )
        return;

    
    // if the grabber can't load the pages discontinuously, let's check if the previous page has been loaded, or not.
    if ( ! _grabber.canLoadPhotosPagesDiscontinuously && pageIndex > 0){
        
        
        // If the previous page has not been loaded,
        if ( ! [_indexesOfLoadedPages containsObject:[NSNumber numberWithInt:pageIndex-1]] ) {
            
            
                // mark pageIndex to load
                [self markPageIndexToLoad:pageIndex];
            
                // load previous page
                [self loadPage:pageIndex-1];
            
            return;
            
        }
    }
    
    
    
    [self markPageIndexAsLoading:pageIndex];
        
    [_grabber fillAlbum:_album
  withPhotosAtPageIndex:pageIndex
withNumberOfPhotosPerPage:kNumberOfPhotosPerPage
       andCompleteBlock:^(NSArray *results) {
           

           [self markPageIndexAsLoaded:pageIndex];
           
           // If the grabber returned less photos than expected, we can consider that all photos have been grabbed.
           if ( [results count] < kNumberOfPhotosPerPage ){
               [self setState:GRKPickerPhotosListStateAllPhotosGrabbed];
               
           } else {
               [self setState:GRKPickerPhotosListStatePhotosGrabbed];
               
           }
           
           
           // if we must reload the whole collectionView because the property album.count changed
           if ( _needToReloadDataBecauseAlbumCountChanged ){

               _needToReloadDataBecauseAlbumCountChanged = NO;

               
               // First, keep the indexPaths of the selected items
               NSArray * selectedItems = [_collectionView indexPathsForSelectedItems];
               
               // Then, reload the collectionView
               [_collectionView reloadData];

               // Then, set the selected items again
               for ( NSIndexPath * indexPathOfSelectedItem in selectedItems ){
                   [_collectionView selectItemAtIndexPath:indexPathOfSelectedItem animated:NO scrollPosition:UICollectionViewScrollPositionNone];
               }

               
           } else {
           
               // Else, only reload items for the given indexPaths (not the whole collectionView)
               
               NSMutableArray * indexPathsToReload = [NSMutableArray array];
           
               for ( int i = (pageIndex * kNumberOfPhotosPerPage);
                    i <= (pageIndex+1) * kNumberOfPhotosPerPage -1 && i < _album.count - 1;
                    i++ ){
           
                   [indexPathsToReload addObject:[NSIndexPath indexPathForItem:i inSection:0]];
           
               }
           
               [_collectionView reloadItemsAtIndexPaths:indexPathsToReload];
           
           }
           
           // if there are other pages to load, load the first one
            if( [_indexesOfPagesToLoad count] > 0 ){
                
                [self loadPage:[[_indexesOfPagesToLoad objectAtIndex:0] intValue]];
                
            }
         
           
       } andErrorBlock:^(NSError *error) {
           NSLog(@" error for page %d : %@", pageIndex,  error);
           
           [_indexesOfLoadingPages removeObject:[NSNumber numberWithInt:pageIndex]];
           [self setState:GRKPickerPhotosListStateGrabbingFailed];
           
       }];
    
}

-(void) updateRightBarButtonItem {
    
    // Update the right bar button from "cancel" to "done" or vice-versa, if needed, according to the count of selected photos
    
    if ( [[[GRKPickerViewController sharedInstance] selectedPhotos] count] > 0 &&
         (self.navigationItem.rightBarButtonItem == _cancelButton || self.navigationItem.rightBarButtonItem == nil ) ){
        
        self.navigationItem.rightBarButtonItem = _doneButton;
        
        
    } else if ( [[[GRKPickerViewController sharedInstance] selectedPhotos] count] == 0 &&
         (self.navigationItem.rightBarButtonItem == _doneButton || self.navigationItem.rightBarButtonItem == nil ) ){
        
        self.navigationItem.rightBarButtonItem = _cancelButton;
        
    }
    
}

-(void) didTouchDoneButton {

    [[GRKPickerViewController sharedInstance] dismiss];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // stop all operations of the grabber
    [_grabber cancelAll];
    
    // stop all loads of thumbnails
    [[GRKPickerThumbnailManager sharedInstance] removeAllURLsOfThumbnailsToDownload];
    [[GRKPickerThumbnailManager sharedInstance] cancelAllConnections];
    
    // Reset the operations count.
    // If the view disappears while something is loading (i.e. after an INCREASE_OPERATIONS_COUNT),
    //  the corresponding DECREASE_OPERATIONS_COUNT is not called, and the activity indicator remains spinning...
    RESET_OPERATIONS_COUNT
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ( interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation) );
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ( [keyPath isEqualToString:@"count"] && object == _album ){
        
        _needToReloadDataBecauseAlbumCountChanged = YES;
        
    }
    
}


-(void) setState:(GRKPickerPhotosListState)newState {
 
 state = newState;
 
 switch (newState) {

     case GRKPickerPhotosListStateInitial:{
         
         
         
     }
     break;
         
     case GRKPickerPhotosListStateGrabbing:{
         
         INCREASE_OPERATIONS_COUNT
         
     }
     break;
         
     // When some photos are grabbed, reload the collectionView
     case GRKPickerPhotosListStateAllPhotosGrabbed:
     case GRKPickerPhotosListStatePhotosGrabbed:{

         DECREASE_OPERATIONS_COUNT
         
     }
     break;            
 
        
     case GRKPickerPhotosListStateGrabbingFailed:
         
         DECREASE_OPERATIONS_COUNT
         
         break;
         
     
     default:
         break;
 }
 
 
}

-(void) markPageIndexAsLoading:(NSUInteger)pageIndex;{
    
    [self setState:GRKPickerPhotosListStateGrabbing];
    
    if ( [_indexesOfLoadingPages indexOfObject:[NSNumber numberWithInt:pageIndex]] == NSNotFound ){

        [_indexesOfLoadingPages addObject:[NSNumber numberWithInt:pageIndex]];
        //NSLog(@" page %d marked as LOADING", pageIndex);
    }
    
    [_indexesOfPagesToLoad removeObject:[NSNumber numberWithInt:pageIndex]];
    
}

-(void) markPageIndexAsLoaded:(NSUInteger)pageIndex;{
    
    //NSLog(@" page %d marked as LOADED", pageIndex);
    
    [_indexesOfLoadedPages addObject:[NSNumber numberWithInt:pageIndex]];
    [_indexesOfLoadingPages removeObject:[NSNumber numberWithInt:pageIndex]];
    [_indexesOfPagesToLoad removeObject:[NSNumber numberWithInt:pageIndex]];
}


-(void) markPageIndexToLoad:(NSUInteger)pageIndex;{
    
    if ( [_indexesOfPagesToLoad indexOfObject:[NSNumber numberWithInt:pageIndex]] == NSNotFound ){
        [_indexesOfPagesToLoad addObject:[NSNumber numberWithInt:pageIndex]];
        
        //NSLog(@" page %d marked as TO LOAD", pageIndex);
    }
}
    



#pragma mark - Helpers


-(GRKPhoto*) photoForCellAtIndexPath:(NSIndexPath*)indexPath {
    
    /*
     As there is only one section in the collectionView, we can rely on the indexPath.row value without further calculations
    */
    NSArray * photos = [_album photosAtPageIndex:indexPath.row withNumberOfPhotosPerPage:1];
    if ( [photos count] > 0 ){
        
        id expectedPhoto = [photos objectAtIndex:0];
        if ( expectedPhoto == [NSNull null] ){
            return nil;
        }
        
        return expectedPhoto;
        
    } else return nil;
    
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
 
    return _album.count;
    
}

-(void) prepareCell:(GRKPickerPhotosListThumbnail *)cell fromCollectionView:(UICollectionView*)collectionView atIndexPath:(NSIndexPath*)indexPath withPhoto:(GRKPhoto*)photo  {
    
        NSURL * thumbnailURL = nil;
        
        for( GRKImage * image in [photo imagesSortedByHeight] ){
            
            // If the imageView for thumbnails is 75px wide, we need images with both dimensions greater or equal to 2*75px, for a perfect result on retina displays
            if ( image.width >= kCellWidth*2 && image.height >= kCellHeight*2 ) {
                
                thumbnailURL = image.URL;
                
                // Once we have found the first image bigger than the thumbnail, break the loop
                break;
            }
        }
        
        // Try to retreive the thumbnail from the cache first ...
        UIImage * cachedThumbnail = [[GRKPickerThumbnailManager sharedInstance] cachedThumbnailForURL:thumbnailURL andSize:CGSizeMake(150, 150)];

        if ( cachedThumbnail == nil ) {
            
            // If it hasn't been downloaded yet, let's do it
            [[GRKPickerThumbnailManager sharedInstance] downloadThumbnailAtURL:thumbnailURL
                                                             forThumbnailSize:CGSizeMake(150, 150)
                                                            withCompleteBlock:^( UIImage *image, BOOL retrievedFromCache ) {
                                                                
                                                                if ( image != nil ){
                                                                    
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        
                                                                        /* do not do that :
                                                                         [cell updateThumbnailWithImage:image animated:NO];
                                                                         
                                                                         This block is performed asynchronously.
                                                                         During the download of the image, the given cell may have been dequeued and reused, so we would be updating the wrong cell.
                                                                         Do this instead :
                                                                         */
                                                                        
                                                                        GRKPickerPhotosListThumbnail * cellToUpdate = (GRKPickerPhotosListThumbnail *)[collectionView cellForItemAtIndexPath:indexPath];
                                                                        [cellToUpdate updateThumbnailWithImage:image animated: ! retrievedFromCache ];
                                                                        
                                                                    });
                                                                    
                                                                }
                                                                
                                                                
                                                            } andErrorBlock:^(NSError *error) {
                                                                
                                                                // nothing to do, fail silently
                                                                
                                                            }];
            
            
        }else {
            
            // else, just update it
            [cell updateThumbnailWithImage:cachedThumbnail animated:NO];
        }
    
       

    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GRKPickerPhotosListThumbnail * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pickerPhotosCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    
    GRKPhoto * photo = [self photoForCellAtIndexPath:indexPath];
    if ( photo != nil ) {
        
        [self prepareCell:cell fromCollectionView:collectionView atIndexPath:indexPath withPhoto:photo];
        
        if ( ! cell.selected && [[[GRKPickerViewController sharedInstance] selectedPhotosIds] containsObject:photo.photoId]) {
            //[collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            cell.selected = YES;
        }
        
        
    } else {
        
        int pageOfThisCell = ceil( indexPath.row / kNumberOfPhotosPerPage );
            
        [self loadPage:pageOfThisCell];

        
    }
    
    
    return cell;
    
    
}


#pragma mark - UICollectionViewDelegate methods 


-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {

    
    GRKPhoto * highlightedPhoto = [self photoForCellAtIndexPath:indexPath];

    [[GRKPickerViewController sharedInstance] didHighlightPhoto:highlightedPhoto];
    
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GRKPhoto * unhighlightedPhoto = [self photoForCellAtIndexPath:indexPath];
    
    [[GRKPickerViewController sharedInstance] didUnhighlightPhoto:unhighlightedPhoto];
    

}


-(BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	GRKPhoto * selectedPhoto =  [self photoForCellAtIndexPath:indexPath];
    
    // Only allow selection of items for already-loaded photos.
    if ( selectedPhoto == nil ){
        return NO;
    }
    
    // if the photo is already loaded, then ask the Picker if it can select the photo or not
    return [[GRKPickerViewController sharedInstance] shouldSelectPhoto:selectedPhoto];
    
}



-(BOOL) collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
	GRKPhoto * deselectedPhoto =  [self photoForCellAtIndexPath:indexPath];
    
    // Ask the Picker if it can deselect the photo or not
    return [[GRKPickerViewController sharedInstance] shouldDeselectPhoto:deselectedPhoto];
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    GRKPhoto * selectedPhoto = [self photoForCellAtIndexPath:indexPath];
    
    /*
     In single-selection mode, when the user selects an already-selected item, the item must be deselected.
    */
    // In single-selection mode
    if ( collectionView.allowsSelection && ! collectionView.allowsMultipleSelection ){
        
        // If the selected item has already been selected
        if ( [[[GRKPickerViewController sharedInstance] selectedPhotosIds] containsObject:selectedPhoto.photoId] ){
            
            // it must be deselected
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [[GRKPickerViewController sharedInstance] didDeselectPhoto:selectedPhoto];
            [self updateRightBarButtonItem];
            return;
            
        }
        
    }
    
    [[GRKPickerViewController sharedInstance] didSelectPhoto:selectedPhoto];
    
    [self updateRightBarButtonItem];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GRKPhoto * selectedPhoto = [self photoForCellAtIndexPath:indexPath];

//    if ( [[GRKPickerViewController sharedInstance] shouldDeselectPhoto:selectedPhoto] ){

        [[GRKPickerViewController sharedInstance] didDeselectPhoto:selectedPhoto];
        [self updateRightBarButtonItem];
        
//    }
    
    
}



@end
