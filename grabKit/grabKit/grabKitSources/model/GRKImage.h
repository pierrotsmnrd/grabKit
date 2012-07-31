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


/**
 A GRKImage object represent an image for a photo
 
 It stores properties like the URL of the image, its width and height, and a BOOL to mark the original image.
  
 */
@interface GRKImage  : NSObject { 

    NSURL * _URL;
    
    NSUInteger _width;
    NSUInteger _height;
    
    BOOL _isOriginal;
}


/** @name  Properties */

/** URL of the image */ 
@property (nonatomic, strong, readonly) NSURL * URL;
/** width of the image */ 
@property (nonatomic, readonly) NSUInteger width;
/** height of the image */ 
@property (nonatomic, readonly) NSUInteger height;
/** BOOL value marking the image as original */ 
@property (nonatomic, readonly) BOOL isOriginal;


/** @name Creating a GRKImage */

/** Creates and returns a GRKImage object with the given parameters
 *
 * 
 * 
 * @param URLString string representing the URL of the image
 * @param width width of the image
 * @param height height of the image
 * @param isOriginal BOOL value to mark the image as original
 * @return an initialized GRKImage.
 */
-(id) initWithURLString:(NSString *)URLString andWidth:(NSUInteger)width andHeight:(NSUInteger)height isOriginal:(BOOL)isOriginal;


/** Creates and returns a GRKImage object with the given parameters
 *
 * 
 * 
 * @param URL URL of the image
 * @param width width of the image
 * @param height height of the image
 * @param isOriginal BOOL value to mark the image as original
 * @return an initialized GRKImage.
 */
-(id) initWithURL:(NSURL *)URL andWidth:(NSUInteger)width andHeight:(NSUInteger)height isOriginal:(BOOL)isOriginal;


/** Creates and returns a GRKImage object with the given parameters
 *
 * 
 * 
 * @param URLString string representing the URL of the image
 * @param width width of the image
 * @param height height of the image
 * @param isOriginal BOOL value to mark the image as original
 * @return an initialized GRKImage.
 */
+(GRKImage*) imageWithURLString:(NSString *)URLString andWidth:(NSUInteger)width andHeight:(NSUInteger)height isOriginal:(BOOL)isOriginal;


/** Creates and returns a GRKImage object with the given parameters
 *
 * 
 * 
 * @param URL URL of the image
 * @param width width of the image
 * @param height height of the image
 * @param isOriginal BOOL value to mark the image as original
 * @return an initialized GRKImage.
 */
+(GRKImage*) imageWithURL:(NSURL *)URL andWidth:(NSUInteger)width andHeight:(NSUInteger)height isOriginal:(BOOL)isOriginal;


@end
