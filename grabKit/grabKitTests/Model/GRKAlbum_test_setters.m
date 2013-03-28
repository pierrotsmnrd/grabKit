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

#import "GRKAlbum_test_setters.h"
#import "GRKAlbum.h"
#import "GRKAlbum+modify.h"

@implementation GRKAlbum_test_setters


- (void)testAddPhotoAtIndex
{
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    GRKPhoto * randomPhotoAtIndex0 = [self randomPhoto];
    [album addPhoto:randomPhotoAtIndex0 atIndex:0];
    
    GRKPhoto * randomPhotoAtIndex9 = [self randomPhoto];
    [album addPhoto:randomPhotoAtIndex9 atIndex:9];

  	NSArray * photos = [album orderedPhotos];

    STAssertEquals([photos objectAtIndex:9], randomPhotoAtIndex9, @"method [GRKAlbum addPhoto:atIndex:] is bugged");
    STAssertEquals([photos count], (NSUInteger)10, @"method [GRKAlbum addPhoto:atIndex:] is bugged");

    
    GRKPhoto * randomPhotoAtIndex5 = [self randomPhoto];
    [album addPhoto:randomPhotoAtIndex5 atIndex:5];
	
    
    
    photos = [album orderedPhotos];
    
    STAssertEquals([photos objectAtIndex:9], randomPhotoAtIndex9, @"method [GRKAlbum addPhoto:atIndex:] is bugged (%@ instead of %@)",[photos objectAtIndex:9],randomPhotoAtIndex9  );

    STAssertEquals([photos objectAtIndex:5], randomPhotoAtIndex5, @"method [GRKAlbum addPhoto:atIndex:] is bugged (%@ instead of %@)",[photos objectAtIndex:5],randomPhotoAtIndex5  );
    STAssertEquals([photos count], (NSUInteger)10, @"method [GRKAlbum addPhoto:atIndex:] is bugged");

    
}

