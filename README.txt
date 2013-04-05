
GrabKit
=======================

GrabKit for iOS offers a ready-to-use component to easily import photos from social networks. 

GrabKit allows you to retrieve photos from  :
	* Facebook
	* FlickR
	* Picasa
	* Instagram
	* iPhone/iPad
	* ... and more to come



Abstract
--------

In your iPhone/iPad applications, you may want to let your users access their photo albums hosted on various social networks like Facebook or FlickR, or stored in the device.
Unfortunately, the websites hosting these images offer different APIs and different libraries to authentify a user, grab its photo albums, etc.

GrabKit is made to wrap these differences into :
	* a simple library : GrabKitLib 
	* a simple ready-to-use component : GrabKitPicker, based on GrabKitLib


GrabKitPicker is Developer-friendly :
	
	* Compatible with iOS 5.1 and higher, for both iPhone and iPad, the GrabKitPicker is already compatible with your project. 
		
	* Once you've installed and configured it, all you have to do is to present it "modally" on iPhone, or through a popover on iPad.
		
	* Easy to use, GrabKitPicker offers two main classes : GRKPickerViewController, and its delegate GRKPickerViewControllerDelegate.

	* Through its delegation protocol, you can easily handle your users' interactions.
	
	* Easy to customize, it will fit to the design of your applications.
	
	* Of course, GrabKitPicker uses ARC, and is full of documentation and comments.
	
GrabKitPicker is also user-friendly :
	
	* Translated in French and English so far, but soon translated in other languages. Feel free to help ! :)
		
	* The default interface is simple and easy to use, though heavily tested to offer the best user-experience possible.
	
	
	
![screenshot of GrabKitPicker](https://github.com/pierrotsmnrd/grabKit/raw/master/doc/screenshots_demo.png)
		


Demo application
-------------

The best way to discover how powerful GrabKit is, is to run the Demo application.
Only a few steps are needed to run it, just follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-run-GrabKit's-demo-application)


How to use Grabkit in your app
-------------


### Installation

To install and setup GrabKit in your project, follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-install-GrabKit)

                    
### Configuration                    
                    
In order to grab content from each service, you need to register your app and get an API key from each service. 

Please follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-configure-GrabKit) 


### Add the GrabKitPicker in you code 

From any UIViewController in your app, all you have to do is similar to this :
	
	// Retrieve the singleton of GrabKitPicker
	GRKPickerViewController * grabkitPickerViewController = [GRKPickerViewController sharedInstance];

	// Set the picker's delegate. 
	// Don't forget to add GRKPickerViewControllerDelegate in the list of protocols implemented by your controller.
	grabkitPickerViewController.pickerDelegate = self;

	 // We allow the selection 
    grabkitPickerViewController.allowsSelection = YES;
	grabkitPickerViewController.allowsMultipleSelection = YES;
	
	[self presentViewController:grabkitPickerViewController animated:YES completion:^{
    	// GrabKitPicker is now displayed        
    }];
	
	
