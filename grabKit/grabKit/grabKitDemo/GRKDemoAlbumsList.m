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

#import "GRKDemoAlbumsList.h"
#import "GRKServiceGrabberConnectionProtocol.h"
#import "GRKDemoPhotosList.h"
#import "GRKDemoAlbumsListCell.h"

@interface GRKDemoAlbumsList()
    -(void)grabMoreAlbums;
    -(void)setState:(GRKDemoAlbumsListState)newState;
    -(void)addLogoutButton;
@end


NSUInteger kNumberOfAlbumsPerPage = 8;

@implementation GRKDemoAlbumsList

-(void) dealloc {
    
    for( GRKAlbum * album in _albums ){
        [album removeObserver:self forKeyPath:@"count"];
    }

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(id) initWithGrabber:(id)grabber andServiceName:(NSString *)serviceName{
    
    self = [super initWithNibName:@"GRKDemoAlbumsList" bundle:nil];
    if ( self ){
        
        _grabber = grabber;
        _serviceName = serviceName;
        _albums = [[NSMutableArray alloc] init];
        _lastLoadedPageIndex = 0;
        allAlbumsGrabbed = NO;
        [self setState:GRKDemoAlbumsListStateInitial];
    }
    
    
    return self;
}


-(void) setState:(GRKDemoAlbumsListState)newState {
    
    
    state = newState;
    
    switch (newState) {
            
        // When some albums are grabbed, reload the tableView    
        case GRKDemoAlbumsListStateAlbumsGrabbed:
            [self.tableView reloadData];
            break;            
        case GRKDemoAlbumsListStateAllAlbumsGrabbed:
            [self.tableView reloadData];
            break;
            
            
        default:
            break;
    }
    
    
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
}

-(void) addLogoutButton {
    
    if ( self.navigationItem.rightBarButtonItem == nil ){
        
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" 
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self action:@selector(logoutGrabberAndPopToRoot)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.title = _serviceName;
    
    if ( state != GRKDemoAlbumsListStateInitial ) return;
    


    // If the grabber needs to connect
    if ( [_grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)] ){
        
        [(id<GRKServiceGrabberConnectionProtocol>)_grabber isConnected:^(BOOL connected) {
            
            NSLog(@" grabber connected ? %d", connected);
            if ( ! connected ){
                
                
                NSString * connectMessage = [NSString stringWithFormat:@"The Demo App needs to open Safari to authentificate you on %@. ", _grabber.serviceName ];
                UIAlertView * grabberNeedToConnect = [[UIAlertView alloc] initWithTitle:@"Connection" 
                                                                                 message:connectMessage 
                                                                                delegate:self 
                                                                       cancelButtonTitle:@"Cancel" 
                                                                       otherButtonTitles:@"Ok", nil];

                [grabberNeedToConnect show];
                
            
            } else {

                dispatch_async(dispatch_get_main_queue(), ^(void){

                    // add the "log out" button
                    [self addLogoutButton];
                    
                    // and start grabbing albums
                    [self grabMoreAlbums];   

                });

                
            }
        }];
                
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            // start grabbing albums ( we don't need to add the "log out" button, as the grabber doesn't need to connect ...)
            [self grabMoreAlbums];   
            
        });

    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_grabber cancelAll];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSUInteger res = [_albums count];
    
    // If some albums have been grabbed, show an extra cell for "N albums - Load More"
    if ( state == GRKDemoAlbumsListStateAlbumsGrabbed ) res++;
    
    // If all albums have been grabbed, show an extra cell for "N Albums"
    if ( state == GRKDemoAlbumsListStateAllAlbumsGrabbed ) res++;
    
    
    return res;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    // Handle the extra cell
    if ( indexPath.row >= [_albums count] ){

        static NSString *CellIdentifier = @"ExtraCell";
    
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        if ( ! allAlbumsGrabbed ){ 
            cell.textLabel.text = [NSString stringWithFormat:@"%d Albums - Load More", [_albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%d Albums", [_albums count]];
            cell.textLabel.font = [UIFont fontWithName:@"System" size:8];
        }
        
    }else {
        
        static NSString *CellIdentifier = @"AlbumCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GRKDemoAlbumsListCell" owner:nil options:nil] objectAtIndex:0];
        }
        
        GRKAlbum * albumAtIndexPath = (GRKAlbum*)[_albums objectAtIndex:indexPath.row];

        
        [(GRKDemoAlbumsListCell*)cell setAlbum:albumAtIndexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        
    }

    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    // If the user touched the "load more" cell, and if there are still more albums to load
    if ( indexPath.row == [_albums count]  && ! allAlbumsGrabbed ){
        [self grabMoreAlbums];
    }else if ( indexPath.row <= [_albums count] -1 ) {
        
        GRKAlbum * albumAtIndexPath = [_albums objectAtIndex:indexPath.row];
        
        GRKDemoPhotosList * photosList = [[GRKDemoPhotosList alloc] initWithNibName:@"GRKDemoPhotosList" bundle:nil andGrabber:_grabber andAlbum:albumAtIndexPath];
        [self.navigationController pushViewController:photosList animated:YES];

        
    }

}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if ( buttonIndex == alertView.cancelButtonIndex ){
       
        [self.navigationController popViewControllerAnimated:YES];
        
    } else { 
        
        [self setState:GRKDemoAlbumsListStateConnecting];
        
        [(id<GRKServiceGrabberConnectionProtocol>)_grabber connectWithConnectionIsCompleteBlock:^(BOOL connected) {
            
            if ( connected ) {
                
                [self setState:GRKDemoAlbumsListStateConnected];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // add the "log out" button
                    [self addLogoutButton];
                    [self grabMoreAlbums];
                    
                });
                
            } else {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }
        
        } andErrorBlock:^(NSError *error) {
            
            [self setState:GRKDemoAlbumsListStateError];
            NSLog(@" an error occured trying to connect the grabber : %@", error);
            
        
        }];
        
    }
    
}

