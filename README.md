
GrabKit
=======================

GrabKit is an iOS Objective-C library offering simple and unified methods to retrieve photo albums on Facebook, Flickr, Picasa, iPhone/iPad and Instagram (and more to come...)


Abstract
--------

In your iPhone/iPad applications, you may want to let your users access their photo albums hosted on various social networks like Facebook or FlickR, or stored in the device.
Unfortunately, the websites hosting these images offer different APIs and different libraries to authentify a user, grab its photo albums, etc.

GrabKit is made to wrap these differences into a simple library. Retrieve photo albums the same way for Facebook, FlickR, or any other implemented service !

So far, Grabkit allows you to retrieve photos from the following sources :

* Facebook
* FlickR
* Picasa
* Instagram
* iPhone/iPad


GrabKit is compatible with iOS 5.1 and further.

GrabKit is an ARC project.


Demo application
-------------

![screenshot of the demo application](https://github.com/pierrotsmnrd/grabKit/raw/master/doc/screenshots_demo.png)


A few steps are needed to run GrabKit's demo application, please follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-run-GrabKit's-demo-application)


How to use Grabkit in your app
-------------


### Installation

To install and setup GrabKit in your project, follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-install-GrabKit)

                    
### Configuration                    
                    
In order to grab content from each service, you need to register your app and get an API key from each service. 

Please follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-configure-GrabKit) 


### Examples 

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

* an **album** is an instance of a ``GRKAlbum``, having the following properties :
	* ``albumId`` : id of the album according to the service
	* ``count`` : total number of photos for the album, according to the service. 
	* ``name`` : name of the album
	* ``coverPhoto`` : an instance of a ``GRKPhoto`` representing the cover photo of the album
	
* a **photo** is an instance of a ``GRKPhoto``. It has a ``name`` (title of the photo), a ``caption``(its description). 
A ``GRKPhoto`` has several **images** which represent the photo in different sizes.

* an **image** is an instance of ``GRKImage``. it has a ``width``, a ``height``, an ``URL``, and a flag (``isOriginal``) notifying if this image is the original image uploaded by the user. 


Coming soon
-------

* More tests and examples
* More services
* More documentation
* More content to grab
* Changes for iOS6

Feel free to help and contribute :)


GrabKit v1.2.3 changes
-------
* Update in GrabKit Demo's pbxproj to weakly link 2 frameworks ( Accounts and AdSupport, needed for Facebook )
* Update in GrabKit's pbxproj for Xcode 4.6
* Update in Facebook Grabber : better test to validate session, and improved handling of errors in some batch requests.
* Fix for issue #12 (improvement) : Detection of cancelled authentication processes.


GrabKit v1.2.2 changes
-------
* The "external libraries" directory has been replaced by submodules
* A bash script has been added to download and install submodules
* The icons for each service in the demo App have been updated
* The documentation has been updated
* Fixed a bug in GRKDeviceGrabber when there is 0 album on the device


GrabKit v1.2.1
-------
* Merging a pull request from zrqx, fixing minor bugs for the Facebook grabber.


GrabKit v1.2 changes
-------

[check the full changelog](https://github.com/pierrotsmnrd/grabKit/blob/master/changelog.txt)
	

License
-------

This project is under MIT License, please feel free to contribute and use it.


The Facebook Grabber uses :
* ISO8601DateFormatter made by Peter Hosey. http://boredzo.org/iso8601unparser/
* Facebook iOS SDK  https://github.com/facebook/facebook-ios-sdk

The FlickR Grabber uses the ObjectiveFlickR project :  https://github.com/lukhnos/objectiveflickr

The Picasa Grabber uses "Google Data APIs Objective-C Client Library" : https://code.google.com/p/gdata-objectivec-client/


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
