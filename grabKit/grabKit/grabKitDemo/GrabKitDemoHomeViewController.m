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

#import "GrabKitDemoHomeViewController.h"
#import "GrabKit.h"
#import "GRKPickerViewController.h"
#import "GRKAlbum.h"

@interface GrabKitDemoHomeViewController ()

@end

@implementation GrabKitDemoHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)didTouchLoadAnImagButton:(id)sender;
{
    
    // Here, we retrieve the sharedInstance of the picker
    GRKPickerViewController * grabkitPickerViewController = [GRKPickerViewController sharedInstance];
    
    // We set our controller as delegate of the picker
    grabkitPickerViewController.pickerDelegate = self;
    
    // We allow the selection ...
    grabkitPickerViewController.allowsSelection = YES;

    // ... and we allow, or not, the multiple selection.
    grabkitPickerViewController.allowsMultipleSelection = _multipleSelectSwitch.on;


    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {

        // On iPhone, all you have to do is to present the picker like any other view controller
        [self presentViewController:grabkitPickerViewController animated:YES completion:^{
            
        }];

    } else {
    
        // On iPad, instead of building your own UIPopoverController to present the picker, use this method :
        [grabkitPickerViewController presentInPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
        // Don't build your own UIPopoverController to present the picker. GRKPickerViewController builds and uses its own popover, for technical reasons, leading to a better user experience.
    
    
    }

    
    
}


#pragma mark GRKPickerViewControllerDelegate methods 


/* All the delegate methods below informs you on how the user interacts with the GRKPickerViewController.
 
*/
-(void)picker:(GRKPickerViewController *)picker didHighlightPhoto:(GRKPhoto *)photo {
    
    NSLog(@" did highlight photo : %@", photo);
    
    
    /* Here, you can push your own viewController in the picker's navigation hierarchy.
    
    CustomViewController * myController = [[CustomViewController alloc] initWithPhoto:photo];
    [[GRKPickerViewController sharedInstance] pushViewController:myController animated:YES];

    Important to notice : 
        _ if you push your own view controller in this method, the controller is pushed BEFORE the photo is SELECTED.
        _ if you push it in the method picker:didUnhighlightPhoto: below, the controller is pushed AFTER the photo becomes SELECTED or UNSELECTED (according to its state before the users touches it)
     
     */
    
}

-(void)picker:(GRKPickerViewController *)picker didUnhighlightPhoto:(GRKPhoto *)photo {
    
    NSLog(@" did unhighlight photo : %@", photo);
    
}




-(BOOL)picker:(GRKPickerViewController *)picker shouldSelectPhoto:(GRKPhoto *)photo {
    
    NSLog(@" should select photo ? %@", photo);
    return YES;
}

-(BOOL)picker:(GRKPickerViewController *)picker shouldDeselectPhoto:(GRKPhoto *)photo {
    
    NSLog(@" should deselect photo ? %@", photo);
    return YES;
}




-(void)picker:(GRKPickerViewController *)picker didSelectPhoto:(GRKPhoto *)photo {
    
    NSLog(@" did select photo : %@", photo);
}

-(void)picker:(GRKPickerViewController *)picker didDeselectPhoto:(GRKPhoto *)photo {

    NSLog(@" did deselect photo : %@", photo);
    
}


-(void)picker:(GRKPickerViewController *)picker didDismissWithSelectedPhotos:(NSArray *)selectedPhotos {
    
    NSLog(@" did finish, selected photos : %@", selectedPhotos );
    
    /* This method is called when the user dismisses the picker.
        The array selectedPhotos contains the GRKPhoto objects that the user selected. 
        If the multiple selection is not allowed, the array contains only one object.
     
        
     A GRKPhoto object contains one or several GRKImage objects. 
     Here is a snippet showing how you can retrieve the URL of one of the images :
     
     */
    
    
    if ( [selectedPhotos count] > 0 ){
        
        // For this example, let's retrieve the first photo
        GRKPhoto * firstPhoto = [selectedPhotos objectAtIndex:0];

        // On this photo, we want the original image, the one the user uploaded on the service
        GRKImage * originalImage = [firstPhoto originalImage];
        
        NSLog(@" the URL of the original image of the first selected photo is : %@", originalImage.URL );
        NSLog(@" the size of this image is : %d x %d ", originalImage.width, originalImage.height );
        
        // Warning : this image can be VERY BIG (for example, on FlickR, original images can weight 5MB !)
        
        /* Important Notice : Special URLs for the images from the device
         
         For the photos grabbed from the device, the URL of the images will begin with : assets-library://
         You can't download these images with an NSURLConnection or whatever. 
         Here is a snippet showing how you can retrieve such image :
         
         */

        // If the url begins with assets-library://
        if ( [[originalImage.URL absoluteString] hasPrefix:@"assets-library://"] ){
            
            // Instantiate a library
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            
            // Ask for the "Asset" for the URL. An asset is a representation of an image in the Photo application.
            [library assetForURL:originalImage.URL
                     resultBlock:^(ALAsset *asset) {
                
                         // Here, we have the asset, let's retrieve the image from it
                         
                         CGImageRef imgRef = [[asset defaultRepresentation] fullResolutionImage];
                         /* Instead of the full res image, you can ask for an image that fits the screen
                         CGImageRef imgRef  = [[asset defaultRepresentation] fullScreenImage];
                         */
                         
                         // From the CGImage, let's build an UIImage
                         UIImage * fullResImage = [UIImage imageWithCGImage:imgRef];
                         
                         // and we're done ! :)
                         NSLog(@" The UIImage for URL %@ is %@", originalImage.URL, fullResImage);
            
                     } failureBlock:^(NSError *error) {
                         
                         // Something wrong happened.
                         
                     }];
       
        }
        
        
        
    }
    
    
}



-(void)pickerWillShowServicesList:(GRKPickerViewController *)picker {
    NSLog(@" picker will show services list");
}

-(void)pickerDidShowServicesList:(GRKPickerViewController *)picker {
    NSLog(@" picker did show services list");
}




-(void)picker:(GRKPickerViewController *)picker willShowAlbumsListForServiceName:(NSString *)serviceName{
    NSLog(@" picker will show albums list for service name : %@", serviceName);
}

-(void)picker:(GRKPickerViewController *)picker didShowAlbumsListForServiceName:(NSString *)serviceName{
    NSLog(@" picker did show albums list for service name : %@", serviceName);
}



-(void)picker:(GRKPickerViewController *)picker willShowPhotosListForAlbum:(GRKAlbum *)album{
    NSLog(@" picker will show photos list for album : %@", album.name);
}

-(void)picker:(GRKPickerViewController *)picker didShowPhotosListForAlbum:(GRKAlbum *)album{
    NSLog(@" picker did show photos list for album : %@", album.name);
}





@end
