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
#import "GRKPickerViewController+privateMethods.h"
#import "GRKPickerServicesList.h"
#import "GRKPickerAlbumsList.h"
#import "GRKPickerPhotosList.h"


GRKPickerViewController * pickerViewControllerSharedInstance = nil;

@implementation GRKPickerViewController

@synthesize pickerDelegate = _pickerDelegate;
@synthesize allowsSelection = __allowsSelection;
@synthesize allowsMultipleSelection = __allowsMultipleSelection;
@synthesize keepsSelection = __keepsSelection;



+(GRKPickerViewController *) sharedInstance {
    
    if ( pickerViewControllerSharedInstance == nil ){
        
        GRKPickerServicesList * servicesList = [[GRKPickerServicesList alloc] init];

        pickerViewControllerSharedInstance = [[GRKPickerViewController alloc] initWithRootViewController:servicesList];
        
        pickerViewControllerSharedInstance.navigationBar.translucent = YES;
        pickerViewControllerSharedInstance.navigationBar.barStyle = UIBarStyleBlack;
        
    }
    
    return pickerViewControllerSharedInstance;
    
}


-(id) initWithRootViewController:(UIViewController *)rootViewController{
    
    self = [super initWithRootViewController:rootViewController];
    if ( self ){
        _pickerPresentingPopover = nil;
        _pickerDelegate = nil;
        
        _selectedPhotos = [NSMutableDictionary dictionary];
        
        self.allowsSelection = YES;
        self.allowsMultipleSelection = NO;
        self.keepsSelection = NO;
        
        runningOperations = 0;
        
        /*
         Set the UINavigationControllerDelegate
            /!\ don't mix up between :
            self.delegate : UINavigationControllerDelegate
            self.pickerDelegate : GRKPickerViewControllerDelegate
         */
        self.delegate = self;
        
    }
    
    return self;
}



-(void)presentInPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    
    if ( _pickerPresentingPopover == nil ){
        _pickerPresentingPopover = [[UIPopoverController alloc] initWithContentViewController:self];
    }
    
    _pickerPresentingPopover.popoverContentSize = CGSizeMake(320, 500);

    [self popToRootViewControllerAnimated:NO];
    
    [_pickerPresentingPopover presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    
}



-(void)presentInPopoverFromRect:(CGRect)rect inView:(UIView*)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    
    if ( _pickerPresentingPopover == nil ){
        _pickerPresentingPopover = [[UIPopoverController alloc] initWithContentViewController:self];
    }
    
    _pickerPresentingPopover.popoverContentSize = CGSizeMake(320, 500);
    
    [self popToRootViewControllerAnimated:NO];
    
    [_pickerPresentingPopover presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark UINavigationControllerDelegate methods

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ( [viewController isKindOfClass:[GRKPickerServicesList class]]) {
        
        
        // Notify the delegate that the picker did show the list of services.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(pickerWillShowServicesList:)]){
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate pickerWillShowServicesList:self];
        }

        
       
    } else if ( [viewController isKindOfClass:[GRKPickerAlbumsList class]]) {

        // Notify the delegate that the picker did show the list of albums for the given service.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(picker:willShowAlbumsListForServiceName:)]){
            
            NSString * serviceName = ((GRKPickerAlbumsList*)viewController).serviceName;
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate picker:self willShowAlbumsListForServiceName:serviceName];
            
        }
        
    
    } else if ( [viewController isKindOfClass:[GRKPickerPhotosList class]]) {
        
        // Notify the delegate that the picker did show the list of photos for the given album.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(picker:willShowPhotosListForAlbum:)]){
            
            GRKAlbum * album = ((GRKPickerPhotosList*)viewController).album;
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate picker:self willShowPhotosListForAlbum:album];
            
        }
        
    }
    
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ( [viewController isKindOfClass:[GRKPickerServicesList class]]) {

        CGSize sizeForServicesList = CGSizeMake(320, 480);
        viewController.contentSizeForViewInPopover = sizeForServicesList;
        _pickerPresentingPopover.popoverContentSize = sizeForServicesList;

        
        // Notify the delegate that the picker did show the list of services.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(pickerDidShowServicesList:)]){
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate pickerDidShowServicesList:self];
        }

        
    } else if ( [viewController isKindOfClass:[GRKPickerAlbumsList class]]) {
        
        CGSize sizeForAlbumsList = CGSizeMake(320, 680);
        viewController.contentSizeForViewInPopover = sizeForAlbumsList;
        _pickerPresentingPopover.popoverContentSize = sizeForAlbumsList;

        
        // Notify the delegate that the picker did show the list of albums for the given service.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(picker:didShowAlbumsListForServiceName:)]){
            
            NSString * serviceName = ((GRKPickerAlbumsList*)viewController).serviceName;
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate picker:self didShowAlbumsListForServiceName:serviceName];
            
        }

         
    } else if ( [viewController isKindOfClass:[GRKPickerPhotosList class]]) {
        
        
        // Notify the delegate that the picker did show the list of photos for the given album.
        if ( self.pickerDelegate != nil && [self.pickerDelegate respondsToSelector:@selector(picker:didShowPhotosListForAlbum:)]){
            
            GRKAlbum * album = ((GRKPickerPhotosList*)viewController).album;
            [(id<GRKPickerViewControllerDelegate>)self.pickerDelegate picker:self didShowPhotosListForAlbum:album];
            
        }
        
        
    }
    
    
}



@end
