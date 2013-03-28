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

#import "GRKAlbum_test_getters.h"
#import "GRKAlbum.h"
#import "GRKAlbum+modify.h"
#import "GRKPhoto.h"



@implementation GRKAlbum_test_getters

/*
 
 // photos getters
 
 // returns an  array containing the GRKPhoto already loaded, and containing [NSNull null] for photos not loaded yet
 // Objects in the returned array follow the order in which they have been added to the album
 -(NSArray*) orderedPhotos;	
 
 // returns an array containing all the GRKPhoto already loaded.
 // Objects in the returned array follow the order in which they have been added to the album
 -(NSArray*) orderedPhotosWithoutBlanks;	
 
 // returns an array containing all the GRKPhoto already loaded, without specific order
 -(NSArray*) photos; 
 
 // returns an array containing the GRKPhoto for the given page index, with the given number of photos per page. 
 // Objects in the returned array follow the order in which they have been added to the album
 // the returned array is filled with NSNull objects if some photos in the album has not been totally filled
 -(NSArray*) photosAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;
 
 // returns an array containing the ids of the GRKPhoto for the given page index, with the given number of photos per page. 
 // Objects in the returned array follow the order in which they have been added to the album
 -(NSArray*) photosIdsAtPageIndex:(NSUInteger)pageIndex withNumberOfPhotosPerPage:(NSUInteger)numberOfPhotosPerPage;
 

 
*/


- (void)testOrderedPhotos
{
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    // add photos for album, only for even ranks
    for( int i = 0; i < 11; i+=2 ){
        
        
        GRKPhoto * randomPhoto = [self randomPhotoWithIdAndName:[NSString stringWithFormat:@"%d",i]];
        [album addPhoto:randomPhoto atIndex:i];
        
    }
    
  	NSArray * photos = [album orderedPhotos];
    
    STAssertEquals([photos count], (NSUInteger)11,@"method [GRKAlbum orderedPhotos] is bugged (%d objects instead of %d)",[photos count], 11 );
    
    for( int i = 0; i < 11; i++ ){

        id objectAtThisIndex = [photos objectAtIndex:i];
        
        if ( i%2 == 0){
            
	        STAssertTrue( [objectAtThisIndex isKindOfClass:[GRKPhoto class]] ,@"method [GRKAlbum orderedPhotos] is bugged (object at index %d is not a GRKPhoto)", i );

            // here, we test that the returned array is properly ordered
            if ( [objectAtThisIndex isKindOfClass:[GRKPhoto class]] ){
            
                NSString * supposedPhotoId = [NSString stringWithFormat:@"%d", i];
                NSString * photoIdToTest = ((GRKPhoto*)objectAtThisIndex).photoId;
                
                STAssertTrue( [photoIdToTest isEqualToString:supposedPhotoId] ,@"method [GRKAlbum orderedPhotos] is bugged (object at index %d has photoId %@ instead of %@)", i, photoIdToTest, supposedPhotoId );
            
            }
		} else {
	        STAssertTrue( [[photos objectAtIndex:i] isKindOfClass:[NSNull class]] ,@"method [GRKAlbum orderedPhotos] is bugged (object at index %d is not a NSNul)", i );
   		}     
    
    }
            
}

-(void) testOrderedPhotosWithoutBlanks {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    // add photos for album, only for even ranks
    for( int i = 0; i < 11; i+=2 ){
        
        
        GRKPhoto * randomPhoto = [self randomPhotoWithIdAndName:[NSString stringWithFormat:@"%d",i]];
        [album addPhoto:randomPhoto atIndex:i];
        
    }
    
  	NSArray * photos = [album orderedPhotosWithoutBlanks];
    
    STAssertEquals([photos count], (NSUInteger)6, @"method [GRKAlbum orderedPhotosWithoutBlanks] is bugged (has %d objects instead of %d", [photos count], 6);
    
    for( int i = 0; i < [photos count]; i++ ){
        
        id object = [photos objectAtIndex:i];
        STAssertTrue( [object isKindOfClass:[GRKPhoto class]],@"method [GRKAlbum orderedPhotosWithoutBlanks] is bugged (object at index %d is a %@, not a GRKPhoto)",i, [object class]);
        
        NSString * supposedPhotoId = [NSString stringWithFormat:@"%d", i*2];
        NSString * photoIdToTest = ((GRKPhoto*)object).photoId;
        STAssertTrue( [photoIdToTest isEqualToString:supposedPhotoId], @"method [GRKAlbum orderedPhotosWithoutBlanks] is bugged (object has photoId '%@' instead of '%@')", photoIdToTest, supposedPhotoId);
        
        
    }
    
}

-(void) testPhotos {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    // add photos for album, only for even ranks
    for( int i = 0; i < 11; i+=2 ){
        
        
        GRKPhoto * randomPhoto = [self randomPhoto];
        [album addPhoto:randomPhoto atIndex:i];
        
    } 
    
    NSArray * photos = [album photos];
    
    STAssertEquals([photos count], (NSUInteger)6, @"method [GRKAlbum photos] is bugged (has %d objects instead of %d", [photos count], 6);
    
    for( int i = 0; i < [photos count]; i++ ){
        
        id object = [photos objectAtIndex:i];
        STAssertTrue( [object isKindOfClass:[GRKPhoto class]],@"method [GRKAlbum photos] is bugged (object at index %d is a %@, not a GRKPhoto)",i, [object class]);
                
    }
}



