
GrabKit
=======================

GrabKit is an iOS Objective-C library offering simple and unified methods to retrieve photo albums on Facebook, Flickr, Picasa, iPhone/iPad and Instagram (and more to come...)


Abstract
--------

In your iPhone/iPad applications, you may want to let your users access their photo albums hosted on various social networks like Facebook or FlickR, or stored in the device.
Unfortunately, the websites hosting these images offer different APIs and different libraries to authentify a user, grab its photo albums, etc.

GrabKit is made to wrap these differences into a simple library. Retrieve photo albums the same way for Facebook, FlickR, or any other implemented service !

So far, GrabKit supports :
- Facebook
- FlickR
- Instagram
- Picasa
- iPhone/iPad


GrabKit is an ARC project.  


Screenshots of the Demo application
-------------

![screenshot of the demo application](https://github.com/pierrotsmnrd/grabKit/raw/master/doc/screenshots_demo.png)


Quick Examples
-------------
### First example : retrieve 10 albums on user's Facebook account.

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

### Second example : Fill an album with its 10 first photos
	
	GRKAlbum * firstAlbum = [albums objectAtIndex:0];
	
	[grabber fillAlbum:firstAlbum withPhotosAtPageIndex:0 withNumberOfPhotosPerPage:10 andCompleteBlock:^(NSArray *addedPhotos) {
                    
         // At this point, firstAlbum is filled with its 10 first photos, and the added photos are passed in the NSArray addedPhotos
          
          NSLog(@" already loaded photos of first album : %@", [firstAlbum photos]);
          NSLog(@" added photos : %@", addedPhotos);
          
          
      } andErrorBlock:^(NSError *error) {
          // Oop's, an error occured :)
      }] ;
	
	

Features
--------

Grabkit allows you to grab these photo albums for the following services :

* Facebook
* FlickR
* Picasa
* Instagram
* iPhone/iPad


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


How To Use GrabKit
-------------

The demo application included in the project is ready to use.

### Installation

To install and setup GrabKit in your project, follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-install-GrabKit)

                    
### Configuration                    
                    
In order to grab content from each service, you need to register your app and get an API key from each service. 

Please follow the [detailled instructions in the wiki](https://github.com/pierrotsmnrd/grabKit/wiki/How-to-configure-GrabKit) 


Coming soon
-------

* More tests and examples
* More services
* More documentation
* More content to grab
* Changes for iOS6

Feel free to help and contribute :)


GrabKit v1.2 changes
-------

* All Grabbers can now grab the data of the Cover of an album, and build a GRKPhoto from it. 
  Use the Two methods added to the GRKServiceGrabberProtocol, and implemented in every grabber :
	* [GRKServiceGrabber fillCoverPhotoOfAlbum:andCompleteBlock:andErrorBlock:];
	* [GRKServiceGrabber fillCoverPhotoOfAlbums:andCompleteBlock:andErrorBlock:];					                 
* GRKAlbum : Adding the property GRKPhoto * coverPhoto
* Facebook grabber : added grabbing of the "tagged photos" of the user.
* Facebook grabber : now uses batched queries
* Facebbok grabber : optimization when retrieving data of a photo (loading only the needed data)
* GrabKit now includes the official release of Facebook iOS SDK 3.0 (not the beta version anymore)
* FlickR grabber : uses queued queries to retrieve covers of albums (FlickR API doens't offer batch methods)
* GrabKit now includes the last version of ObjectiveFlickR project (fixing issue #5)
* Picasa grabber : uses queued queries to retrieve covers of albums (Picasa API offers batch methods but they are totally unusable)
* Removed each specific kind of blocks to handle queries results (GRKFacebookQueryHandlingBlock, GRKFlickrQueryHandlingBlock, ...). These blocks are replaced by GRKQueryResultBlock.
* GRKAlbum : the method "getDateForProperty:" is now "dateForProperty:"
* GRKPhoto : the method "getDateForProperty:" is now "dateForProperty:"
* adding KVO on property "count" of GRKAlbum (useful to notify changes of this value, as services may return a wrong value)
* Update in Demo : more elegant squared cells with gray background when a thumbnail is loading
* Update in Demo : list of albums now displays the albums' covers.

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