#pragma mark - 


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    if ( [keyPath isEqualToString:@"count"] ){
        
        NSInteger indexOfAlbum = [_albums indexOfObject:object];

        if ( indexOfAlbum != NSNotFound ){
            
            NSArray * indexPathsToReload = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexOfAlbum inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];    
        }
        
    }
    
}

-(void) loadCoverPhotoForAlbums:(NSArray*)albums {
    
    
    NSMutableArray * albumsWithoutCover = [NSMutableArray array];
    for( GRKAlbum * album in albums ){
        if ( album.coverPhoto == nil ){
            [albumsWithoutCover addObject:album];
        }
    }
    
    [_grabber fillCoverPhotoOfAlbums:albumsWithoutCover withCompleteBlock:^(id result) {

        //NSLog(@" finished ! %@", result);
        
        [self.tableView reloadData]; 
        
    } andErrorBlock:^(NSError *error) {
        
        
    }];
    
    
}

-(void) grabMoreAlbums {
    
    
    [self setState:GRKDemoAlbumsListStateGrabbing];
    
    NSLog(@" load albums for page %d", _lastLoadedPageIndex);
    [_grabber albumsOfCurrentUserAtPageIndex:_lastLoadedPageIndex
                   withNumberOfAlbumsPerPage:kNumberOfAlbumsPerPage 
                            andCompleteBlock:^(NSArray *results) {
                                
                                _lastLoadedPageIndex+=1;
                                [_albums addObjectsFromArray:results];
                                
                                for( GRKAlbum * newAlbum in results ){
                                    
                                    [newAlbum addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
                                }
                                
                                [self loadCoverPhotoForAlbums:results];
                                
                                // Update the state. the tableView is reloaded in this method.
                                if ( [results count] < kNumberOfAlbumsPerPage ){
                                    allAlbumsGrabbed = YES;
                                    [self setState:GRKDemoAlbumsListStateAllAlbumsGrabbed];
                                } else [self setState:GRKDemoAlbumsListStateAlbumsGrabbed];
                                
                                
                                
                            } andErrorBlock:^(NSError *error) {
                            
                                NSLog(@" error ! %@", error);
                                
                            }];
    
}


#pragma mark - Logout

-(void) logoutGrabberAndPopToRoot {
    
    [_grabber cancelAllWithCompleteBlock:^(NSArray *results) {

  
        if ( [_grabber conformsToProtocol:@protocol(GRKServiceGrabberConnectionProtocol)] ){

            [(id<GRKServiceGrabberConnectionProtocol>)_grabber disconnectWithDisconnectionIsCompleteBlock:^(BOOL disconnected) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

        
    }];

    
}


@end
