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


#import "GRKDemoPhotosListCell.h"
#import "GRKDemoImagesDownloader.h"
#import "GRKPhoto.h"
#import "GRKImage.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface GRKDemoPhotosListCell()
-(void) updateThumbnails;
@end

@implementation GRKDemoPhotosListCell

@synthesize photos = _photos;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
-(id) initWithIdentifier:(NSString*)reuseIdentifier andArrayOfPhotos:(NSArray*)photos;
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if ( self != nil ){
        
        _photos = [photos retain];
    }
    
    return self;
}
*/
- (void)prepareForReuse {
    
    _photos = nil;
}

-(void) setPhotos:(NSArray*)newPhotos;
{
    
    _photos = newPhotos;
    
    [self updateThumbnails];
    
}

-(void) updateThumbnail:(UIImageView*)thumbnail withPhoto:(GRKPhoto*)photo {
    
    NSURL * thumbnailURL = nil;
    
    for( GRKImage * image in [photo imagesSortedByHeight] ){
        
        // The imageView for thumbnails are 75px wide
        if ( image.width > 75 ) {
            
            thumbnailURL = image.URL;
            
            // Once we have found the first thumbnail bigger than the thumbnail, break the loop
            break;
        }
    }
    
    
    // Special case for the assets images
    if ( [[thumbnailURL absoluteString] hasPrefix:@"assets-library://"] ){
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:thumbnailURL resultBlock:^(ALAsset *asset) {

            // You can also load a "fullResolutionImage", but it's heavy ...
            CGImageRef imgRef = [[asset defaultRepresentation] fullScreenImage];
            [thumbnail setImage:[UIImage imageWithCGImage:imgRef]];
            
        } failureBlock:^(NSError *error) {
           
            [thumbnail setBackgroundColor:[UIColor redColor]];
            
        }];
        
    } else {
    
        [[GRKDemoImagesDownloader sharedInstance] downloadImageAtURL:thumbnailURL forImageView:thumbnail];
    
    }

}

-(void) updateThumbnails {
    
    if ( [_photos count] == 0 ) return;
    
    GRKPhoto * photoForThumbnail0 = [_photos objectAtIndex:0];
    [self updateThumbnail:photoThumbnail0 withPhoto:photoForThumbnail0];
    
    
    if ( [_photos count] == 1 ) return;
    
    GRKPhoto * photoForThumbnail1 = [_photos objectAtIndex:1];
    [self updateThumbnail:photoThumbnail1 withPhoto:photoForThumbnail1];
    
    
    if ( [_photos count] == 2 ) return;
    
    GRKPhoto * photoForThumbnail2 = [_photos objectAtIndex:2];
    [self updateThumbnail:photoThumbnail2 withPhoto:photoForThumbnail2];
    
    
    if ( [_photos count] == 3 ) return;
    
    GRKPhoto * photoForThumbnail3 = [_photos objectAtIndex:3];
    [self updateThumbnail:photoThumbnail3 withPhoto:photoForThumbnail3];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