On iPad, you can simply call this method on the picker, to present it from a UIPopover :
	
	[grabkitPickerViewController presentInPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
	
Then, implement in your controller the delegate method you need. 
The delegate method called when the picker is dismissed, passing the array of the photos the user selected, is :

	-(void)picker:(GRKPickerViewController*)picker didDismissWithSelectedPhotos:(NSArray*)selectedPhotos {
		
		// selectedPhotos is an NSArray of GRKPhoto objects. Check the "Model" section below for more details.
			
	}

### Use GrabKitLib

	TODO REWORK
	
	
#### First example : retrieve 10 albums on user's Facebook account.

    #import "GRKFacebookGrabber.h"
    
    // create a grabber for Facebook
	GRKFacebookGrabber * grabber = [[GRKFacebookGrabber alloc] init];

	// Do you prefer a grabber for Picasa or FlickR ? simply create a GRKPicasaGrabber or a GRKFlickrGrabber.
	// the following code would still work.

    // Connect the grabber. the user will be prompted in Safari to authenticate and return to the app.
	[grabber connectWithConnectionIsCompleteBlock:^(BOOL connected){
		
        if ( connected ){
            
            // ask for the first 10 albums of the user.
            [grabber albumsOfCurrentUserAtPageIndex:0 withNumberOfAlbumsPerPage:10 andCompleteBlock:^(NSArray *albums) {
               
                // albums is an NSArray of GRKAlbum, containing the 10 first albums of the user on Facebook.
                
            } andErrorBlock:^(NSError *error) {
        
                // Oop's, an error occured :)
            }];
        }
        
    }];

#### Second example : Fill an album with its 10 first photos
	
	GRKAlbum * firstAlbum = [albums objectAtIndex:0];
	
	[grabber fillAlbum:firstAlbum withPhotosAtPageIndex:0 withNumberOfPhotosPerPage:10 andCompleteBlock:^(NSArray *addedPhotos) {
                    
         // At this point, firstAlbum is filled with its 10 first photos, and the added photos are passed in the NSArray addedPhotos
          
          NSLog(@" already loaded photos of first album : %@", [firstAlbum photos]);
          NSLog(@" added photos : %@", addedPhotos);
          
          
      } andErrorBlock:^(NSError *error) {
          // Oop's, an error occured :)
      }] ;
	



Model 
-------------

* A ``GRKAlbum`` represents a **photo album**. This object has the following properties :
	* ``albumId`` : id of the album, as returned by the service.
	* ``count`` : total number of photos for the album, according to the service. 
	* ``name`` : name of the album.
	* ``coverPhoto`` : an instance of a ``GRKPhoto`` representing the cover photo of the album
	
* A ``GRKPhoto`` represents a **photo**. It has a ``name`` (title of the photo), a ``caption``(its description). 
A ``GRKPhoto`` has several **images** which represent the photo in different sizes.

* an **image** is an instance of ``GRKImage``. it has a ``width``, a ``height``, an ``URL``, and a flag (``isOriginal``) set at ``YES`` if this image is the original image uploaded by the user. 


Coming soon
-------

* More tests and examples
* More services
* More content to grab

Feel free to help and contribute :)


GrabKit v1.3 changes
-------
* Introducing the GrabKitPicker, and much more. [check the full changelog](https://github.com/pierrotsmnrd/grabKit/blob/master/changelog.txt)
	

License
-------

This project is under MIT License, please feel free to contribute and use it.

The GrabKitPicker uses :
* NVUIGradientButton made by Nicolas Verinaud. https://github.com/nverinaud/NVUIGradientButton/
* MBProgressHUD made by Jonathan George. https://github.com/jdg/MBProgressHUD/
* PSTCollectionView by Peter Steinberger. https://github.com/steipete/PSTCollectionView/


The Facebook Grabber uses :
* ISO8601DateFormatter made by Peter Hosey. http://boredzo.org/iso8601unparser/
* Facebook iOS SDK  https://github.com/facebook/facebook-ios-sdk

The FlickR Grabber uses the ObjectiveFlickR project :  https://github.com/lukhnos/objectiveflickr

The Picasa Grabber uses "Google Data APIs Objective-C Client Library" : https://code.google.com/p/gdata-objectivec-client/


Special thanks to talented [Laurence Vagner](http://www.redisdead.net/) for the use of her photo album 'Foodporn' in the demo video.

Check her [FlickR page](http://www.flickr.com/photos/redisdead) for more pictures under Creative Commons licence.


The demo video has been made with CaptureRecord. https://github.com/gabriel/CaptureRecord

Donations
-------

GrabKit is \***100% free**\* .
However, developing and supporting this project is hard work and costs real money. Please help support the development of GrabKit !

**10%** of your donations is donated to the **Free Software Foundation**.

[![donation](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GEHQ8UX5RR298&lc=US&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)



Contact
-------

Are you using GrabKit in your project ? Do you have a suggestion ? Any question ? 


Pierre-Olivier Simonard 

pierre.olivier.simonard@gmail.com

www.twitter.com/pierrotsmnrd

www.linkedin.com/in/pierreoliviersimonard

