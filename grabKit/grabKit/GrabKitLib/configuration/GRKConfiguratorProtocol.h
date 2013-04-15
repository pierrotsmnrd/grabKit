//
//  DefaultGRKConfigurationDelegate.h
//  ShareKit
//
//  Created by Edward Dale on 10/16/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol GRKConfiguratorProtocol 

@required

// Connection to services

// Facebook
- (NSString*)facebookAppId;

// Flickr 
- (NSString*)flickrApiKey;
- (NSString*)flickrApiSecret;
- (NSString*)flickrRedirectUri;


// Instragram 
- (NSString*)instagramAppId;
- (NSString*)instagramRedirectUri;

// Picasa
- (NSString*)picasaClientId;
- (NSString*)picasaClientSecret;


// Others

// The name of the album "Tagged photos" on Facebook, as you want GrabKit to return it.
// Hint : use localization here.
- (NSString*) facebookTaggedPhotosAlbumName;

@optional


/* The Picasa connector doesn't open a Safari page to let the user authenticate. Instead, it presents a viewController. 
 When using the GrabKitPicker, the viewController is presented in its navigation hierarchy, no action is required on your part.
 
 But when you use GrabKit as a library, Picasa's Auth viewController must be displayed. 
 The viewController returned by this configuration method will present Picasa's auth controller.

 
 If your custom viewController is an instance of UINavigationController, GrabKit will call the configuration method 'customViewControllerShouldPresentPicasaAuthControllerModally' to know if Picasa's Auth Controller must be presented "modally", or pushed in the navigation hierarchy.
 
 If your custom viewController is not a navigationController, GrabKit will present Picasa's auth controller "modally"
 
 */
-(UIViewController *)customViewControllerToPresentPicasaAuthController;


/* If you use GrabKit as a library (i.e. without GrabKitPicker), and if the custom view controller you return in "customViewControllerToPresentPicasaAuthController" is an instance of UINavigationController, then this method will help you define if Picasa's Auth Controller must be pushed in the navigation hierarchy, or must be presented modally.
 
 */
-(BOOL)customViewControllerShouldPresentPicasaAuthControllerModally;

@end


