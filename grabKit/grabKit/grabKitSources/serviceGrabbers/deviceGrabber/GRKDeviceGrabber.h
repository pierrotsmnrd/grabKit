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

#import <UIKit/UIKit.h>
#import "GRKServiceGrabber.h"
#import "GRKServiceGrabberProtocol.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kGRKServiceNameDevice = @"GRKDeviceGrabber";

/** GRKDeviceGrabber is a subclass of GRKServiceGrabber specific for the iPhone/iPad, conforming to GRKServiceGrabberProtocol.
 */
@interface GRKDeviceGrabber : GRKServiceGrabber <GRKServiceGrabberProtocol> {
    
    /** a reference to an instance of ALAssetsLibrary, from which we retrieve the albums and photos
    */
    ALAssetsLibrary* library;
    
    
    /** NSDictionary containing ALAssetsGroup as objects, and their respective id as keys
       This dictionary is needed because ALAssetsLibrary doesn't offer a method to retrieve an ALAssetsGroup by its id
    */
    NSMutableDictionary * assetsGroupsById; 
    
    
    /** When calling the method [GRKDeviceGrabber cancelAll], this flag is set to yes.
        The running operations check this flag to know if they have to stop.
     */
    BOOL cancelAllFlag;
    
    
    /** Count of the current queries running.
        Each time a query ends, this count in decremented.
     When calling [GRKDeviceGrabber cancelAllWithCompleteBlock:], the complete block is copied.
     Then, when the queriesCount reaches zero, the completeBlock is called.
    */
    int queriesCount;
    
    
    /** block to call once all the queries are canceled
     */
    GRKServiceGrabberCompleteBlock cancelAllCompleteBlock; 
}

@end
