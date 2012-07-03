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
//  GDataFeedPhotoBase.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataFeedPhotoBase.h"
#import "GDataPhotoElements.h"

@interface GDataFeedPhotoUser : GDataFeedPhotoBase {
}

+ (GDataFeedPhotoUser *)userFeed;

- (NSNumber *)maxPhotosPerAlbum; // long long
- (void)setMaxPhotosPerAlbum:(NSNumber *)num;

- (NSString *)nickname;
- (void)setNickname:(NSString *)str;

- (NSString *)thumbnail;
- (void)setThumbnail:(NSString *)str;

- (NSNumber *)quotaLimit; // long long
- (void)setQuotaLimit:(NSNumber *)num;

- (NSNumber *)quotaUsed; // long long
- (void)setQuotaUsed:(NSNumber *)num;

- (NSString *)username;
- (void)setUsername:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