- (void)testAddPhotoForPageIndexWithNumberOfPhotosPerPage {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    NSUInteger numberOfPhotosPerPage = 5;
    
    NSMutableArray * page0 = [NSMutableArray array];
    for ( int i= 0; i < numberOfPhotosPerPage; i++ ){
        [page0 addObject:[self randomPhoto]];
    }
    
    NSMutableArray * page2 = [NSMutableArray array];
    for ( int i= 0; i < numberOfPhotosPerPage; i++ ){
        [page2 addObject:[self randomPhoto]];
    }
    
    [album addPhotos:page0 forPageIndex:0 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    [album addPhotos:page2 forPageIndex:2 withNumberOfPhotosPerPage:numberOfPhotosPerPage];    
    
    
    // Step 1
    // at this point, the album is supposed to be filled with :
    //	_ 5 GRKPhoto objects for indexes 0->4,
    //	_ then 5 NSNull for indexes 5->9 
    //	_ and finally 5 GRKPhoto objects for indexes 10->14
    
	// Here is an illustration (P : GRKPhoto, N : NSNull )
    //  Object		P  P  P  P  P  N  N  N  N  N   P   P  P  P  P
    //	rank		0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 
    // pageIndex   [      0     ] [      2     ] [      3     ] 
    // let's check that
    
    NSArray * allPhotosAndNSNull = [album orderedPhotos];
    
    for ( int i= 0; i < numberOfPhotosPerPage; i++ ){
		
        STAssertEquals([allPhotosAndNSNull objectAtIndex:i],[page0 objectAtIndex:i], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged");
        
        STAssertEquals([allPhotosAndNSNull objectAtIndex:numberOfPhotosPerPage+i],[NSNull null], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged");

        STAssertEquals([allPhotosAndNSNull objectAtIndex:numberOfPhotosPerPage*2+i],[page2 objectAtIndex:i], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged");

    }
    
    // Step 2
    //
    // let's reuse the previous album, and modify it.
    // let's use pages of 3 photos, and set photos for even page indexes

    numberOfPhotosPerPage = 3;
    
    for ( int i=0; i <= 5 ; i+=2 ){
    					// we have 5 pages, with 3 photos per page.
        NSMutableArray * newPage = [NSMutableArray array];
        for ( int j= 0; j < numberOfPhotosPerPage; j++ ){
            [newPage addObject:[self randomPhoto]];
        }
        
        [album addPhotos:newPage forPageIndex:i withNumberOfPhotosPerPage:numberOfPhotosPerPage];
        
        allPhotosAndNSNull = [album orderedPhotos];
	
    }

    allPhotosAndNSNull = [album orderedPhotos];
    
    
    // Here is an illustration of what the album should contain : (P : GRKPhoto, N : NSNull )
	//  Step1 		P  P  P   P  P  N   N  N  N   N  P  P   P  P  P
    //  Now 		P  P  P   P  P  N   P  P  P   N  P  P   P  P  P
    //	rank 		0  1  2   3  4  5   6  7  8   9 10 11  12 13 14 
    // pageIndex   [  0  ]   [  1  ]   [  2  ]   [  3  ]  [   4  ]  

    // let's check that objects at indexes 5 and 9 are NSNull, and the others are GRKPhoto

	allPhotosAndNSNull = [album orderedPhotos];
    
    
    STAssertEquals([allPhotosAndNSNull objectAtIndex:5],[NSNull null], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged");
    STAssertEquals([allPhotosAndNSNull objectAtIndex:9],[NSNull null], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged");
    
    for ( int i = 0; i < 15; i++ ){
        
        if ( i != 5 && i != 9 ){

            STAssertTrue( [[allPhotosAndNSNull objectAtIndex:i] isKindOfClass:[GRKPhoto class]], @" method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage:] is bugged (index:%d)", i);
            
        }
        
    }
    
}



- (void)testCountUpdate {
    
    // let's build an album supposed to have 20 photos.
    
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:20 
                                  andDates:nil];
    
    // Let's build 3 pages of 5 photos ...
    
    NSMutableArray * pageAtIndex0 = [NSMutableArray array];
    NSMutableArray * pageAtIndex1 = [NSMutableArray array];
    NSMutableArray * pageAtIndex2 = [NSMutableArray array];
    
    for ( int i = 0; i < 5; i++ ){
        [pageAtIndex0 addObject:[self randomPhoto]];
        [pageAtIndex1 addObject:[self randomPhoto]];
        [pageAtIndex2 addObject:[self randomPhoto]];
    }
    
    // ... and a 4th page of only 2 pictures.
    
    NSMutableArray * pageAtIndex3 = [NSMutableArray arrayWithObjects:[self randomPhoto], [self randomPhoto], nil];
    
    // add these pages to the album
    
    [album addPhotos:pageAtIndex0 forPageIndex:0 withNumberOfPhotosPerPage:5];
    [album addPhotos:pageAtIndex1 forPageIndex:1 withNumberOfPhotosPerPage:5];    
    [album addPhotos:pageAtIndex2 forPageIndex:2 withNumberOfPhotosPerPage:5];    
    [album addPhotos:pageAtIndex3 forPageIndex:3 withNumberOfPhotosPerPage:5];        
    
    
    // at this point, album.count should have been updated to 17
    
    STAssertTrue( album.count == 17, @"method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage] doesn't update the count value properly ");
    
    
    // reset the page at index 3 to have 5 photos ...
    [pageAtIndex3 addObject:[self randomPhoto]];
    [pageAtIndex3 addObject:[self randomPhoto]];
    [pageAtIndex3 addObject:[self randomPhoto]];
    
    [album addPhotos:pageAtIndex3 forPageIndex:3 withNumberOfPhotosPerPage:5];
    
    // ... and test again
    STAssertTrue( album.count == 20, @"method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage] doesn't update the count value properly ");
    
    
    // Now, add a page at index 4 containing only 2 photos, and check that count is updated to 22
    NSMutableArray * pageAtIndex4 = [NSMutableArray arrayWithObjects:[self randomPhoto], [self randomPhoto], nil];
    [album addPhotos:pageAtIndex4 forPageIndex:4 withNumberOfPhotosPerPage:5];
    
    STAssertTrue( album.count == 22, @"method [GRKAlbum addPhotos:forPageIndex:withNumberOfPhotosPerPage] doesn't update the count value properly ");
    
}



- (void)testFirstAddSecondPhotoPage {
    
    GRKAlbum * album = [GRKAlbum albumWithId:@"testAlbum" 
                                   andName:@"testAlbum" 
                                  andCount:10 
                                  andDates:nil];
    
    NSUInteger numberOfPhotosPerPage = 5;
    
    NSMutableArray * page0 = [NSMutableArray array];
    for ( int i= 0; i < numberOfPhotosPerPage; i++ ){
        [page0 addObject:[self randomPhoto]];
    }
    
    NSMutableArray * page1 = [NSMutableArray array];
    for ( int i= 0; i < numberOfPhotosPerPage; i++ ){
        [page1 addObject:[self randomPhoto]];
    }
    
    [album addPhotos:page1 forPageIndex:1 withNumberOfPhotosPerPage:numberOfPhotosPerPage];
    [album addPhotos:page0 forPageIndex:0 withNumberOfPhotosPerPage:numberOfPhotosPerPage];    
    
    
   
    NSLog(@" %@ ", [album photos]);
    
}




@end
