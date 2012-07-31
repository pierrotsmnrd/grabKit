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

#import "GRKDemoPhotosList.h"
#import "GRKDemoPhotosListCell.h"
#import "GRKDemoImagesDownloader.h"

NSUInteger kNumberOfRowsPerSection = 7;
NSUInteger kNumberOfPhotosPerCell = 4;
NSUInteger kNumberOfPhotosPerPage = 7 * 4; 

@interface GRKDemoPhotosList()
    -(NSArray*) photosForCellAtIndexPath:(NSIndexPath*)indexPath;
    -(void) fillAlbumWithMorePhotos;
    -(void) setState:(GRKDemoPhotosListState)newState;
@end

@implementation GRKDemoPhotosList

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGrabber:(GRKServiceGrabber*)grabber  andAlbum:(GRKAlbum*)album{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self != nil ){
        
        _grabber = grabber;     
        _album = album;
        _lastLoadedPageIndex = 0;
        _nextPageIndexToLoad = 0;
        
        [self setState:GRKDemoPhotosListStateInitial];
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

    self.tableView.rowHeight = 79.0;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    [self fillAlbumWithMorePhotos];
    
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
    [[GRKDemoImagesDownloader sharedInstance] removeAllURLsOfImagesToDownload];
    [[GRKDemoImagesDownloader sharedInstance] cancelAllConnections];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




-(void) setState:(GRKDemoPhotosListState)newState {
 
 state = newState;
 
 switch (newState) {
 
     // When some photos are grabbed, reload the tableView    
     case GRKDemoPhotosListStatePhotosGrabbed:{
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
         });
     }  
     break;            
 
     case GRKDemoPhotosListStateAllPhotosGrabbed:{
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }
     break;
 
     default:
         break;
 }
 
 
 }
 

#pragma mark - Helpers

-(NSArray*) photosForCellAtIndexPath:(NSIndexPath*)indexPath {
    
    NSUInteger rowIndex = indexPath.section * kNumberOfRowsPerSection + indexPath.row ; 
    
    NSMutableArray * photosAtIndexPath = [NSMutableArray array];
    [photosAtIndexPath addObjectsFromArray:[_album photosAtPageIndex:rowIndex withNumberOfPhotosPerPage:kNumberOfPhotosPerCell]];
    
    // let's remove some NSNull...
    for ( int i = 0; i < [photosAtIndexPath count]; i++ ){
        
        if ( [photosAtIndexPath  objectAtIndex:i] == [NSNull null] ){
            [photosAtIndexPath removeObjectAtIndex:i];
            i--;
        }
    }
    
    return [NSArray arrayWithArray:photosAtIndexPath];
}

-(void) fillAlbumWithMorePhotos {
    
    NSUInteger pageToLoad = _nextPageIndexToLoad;
    
    [self setState:GRKDemoPhotosListStateGrabbing];
    
    [_grabber fillAlbum:_album
  withPhotosAtPageIndex:pageToLoad 
withNumberOfPhotosPerPage:kNumberOfPhotosPerPage
       andCompleteBlock:^(NSArray *results) {

          // _lastLoadedPageIndex++;
           _lastLoadedPageIndex = pageToLoad;
           
           if ( [results count] < kNumberOfPhotosPerPage )
               [self setState:GRKDemoPhotosListStateAllPhotosGrabbed];
           else [self setState:GRKDemoPhotosListStatePhotosGrabbed];
           
       } andErrorBlock:^(NSError *error) {
           NSLog(@" error for page %d : %@", pageToLoad,  error);
       }];
    
    _nextPageIndexToLoad++;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger res = _lastLoadedPageIndex+1;
    if ( state != GRKDemoPhotosListStateAllPhotosGrabbed ) {
        res ++;
    }
    
    return res;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [NSString stringWithFormat:@"Page %d", section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSUInteger res = 0;
    
    if ( state == GRKDemoPhotosListStateAllPhotosGrabbed && section == _lastLoadedPageIndex ) {
        
        NSUInteger photosCount = [_album count];
        
        // Number of cells with kNumberOfPhotosPerCell photos 
        NSUInteger numberOfCompleteCell = (photosCount - section*kNumberOfRowsPerSection*kNumberOfPhotosPerCell) / kNumberOfPhotosPerCell;
        
        // The last cell can contain less than kNumberOfPhotosPerCell photos
        NSUInteger thereIsALastCellWithLessThenFourPhotos = (photosCount % kNumberOfPhotosPerCell)?1:0;
        
        // always add an extra cell
        res =  numberOfCompleteCell + thereIsALastCellWithLessThenFourPhotos  +1 ;
        
        
    } else if ( section > _lastLoadedPageIndex) {

        // extra cell
        res = 1;
        
    } else res = kNumberOfRowsPerSection;

    
    return res;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    // Extra Cell
    if ( indexPath.section > _lastLoadedPageIndex ){    

        static NSString *extraCellIdentifier = @"ExtraCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:extraCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:extraCellIdentifier];
        }
        
        cell.textLabel.text = @"load more";
        cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        

        
    } else {
        
        static NSString *photoCellIdentifier = @"photoCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GRKDemoPhotosListCell" owner:self options:nil] objectAtIndex:0];
        }

    
    }    
    
    // setting of the cell is done in method [tableView:willDisplayCell:forRowAtIndexPath:]
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // extra cell
    if ( [cell.reuseIdentifier isEqualToString:@"ExtraCell"] ){ 
    
        if ( state == GRKDemoPhotosListStateAllPhotosGrabbed ) {
            
            cell.textLabel.text = [NSString stringWithFormat:@" %d photos", [[_album photos] count] ];
            
        }else {
            cell.textLabel.text = [NSString stringWithFormat:@"Loading page %d", _lastLoadedPageIndex+1];
            [self fillAlbumWithMorePhotos];
        }

        
    } else  // Photo cell
    {
        NSArray * photosAtIndexPath = [self photosForCellAtIndexPath:indexPath];
        [(GRKDemoPhotosListCell*)cell setPhotos:photosAtIndexPath];

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
