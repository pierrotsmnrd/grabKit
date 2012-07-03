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


GrabKit doesn't use ARC (yet).

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
	* ``name`` : nome of the album


* a **photo** is an instance of a ``GRKPhoto``. It has a ``name`` (title of the photo), a ``caption``(its description)
A ``GRKPhoto`` has several **images** which represent the photo in different sizes.

* an **image** is an instance of ``GRKImage``. it has a ``width``, a ``height``, an ``URL``, and a flag (``isOriginal``) notifying if this image is the original image uploaded by the user. 


How To Use GrabKit
-------------


### Installation

* First, include GrabKit in you project : just drag'n'drop the grabKitSources directory.

* in your appDelegate, import "GRKConnectorsDispatcher.h" and add :		
###
        
	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
	    BOOL urlHasBeenHandledByDispatcher = [[GRKConnectorsDispatcher sharedInstance] dispatchURLToConnectingServiceConnector:url];
	    if ( urlHasBeenHandledByDispatcher  ) return YES;
	    else {
	        // If you have specific URL schemes to handle for you application, 
	        //  the GRKConnectorDispatcher won't handle the URL. 
	        // Then, you can handle here your own URL schemes.
	        return NO;
	    }
	}


* GrabKit comes with all the needed libraries included. Just drag'n'drop the "libs" directory into your project.
Nevertheless, if you need to manually add services' libraries to your project, you'll find informations in the wiki. (coming soon)


* Add the following Frameworks :
    * CFNetwork.framework (for the FlickR Lib)
    * SystemConfiguration.framework and Security.framework (for the Picasa Lib)
    * AssetsLibrary.framework (for the Device Grabber)
	
	
                    
### Configuration                    
                    
In order to grab content from each service, you need to register your app and get an API key from each service

#### Facebook :
* go to https://developers.facebook.com/apps/ and click on "+ Create new app"
* enter a name for your app, and proceed
* Once you have completed the process, you'll access the page of your app.
  It shows an App Id : that's what we need.

* Open your application's App-Info.plist and in "URL Types" -> "item N" -> "URL Schemes", add "fb" + your App Id.
* Open the file GRKFacebookConstants.m and set your App Id to kGRKFacebookAppId
    


#### Instagram :
* go to http://instagram.com/developer/clients/register/
* fill the form. In the "OAuth redirect_uri" field, enter a lowercase url like "mygreatapplication://". 
* Report your Client ID and your Redirect URI in GRKInstragramConstants.m
* Open your application's App-Info.plist and in "URL Types" -> "item N" -> "URL Schemes", add your redirect URI

    
#### FlickR :
* go to http://www.flickr.com/services/apps/create/apply/ and choose the kind of key you want
* Process the form and report your Api Key and your Api Secret in GRKFlickrConstants.m
* Click on "Edit auth flow for this app", 
    * in App type, select "web application" (yes, web application ;))
    * in Callback URL, add a custom and unique url, like "mygreatappusinggrabkit://" or "flickr"+your app id+"://"
    Report your callback url (without the "://") to GRKFlickrConstants.m and in your App-Info.plist => "URL Types" -> "item N" -> "URL Schemes"
        
    

#### Picasa : 
* go to https://code.google.com/apis/console/   
    If you have never used Google APIs console before, click on "Create project".
    A default project named "API Project" is created

* Select your project, go to the "API Access" item, and click on "Create an OAUth 2.0 client ID ..."
* Enter your application's name and other informations if you need
* in Application type, select "Installed application", then validate

* Report your Client ID and Client secret in GRKPicasaConstants.m
            

                    
### How to disable a service ?

If you don't need to use a specific service :
_ Delete the directory of its grabber under GrabKitSources/servicesGrabber/ 
_ Delete the according lib under libs/ (warning : Instagram uses Facebook's library)



Coming soon
-------

* More tests and examples
* More services
* More documentation
* More content to grab
* Changes for iOS6
* ARC version

Feel free to help and contribute :)


License
-------

This project is under MIT License, please feel free to contribute and use it.


The Facebook Grabber uses :
* ISO8601DateFormatter made by Peter Hosey. http://boredzo.org/iso8601unparser/
* Facebook iOS SDK  https://github.com/facebook/facebook-ios-sdk

The FlickR Grabber uses the ObjectiveFlickR project :  https://github.com/lukhnos/objectiveflickr

The Picasa Grabber uses "Google Data APIs Objective-C Client Library" : https://code.google.com/p/gdata-objectivec-client/


Contact
-------

Are you using GrabKit in your project ? Do you have a suggestion ? Any question ? 


Pierre-Olivier Simonard pierre.olivier.simonard@gmail.com
www.twitter.com/pierrotsmnrd


