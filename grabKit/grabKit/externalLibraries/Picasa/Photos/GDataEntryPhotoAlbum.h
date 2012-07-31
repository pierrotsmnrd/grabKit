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
//  GDataEntryPhotoAlbum.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataEntryPhotoBase.h"
#import "GDataGeo.h"
#import "GDataMediaGroup.h"
#import "GDataEXIFTags.h"


@interface GDataEntryPhotoAlbum : GDataEntryPhotoBase

+ (GDataEntryPhotoAlbum *)albumEntry;

- (NSString *)access;
- (void)setAccess:(NSString *)obj;

- (NSNumber *)bytesUsed; // long long
- (void)setBytesUsed:(NSNumber *)obj;

- (NSNumber *)commentCount; // int
- (void)setCommentCount:(NSNumber *)obj;

- (NSNumber *)commentsEnabled; // bool
- (void)setCommentsEnabled:(NSNumber *)obj;

- (GDataPhotoTimestamp *)timestamp; // use stringValue or date methods on timestamp
- (void)setTimestamp:(GDataPhotoTimestamp *)obj;

- (NSString *)location;
- (void)setLocation:(NSString *)obj;

- (NSString *)nickname;
- (void)setNickname:(NSString *)obj;

- (NSNumber *)photosLeft; // int
- (void)setPhotosLeft:(NSNumber *)obj;

- (NSNumber *)photosUsed; // int
- (void)setPhotosUsed:(NSNumber *)obj;

- (NSString *)username;
- (void)setUsername:(NSString *)obj;

// setGeoLocation requires an instance of a subclass of GDataGeo, not an
// instance of GDataGeo; see GDataGeo.h
- (GDataGeo *)geoLocation;
- (void)setGeoLocation:(GDataGeo *)geo;

- (GDataMediaGroup *)mediaGroup;
- (void)setMediaGroup:(GDataMediaGroup *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