-(void) testPhotosAtPageIndexWithNumberOfPhotosPerPage {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    // add photos for album, only for even ranks
    for( int i = 0; i < 20; i+=2 ){
        
        GRKPhoto * randomPhoto = [self randomPhotoWithIdAndName:[NSString stringWithFormat:@"%d",i]];
        [album addPhoto:randomPhoto atIndex:i];
        
    } 
 
	NSUInteger numberOfPhotosPerPage = 5;
    NSArray * page0 = [album photosAtPageIndex:0 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    
    for( int i = 0; i < numberOfPhotosPerPage; i++ ){
        
        id objectAtIndex = [page0 objectAtIndex:i];
        if ( i%2 == 0 ){
            
            STAssertTrue( [objectAtIndex isKindOfClass:[GRKPhoto class]],@"method [GRKAlbum photosAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'GRKPhoto'", i, [objectAtIndex class] );  

            if ( [objectAtIndex isKindOfClass:[GRKPhoto class]] ){
                
                
                NSString * supposedPhotoId = [NSString stringWithFormat:@"%d", i];
                NSString * photoIdToTest = ((GRKPhoto*)objectAtIndex).photoId;
                STAssertTrue( [photoIdToTest isEqualToString:supposedPhotoId], @"method [GRKAlbum photosAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object has photoId '%@' instead of '%@')", photoIdToTest, supposedPhotoId);

                
            }
            
        } else {
            
            STAssertTrue( [objectAtIndex isKindOfClass:[NSNull class]],@"method [GRKAlbum photosAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'NSNull'", i, [objectAtIndex class] );  
        }
        
    }
    
    
    
    NSArray * page40 = [album photosAtPageIndex:40 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    STAssertEquals([page40 count], (NSUInteger)0, @"method [GRKAlbum photosAtPageIndex:withNumberOfPhotosPerPage:] is bugged (very far page has %d objects instead of %d)", [page40 count], 0 );
    
    
}


-(void) testPhotosIdsAtPageIndexWithNumberOfPhotosPerPage {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    // add photos for album, only for even ranks
    for( int i = 0; i < 20; i+=2 ){
        
        GRKPhoto * randomPhoto = [self randomPhotoWithIdAndName:[NSString stringWithFormat:@"%d",i]];
        [album addPhoto:randomPhoto atIndex:i];
        
    } 
    
	NSUInteger numberOfPhotosPerPage = 5;
    NSArray * page0 = [album photosIdsAtPageIndex:0 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    
    STAssertTrue([page0 count] == numberOfPhotosPerPage, @"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (returned only %d objects for page 0 with %d photos per page" , [page0 count], numberOfPhotosPerPage);

    
    for( int i = 0; i < numberOfPhotosPerPage; i++ ){
        
        id objectAtIndex = [page0 objectAtIndex:i];
        if ( i%2 == 0 ){
            
            STAssertTrue( [objectAtIndex isKindOfClass:[NSString class]],@"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'NSString'", i, [objectAtIndex class] );  
            
            if ( [objectAtIndex isKindOfClass:[NSString class]] ){
                
                
                NSString * supposedPhotoId = [NSString stringWithFormat:@"%d", i];
                
                STAssertTrue( [objectAtIndex isEqualToString:supposedPhotoId], @"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object has photoId '%@' instead of '%@')", objectAtIndex, supposedPhotoId);
                
                
            }
            
        } else {
            
            STAssertTrue( [objectAtIndex isKindOfClass:[NSNull class]],@"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'NSNull'", i, [objectAtIndex class] );  
        }
        
    }
    
    
    
    
    NSArray * page2With7PhotosPerPage = [album photosIdsAtPageIndex:2 withNumberOfPhotosPerPage:7];
    
    STAssertTrue([page2With7PhotosPerPage count] == 5, @"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (returned only %d objects for page 2 with 7 photos per page" , [page2With7PhotosPerPage count]);
    
    for ( int i = 0; i < 5; i++ ){
        
        id objectAtIndex = [page2With7PhotosPerPage objectAtIndex:i];

        if ( i%2 == 0 && i+14 <= 18 ){
            
            STAssertTrue( [objectAtIndex isKindOfClass:[NSString class]],@"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'NSString'", i, [objectAtIndex class] );  
            
            if ( [objectAtIndex isKindOfClass:[NSString class]] ){
                
                
                NSString * supposedPhotoId = [NSString stringWithFormat:@"%d", i+14];
                
                STAssertTrue( [objectAtIndex isEqualToString:supposedPhotoId], @"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object has photoId '%@' instead of '%@')", objectAtIndex, supposedPhotoId);
                
                
            }

            
        } else {
            
            STAssertTrue( [objectAtIndex isKindOfClass:[NSNull class]],@"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (object at index %d in page0 is kind of class '%@' instead of 'NSNull'", i, [objectAtIndex class] );  

            
        }
        
    }
    
    
    NSArray * page40 = [album photosIdsAtPageIndex:40 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    STAssertEquals([page40 count], (NSUInteger)0, @"method [GRKAlbum photosIdsAtPageIndex:withNumberOfPhotosPerPage:] is bugged (very far page has %d objects instead of %d)", [page40 count], 0 );
    
    
}

@end
