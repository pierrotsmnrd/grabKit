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
//  GDataFeedPhotoBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataFeedPhotoUser.h"
#import "GDataPhotoConstants.h"

@implementation GDataFeedPhotoUser

+ (GDataFeedPhotoUser *)userFeed {
  
  GDataFeedPhotoUser *feed = [self object];
  
  [feed setNamespaces:[GDataPhotoConstants photoNamespaces]];
  
  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryPhotosUser;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // common photo extensions
  Class feedClass = [self class];

  [self addExtensionDeclarationForParentClass:feedClass
                                 childClasses:
   [GDataPhotoMaxPhotosPerAlbum class],
   [GDataPhotoNickname class],
   [GDataPhotoQuotaLimit class],
   [GDataPhotoQuotaUsed class],
   [GDataPhotoThumbnail class],
   [GDataPhotoUser class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"maxPhotosPerAlbum", @"maxPhotosPerAlbum", kGDataDescValueLabeled },
    { @"nickname",          @"nickname",          kGDataDescValueLabeled },
    { @"quotaLimit",        @"quotaLimit",        kGDataDescValueLabeled },
    { @"quotaUsed",         @"quotaUsed",         kGDataDescValueLabeled },
    { @"thumbnail",         @"thumbnail",         kGDataDescValueLabeled },
    { @"username",          @"username",          kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSNumber *)maxPhotosPerAlbum { // long long
  GDataPhotoMaxPhotosPerAlbum *obj = [self objectForExtensionClass:[GDataPhotoMaxPhotosPerAlbum class]];
  return [obj longLongNumberValue];
}

- (void)setMaxPhotosPerAlbum:(NSNumber *)num {
  GDataPhotoMaxPhotosPerAlbum *obj = [GDataPhotoMaxPhotosPerAlbum valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoMaxPhotosPerAlbum class]];  
}

- (NSString *)nickname {
  GDataPhotoNickname *obj = [self objectForExtensionClass:[GDataPhotoNickname class]];
  return [obj stringValue];
}

- (void)setNickname:(NSString *)str {
  GDataPhotoNickname *obj = [GDataPhotoNickname valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoNickname class]];  
}

- (NSString *)thumbnail {
  GDataPhotoThumbnail *obj = [self objectForExtensionClass:[GDataPhotoThumbnail class]];
  return [obj stringValue];
}

- (void)setThumbnail:(NSString *)str {
  GDataPhotoThumbnail *obj = [GDataPhotoThumbnail valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoThumbnail class]];  
}

- (NSNumber *)quotaLimit { // long long
  GDataPhotoQuotaLimit *obj = [self objectForExtensionClass:[GDataPhotoQuotaLimit class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaLimit:(NSNumber *)num {
  GDataPhotoQuotaLimit *obj = [GDataPhotoQuotaLimit valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoQuotaLimit class]];  
}

- (NSNumber *)quotaUsed { // long long
  GDataPhotoQuotaUsed *obj = [self objectForExtensionClass:[GDataPhotoQuotaUsed class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaUsed:(NSNumber *)num {
  GDataPhotoQuotaUsed *obj = [GDataPhotoQuotaUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoQuotaUsed class]];  
}

- (NSString *)username {
  GDataPhotoUser *obj = [self objectForExtensionClass:[GDataPhotoUser class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataPhotoUser *obj = [GDataPhotoUser valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
