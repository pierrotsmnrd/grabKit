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


#import "GRKServiceGrabber.h"

extern const NSString * kGRKProfilePictureKey;
extern const NSString * kGRKUsernameKey;

/** This category extends the GRKServiceGrabber class (the parent class of every grabber) to offer common method needed for the download of specific user's data.
 
*/
@interface GRKServiceGrabber (usernameAndProfilePicture)

/** This method must be masked by every grabber subclassing this class. 

 In Debug, an NSAssert makes this function fail, in order to remind the developer to mask this function in his own grabber.
 
 In Release, this method does nothing.
 
 @param completeBlock this parameter is ignored, and is only needed for the subclassing grabbers
 @param errorBlock this parameter is ignored, and is only needed for the subclassing grabbers
*/
-(void)loadUsernameAndProfilePictureOfCurrentUserWithCompleteBlock:(GRKServiceGrabberCompleteBlock)completeBlock andErrorBlock:(GRKErrorBlock)errorBlock;


/** Returns a "bad format result" error for a "loadUsernameAndProfilePictureOfCurrentUser..." operation.
 The error's domain is built with the grabber's type and the "usernameAndProfilePicture" operation.
 The error's userInfo dictionary contains its localized description (with the key NSLocalizedDescriptionKey)
 
 */
-(NSError *)errorForBadFormatResultForUsernameAndProfilePictureOperation;

@end
