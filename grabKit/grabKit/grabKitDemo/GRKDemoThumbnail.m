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


#import "GRKDemoThumbnail.h"

@interface UIImage(crop)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
@end


@implementation UIImage(crop)


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


static UIImage * thumbnailPlaceholderImage;

@implementation GRKDemoThumbnail


+(UIImage*)sharedThumbnailPlaceholderImage {
    
    if ( thumbnailPlaceholderImage == nil ){
        thumbnailPlaceholderImage = [UIImage imageNamed:@"thumbnail_placeholder.png"];
    }
    
    
    return thumbnailPlaceholderImage;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        UIImageView * backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [backgroundImage setImage:[GRKDemoThumbnail sharedThumbnailPlaceholderImage]];
        [self addSubview:backgroundImage];
        
        CGRect thumbnailRect = CGRectMake(1, 1, self.bounds.size.width -2 , self.bounds.size.height -2 );
        thumbnailImageView = [[UIImageView alloc] initWithFrame:thumbnailRect];
        [self addSubview:thumbnailImageView];
        
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        UIImageView * backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [backgroundImage setImage:[GRKDemoThumbnail sharedThumbnailPlaceholderImage]];
        [self addSubview:backgroundImage];

        CGRect thumbnailRect = CGRectMake(1, 1, self.bounds.size.width -2 , self.bounds.size.height -2 );
        thumbnailImageView = [[UIImageView alloc] initWithFrame:thumbnailRect];
        [self addSubview:thumbnailImageView];
        
    }
    return self;
}



- (UIImage *)thumbnailImageFromImage:(UIImage*)sourceImage thumbnailSize:(CGSize)newSize {
    
    
    UIImage * resultScaled = [sourceImage imageScaledToSize:newSize];
    
    
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

-(void)updateThumbnailWithData:(NSData*)data; {

    [self updateThumbnailWithImage:[UIImage imageWithData:data]];
}


-(void)updateThumbnailWithImage:(UIImage*)image; {
    
    // build the image
    
    CGSize thumbnailSize = thumbnailImageView.frame.size;
    
    UIImage * croppedImage = [self thumbnailImageFromImage:image thumbnailSize:thumbnailSize]; 
    
    
    // UI updates must be done 
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [thumbnailImageView setImage:croppedImage];
        [thumbnailImageView setContentMode:UIViewContentModeRedraw];
    });

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
