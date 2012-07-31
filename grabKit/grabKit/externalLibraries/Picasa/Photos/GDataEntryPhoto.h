/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataEntryPhoto.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataEntryPhotoBase.h"
#import "GDataGeo.h"
#import "GDataMediaGroup.h"
#import "GDataEXIFTags.h"

@interface GDataEntryPhoto : GDataEntryPhotoBase

+ (GDataEntryPhoto *)photoEntry;

// uploading photo data 
- (void)setPhotoData:(NSData *)data; // data will retained by the entry
- (NSData *)photoData;

- (void)setPhotoMIMEType:(NSString *)str;
- (NSString *)photoMIMEType;

// getters and setters

// to move a photo to another album, set the photo entry's albumID
// to the album's GPhotoID and update the photo entry (with
// fetchPhotoEntryByUpdatingEntry:) 
- (NSString *)albumID;
- (void)setAlbumID:(NSString *)str;

- (NSString *)checksum;
- (void)setChecksum:(NSString *)str;

- (NSNumber *)commentCount; // int
- (void)setCommentCount:(NSNumber *)num;

- (NSNumber *)commentsEnabled; // bool
- (void)setCommentsEnabled:(NSNumber *)num;

- (NSNumber *)height; // long long
- (void)setHeight:(NSNumber *)num;

- (NSNumber *)rotation; // int
- (void)setRotation:(NSNumber *)num;

- (NSNumber *)size; // long long
- (void)setSize:(NSNumber *)num;

- (GDataPhotoTimestamp *)timestamp; // use stringValue or date methods on timestamp
- (void)setTimestamp:(GDataPhotoTimestamp *)str;

- (NSNumber *)width; // long long
- (void)setWidth:(NSNumber *)num;

- (NSString *)videoStatus;
- (void)setVideoStatus:(NSString *)str;  

// setGeoLocation requires an instance of a subclass of GDataGeo, not an
// instance of GDataGeo; see GDataGeo.h
- (GDataGeo *)geoLocation;
- (void)setGeoLocation:(GDataGeo *)geo;

- (GDataMediaGroup *)mediaGroup;
- (void)setMediaGroup:(GDataMediaGroup *)obj;

- (GDataEXIFTags *)EXIFTags;
- (void)setEXIFTags:(GDataEXIFTags *)tags;

//
// search result elements introduced in V2
//

- (NSString *)albumDescription;
- (void)setAlbumDescription:(NSString *)str;

- (NSString *)albumTitle;
- (void)setAlbumTitle:(NSString *)str;

- (NSString *)snippet;
- (void)setSnippet:(NSString *)str;

// snippet type constants are in GDataPhotoConstants.h, like
// kGDataPhotoSnippetTypeAlbumTitle
- (NSString *)snippetType;
- (void)setSnippetType:(NSString *)str;

- (NSNumber *)truncated; // int, 0 or 1
- (void)setTruncated:(NSNumber *)num;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
