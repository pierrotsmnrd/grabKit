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


#import "GRKPickerPhotosListThumbnail.h"
#import "GRKPickerViewController.h"

static UIImage * thumbnailPlaceholderImage;

@implementation GRKPickerPhotosListThumbnail


+(UIImage*)sharedThumbnailPlaceholderImage {
    
    if ( thumbnailPlaceholderImage == nil ){
        NSString * path = [GRK_BUNDLE pathForResource:@"thumbnail_placeholder" ofType:@"png"];
        thumbnailPlaceholderImage = [UIImage imageWithContentsOfFile:path];
    }
    
    
    return thumbnailPlaceholderImage;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
       [self buildViews];
        
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        [self buildViews];
        
    }

    return self;
}

-(void) buildViews {
    
    UIImageView * backgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
    [backgroundImage setImage:[GRKPickerPhotosListThumbnail sharedThumbnailPlaceholderImage]];
    self.backgroundView = backgroundImage;
    
    // The imageView's frame is 1px smaller in every directions, in order to show the 1px-wide black border of the background image.
    CGRect thumbnailRect = CGRectMake(1, 1, self.bounds.size.width -2 , self.bounds.size.height -2 );
    thumbnailImageView = [[UIImageView alloc] initWithFrame:thumbnailRect];
//    [self addSubview:thumbnailImageView];
    [self.contentView addSubview:thumbnailImageView];
    
    NSString * path = [GRK_BUNDLE pathForResource:@"thumbnail_selected" ofType:@"png"];
    UIImage * selectedIcon = [UIImage imageWithContentsOfFile:path];
    selectedImageView = [[UIImageView alloc] initWithImage:selectedIcon];
    CGFloat selectedIconSize = round(self.bounds.size.width / 2.5);
    selectedImageView.frame =  CGRectMake(self.contentView.bounds.size.width - selectedIconSize,
                                          0,
                                          selectedIconSize,
                                          selectedIconSize );
    selectedImageView.alpha = .0;
    
    
}



-(void) prepareForReuse {
    
    [thumbnailImageView setImage:nil];
//    [selectedImageView removeFromSuperview];
    selectedImageView.alpha = 0;

    // Fix for issue #27 https://github.com/pierrotsmnrd/grabKit/issues/27
    self.selected = NO;
    
}




-(void)updateThumbnailWithImage:(UIImage*)image  animated:(BOOL)animated; {
    
    if ( thumbnailImageView.image == nil  &&  animated ){
        
            thumbnailImageView.alpha = .0;
            [thumbnailImageView setImage:image];
        
            [UIView animateWithDuration:0.33 animations:^{
                
                thumbnailImageView.alpha = 1.;
            
            } completion:^(BOOL finished) {
                
                if ( selectedImageView.superview == nil ){
                    [self.contentView addSubview:selectedImageView];
                }
                
            }];
            
    } else {
            
            // UI updates must be done on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [thumbnailImageView setImage:image];
               
                if ( selectedImageView.superview == nil ){
                    [self.contentView addSubview:selectedImageView];
                }
            });

            
    }
    
    
}

-(void) setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    selectedImageView.alpha = selected?1:0;
    
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
