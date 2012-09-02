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


#import "GRKDemoAlbumsListCell.h"
#import "GRKDemoImagesDownloader.h"

@implementation GRKDemoAlbumsListCell

@synthesize thumbnail;
@synthesize labelAlbumName;
@synthesize labelPhotosCount;
@synthesize labelDateCreated;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setAlbum:(GRKAlbum*)_newAlbum {
    
    _album = _newAlbum;
    
    labelAlbumName.text = _album.name;
    labelPhotosCount.text = [NSString stringWithFormat:@"%d Photos", _album.count];

    if ( [_album dateForProperty:kGRKAlbumDatePropertyDateCreated] != nil ){
    
        labelDateCreated.hidden = NO;
        labelDateCreated.text = [@"Created " stringByAppendingString:[[_album dateForProperty:kGRKAlbumDatePropertyDateCreated] description]];
        
    } else {
        labelDateCreated.hidden = YES;
    }
    
    
    
    if ( _album.coverPhoto != nil ){
        
        NSURL * thumbnailURL = nil;
        
        for( GRKImage * image in [_album.coverPhoto imagesSortedByHeight] ){
            
            // The imageView for thumbnails are 75px wide
            if ( image.width > 75 ) {
                
                thumbnailURL = image.URL;
                
                // Once we have found the first thumbnail bigger than the thumbnail, break the loop
                break;
            }
        }
        
        [[GRKDemoImagesDownloader sharedInstance] downloadImageAtURL:thumbnailURL 
                                                        forThumbnail:thumbnail];

    } 
    
    
}

-(void) prepareForReuse {
    
    [thumbnail updateThumbnailWithImage:nil];
    labelAlbumName.text = @"";
    labelPhotosCount.text = @"";
    labelDateCreated.text = @"";
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
