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


#import "GRKPickerAlbumsListCell.h"


@implementation GRKPickerAlbumsListCell

@synthesize thumbnail;
@synthesize labelAlbumName;
@synthesize labelPhotosCount;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}



-(void)updateThumbnailWithImage:(UIImage*)image animated:(BOOL)animated {
    
    [self.thumbnail updateThumbnailWithImage:image animated:animated];
    
}


-(void)setAlbum:(GRKAlbum*)_newAlbum {
    
    _album = _newAlbum;
    
    labelAlbumName.text = _album.name;
    

    // In this cell, we want the label for the photos count to be placed right after the name of the album
    // Like : "Album Name (15)" or with truncation : "Very long album na... (160)"
    
    // First, let's compute the size for the album's name label
    
    // 170px is the maximum width for this label.
    CGSize labelAlbumNameSize = [_album.name sizeWithFont:labelAlbumName.font
                                        constrainedToSize:CGSizeMake(170, labelAlbumName.frame.size.height)
                                            lineBreakMode:NSLineBreakByTruncatingTail];
    
    
    // This label has always its origin at (87,28). have a look to the xib.
    labelAlbumName.frame = CGRectMake(87, 28, labelAlbumNameSize.width, labelAlbumNameSize.height);
    
    
    // Now, let's compute and set the frame of the label for the photos count 
    
    NSString * labelPhotosCountText = [NSString stringWithFormat:@"(%d)", _album.count ];
    
    // 50px is the maximum width for this label. it is supposed to be enough to contain the string "(999+)" without truncating
    CGSize labelPhotosCountSize = [labelPhotosCountText sizeWithFont:labelPhotosCount.font
                                                  constrainedToSize:CGSizeMake(50, labelPhotosCount.frame.size.height)
                                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    
    // this label is placed 5px on the right of the album's name
    labelPhotosCount.frame = CGRectMake(  CGRectGetMaxX(labelAlbumName.frame) +5, 28, labelPhotosCountSize.width, labelPhotosCountSize.height);
    labelPhotosCount.text = labelPhotosCountText;
 
    
    
}



-(void) prepareForReuse {
    
    [thumbnail prepareForReuse];
    labelAlbumName.text = @"";
    labelPhotosCount.text = @"";

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
