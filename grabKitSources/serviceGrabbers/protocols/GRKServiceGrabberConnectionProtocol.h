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


#import <Foundation/Foundation.h>
#import "GRKServiceGrabberProtocol.h"

typedef void (^GRKGrabberConnectionIsCompleteBlock)(BOOL connected);
typedef void (^GRKGrabberDisconnectionIsCompleteBlock)(BOOL disconnected);

/*
 This protocol defines method that Grabbers must implement to handle proper connexion to their service.
*/
@protocol GRKServiceGrabberConnectionProtocol


@required

/*
 the [GRKGrabberConnectionProtocol connectWithConnectionIsCompleteBlock:andErrorBlock:] method must perform all actions needed to authenticate a user to a service.
 Typically, in this method, a shared instance of a GRKServiceConnector is used, calling the same method.
 This method is just here for convenience. that way, the developer uses only GRKServiceGrabber objects, and nothing else.
 
 @param connectionIsCompleteBlock a block to call passing a BOOL parameter indicating if the user is connected, or not.
 @param errorBlock a block to call if an error occurs.
 */
-(void)connectWithConnectionIsCompleteBlock:(GRKGrabberConnectionIsCompleteBlock)connectionIsCompleteBlock andErrorBlock:(GRKErrorBlock)errorBlock;


/*
 the [GRKGrabberConnectionProtocol disconnectWithConnectionIsCompleteBlock:andErrorBlock:] method must perform all actions needed to log out a user from a service.
 Typically, in this method, a shared instance of a GRKServiceConnector is used, calling the same method.
 This method is just here for convenience. that way, the developer uses only GRKServiceGrabber objects, and nothing else.
 
 @param disconnectionIsCompleteBlock a block called passing a BOOL parameter indicating if the user is disconnected, or not.
 */
-(void)disconnectWithDisconnectionIsCompleteBlock:(GRKGrabberDisconnectionIsCompleteBlock)disconnectionIsCompleteBlock;



/*
 the [GRKGrabberConnectionProtocol isConnected:] method checks if the user is connected to the service, and calls the connectedBlock with a BOOL value indicating if the user is connected or not.
 Typically, in this method, a shared instance of a GRKServiceConnector is used, calling the same method.
 This method is just here for convenience. that way, the developer uses only GRKServiceGrabber objects, and nothing else.
 
 @param connectedBlock a block called passing a BOOL parameter indicating if the user is connected, or not. 
 */
-(void) isConnected:(GRKGrabberConnectionIsCompleteBlock)connectedBlock;


@end
