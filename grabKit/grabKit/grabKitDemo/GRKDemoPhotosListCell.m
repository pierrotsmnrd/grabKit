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
    
    [photoThumbnail3 setHidden:NO];
    [photoThumbnail2 setHidden:NO];                
    [photoThumbnail1 setHidden:NO];
    [photoThumbnail0 setHidden:NO];

    
}

-(void) setPhotos:(NSArray*)newPhotos;
{
    
    _photos = newPhotos;
    

    // Hide some thumbnails if the row is incomplete
    switch ([_photos count]) {
        case 0:
            [photoThumbnail0 setHidden:YES];
        case 1:
            [photoThumbnail1 setHidden:YES];
        case 2:
            [photoThumbnail2 setHidden:YES];                
        case 3:
           [photoThumbnail3 setHidden:YES];
            break;
    }
    
    
    [self updateThumbnails];
    
}

-(void) updateThumbnail:(GRKDemoThumbnail*)thumbnail withPhoto:(GRKPhoto*)photo {
    
    NSURL * thumbnailURL = nil;
    
    for( GRKImage * image in [photo imagesSortedByHeight] ){
        
        // The imageView for thumbnails are 75px wide
        if ( image.width > 75 ) {
            
            thumbnailURL = image.URL;
            
            // Once we have found the first thumbnail bigger than the thumbnail, break the loop
            break;
        }
    }
    

    [[GRKDemoImagesDownloader sharedInstance] downloadImageAtURL:thumbnailURL forThumbnail:thumbnail];    


}

-(void) updateThumbnails {
    
     switch ([_photos count]) {
    
         case 4:
             [self updateThumbnail:photoThumbnail3 withPhoto:[_photos objectAtIndex:3]];                     
         case 3:
             [self updateThumbnail:photoThumbnail2 withPhoto:[_photos objectAtIndex:2]];        
         case 2:
             [self updateThumbnail:photoThumbnail1 withPhoto:[_photos objectAtIndex:1]];        
         case 1:
             [self updateThumbnail:photoThumbnail0 withPhoto:[_photos objectAtIndex:0]];        

             break;
     
     }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
