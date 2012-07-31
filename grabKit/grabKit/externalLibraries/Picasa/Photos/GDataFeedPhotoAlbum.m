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

#import "GDataFeedPhotoAlbum.h"
#import "GDataPhotoConstants.h"


@implementation GDataFeedPhotoAlbum

+ (GDataFeedPhotoAlbum *)albumFeed {
  
  GDataFeedPhotoAlbum *entry = [self object];
  
  [entry setNamespaces:[GDataPhotoConstants photoNamespaces]];
  
  return entry;
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryPhotosAlbum;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  
  // common photo extensions
  [self addExtensionDeclarationForParentClass:feedClass
                                 childClasses:
   [GDataPhotoAccess class], [GDataPhotoBytesUsed class],
   [GDataPhotoCommentCount class], [GDataPhotoCommentingEnabled class],
   [GDataPhotoTimestamp class], [GDataPhotoNumberUsed class],
   [GDataPhotoNumberLeft class], [GDataPhotoBytesUsed class],
   [GDataPhotoUser class], [GDataPhotoNickname class],
   [GDataPhotoLocation class], [GDataMediaGroup class],
   nil];

  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:feedClass];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"access",          @"access",          kGDataDescValueLabeled },
    { @"bytesUsed",       @"bytesUsed",       kGDataDescValueLabeled },
    { @"commentCount",    @"commentCount",    kGDataDescValueLabeled },
    { @"commentsEnabled", @"commentsEnabled", kGDataDescValueLabeled },
    { @"date",            @"timestamp",       kGDataDescValueLabeled },
    { @"location",        @"location",        kGDataDescValueLabeled },
    { @"nickname",        @"nickname",        kGDataDescValueLabeled },
    { @"photosLeft",      @"photosLeft",      kGDataDescValueLabeled },
    { @"photosUsed",      @"photosUsed",      kGDataDescValueLabeled },
    { @"username",        @"username",        kGDataDescValueLabeled },
    { @"mediaGroup",      @"mediaGroup",      kGDataDescValueLabeled },
    { @"geoLocation",     @"geoLocation",     kGDataDescValueLabeled },

    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)access {
  GDataPhotoAccess *obj = [self objectForExtensionClass:[GDataPhotoAccess class]];
  return [obj stringValue];
}

- (void)setAccess:(NSString *)str {
  GDataPhotoAccess *obj = [GDataPhotoAccess valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoAccess class]];  
}

- (NSNumber *)bytesUsed {
  // long long
  GDataPhotoBytesUsed *obj = [self objectForExtensionClass:[GDataPhotoBytesUsed class]];
  return [obj longLongNumberValue];
}

- (void)setBytesUsed:(NSNumber *)num {
  GDataPhotoBytesUsed *obj = [GDataPhotoBytesUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentCount {
  // int
  GDataPhotoCommentCount *obj = [self objectForExtensionClass:[GDataPhotoCommentCount class]];
  return [obj intNumberValue];
}

- (void)setCommentCount:(NSNumber *)num {
  GDataPhotoCommentCount *obj = [GDataPhotoCommentCount valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentsEnabled {
  // BOOL
  GDataPhotoCommentingEnabled *obj = [self objectForExtensionClass:[GDataPhotoCommentingEnabled class]];
  return [obj boolNumberValue];
}

- (void)setCommentsEnabled:(NSNumber *)num {
  GDataPhotoCommentingEnabled *obj = [GDataPhotoCommentingEnabled valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataPhotoTimestamp *)timestamp {
  return [self objectForExtensionClass:[GDataPhotoTimestamp class]];
}

- (void)setTimestamp:(GDataPhotoTimestamp *)obj {
  [self setObject:obj forExtensionClass:[GDataPhotoTimestamp class]];
}

- (NSString *)location {
  GDataPhotoLocation *obj = [self objectForExtensionClass:[GDataPhotoLocation class]];
  return [obj stringValue];
}

- (void)setLocation:(NSString *)str {
  GDataPhotoLocation *obj = [GDataPhotoLocation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoLocation class]];  
}

- (NSString *)nickname {
  GDataPhotoNickname *obj = [self objectForExtensionClass:[GDataPhotoNickname class]];
  return [obj stringValue];
}

- (void)setNickname:(NSString *)str {
  GDataPhotoNickname *obj = [GDataPhotoNickname valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoNickname class]];  
}

- (NSNumber *)photosLeft {
  // int
  GDataPhotoNumberLeft *obj = [self objectForExtensionClass:[GDataPhotoNumberLeft class]];
  return [obj intNumberValue];
}

- (void)setPhotosLeft:(NSNumber *)num {
  GDataPhotoNumberLeft *obj = [GDataPhotoNumberLeft valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)photosUsed {
  // int
  GDataPhotoNumberUsed *obj = [self objectForExtensionClass:[GDataPhotoNumberUsed class]];
  return [obj intNumberValue];
}

- (void)setPhotosUsed:(NSNumber *)num {
  GDataPhotoNumberUsed *obj = [GDataPhotoNumberUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)username {
  GDataPhotoUser *obj = [self objectForExtensionClass:[GDataPhotoUser class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataPhotoUser *obj = [GDataPhotoUser valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

- (GDataMediaGroup *)mediaGroup {
  return (GDataMediaGroup *) [self objectForExtensionClass:[GDataMediaGroup class]];
}

- (void)setMediaGroup:(GDataMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaGroup class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
