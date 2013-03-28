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

#import "UIImage+thumbnail.h"

@implementation UIImage (thumbnail)


- (UIImage *)thumbnailImageWithSize:(CGSize)newSize {
    
    
    UIImage * resultScaled = [self imageScaledToSize:newSize];
    
    
    CGRect rect = CGRectMake(0, MAX(0, (resultScaled.size.height - newSize.height) / 2 ) , newSize.width, newSize.height);
    if (resultScaled.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * resultScaled.scale,
                          rect.origin.y * resultScaled.scale,
                          rect.size.width * resultScaled.scale,
                          rect.size.height * resultScaled.scale);
    }
    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(resultScaled.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:resultScaled.scale orientation:resultScaled.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}


-(UIImage *)imageScaledToSize:(CGSize)newSize {
    
    if ( self.size.height > self.size.width ){
        
        CGFloat finalHeight = self.size.height * newSize.width / self.size.width;
        
        UIGraphicsBeginImageContextWithOptions( CGSizeMake(newSize.width, finalHeight), NO, 0.0);
        
        [self drawInRect:CGRectMake(0, 0, newSize.width, finalHeight)];
        
    } else {
        
        CGFloat finalWidth =  self.size.width * newSize.height / self.size.height;
        
        UIGraphicsBeginImageContextWithOptions( CGSizeMake(finalWidth, newSize.height), NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, finalWidth, newSize.height)];
        
    }
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}






@end
