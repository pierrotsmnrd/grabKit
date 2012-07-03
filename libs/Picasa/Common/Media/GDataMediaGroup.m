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
//  GDataMediaGroup.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATAMEDIAGROUP_DEFINE_GLOBALS 1
#import "GDataMediaGroup.h"

#import "GDataMediaContent.h"
#import "GDataMediaCredit.h"
#import "GDataMediaPlayer.h"
#import "GDataMediaThumbnail.h"
#import "GDataMediaKeywords.h"
#import "GDataMediaCategory.h"
#import "GDataMediaRating.h"
#import "GDataMediaRestriction.h"

// we'll define MediaDescription and MediaTitle here, since they're
// just derived classes of GDataTextConstruct

@implementation GDataMediaDescription
+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"description"; }
@end

@implementation GDataMediaTitle
+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"title"; }
@end


@implementation GDataMediaGroup
// for media:group, like 
// <media:group> <media:contents  ... /> </media:group>

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"group"; }

#pragma mark -

+ (id)mediaGroup {
  GDataMediaGroup *obj = [self object];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataMediaContent class],
   [GDataMediaCategory class],
   [GDataMediaCredit class],
   [GDataMediaDescription class],
   [GDataMediaPlayer class],
   [GDataMediaRating class],
   [GDataMediaRestriction class],
   [GDataMediaThumbnail class],
   [GDataMediaKeywords class],
   [GDataMediaTitle class],
   nil];  
  
  // still unsupported:
  // MediaCopyright, MediaHash, MediaText
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"categories",  @"mediaCategories",  kGDataDescArrayDescs   },
    { @"contents",    @"mediaContents",    kGDataDescArrayDescs   },
    { @"credits",     @"mediaCredits",     kGDataDescArrayDescs   },
    { @"thumbnails",  @"mediaThumbnails",  kGDataDescArrayDescs   },
    { @"keywords",    @"mediaKeywords",    kGDataDescValueLabeled },
    { @"description", @"mediaDescription", kGDataDescValueLabeled },
    { @"players",     @"mediaPlayers",     kGDataDescArrayDescs   },
    { @"ratings",     @"mediaRatings",     kGDataDescArrayDescs   },
    { @"title",       @"mediaTitle",       kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

// there are many more possible extensions; see MediaGroup.java
//
// Initially, we're just supporting the ones needed for Google Photos

// MediaCategories

- (NSArray *)mediaCategories {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaCategory class]];
  return array;
}

- (void)setMediaCategories:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaCategory class]]; 
}

- (void)addMediaCategory:(GDataMediaCategory *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaCategory class]]; 
}

// MediaContents

- (NSArray *)mediaContents {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaContent class]];
  return array;
}

- (void)setMediaContents:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaContent class]]; 
}

- (void)addMediaContent:(GDataMediaContent *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaContent class]]; 
}

// MediaCredits

- (NSArray *)mediaCredits {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaCredit class]];
  return array;
}

- (void)setMediaCredits:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaCredit class]]; 
}

- (void)addMediaCredit:(GDataMediaCredit *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaCredit class]]; 
}

// MediaPlayers

- (NSArray *)mediaPlayers {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaPlayer class]];
  return array;
}

- (void)setMediaPlayers:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaPlayer class]]; 
}

- (void)addMediaPlayer:(GDataMediaPlayer *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaPlayer class]]; 
}

// MediaRatings

- (NSArray *)mediaRatings {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaRating class]];
  return array;
}

- (void)setMediaRatings:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaRating class]]; 
}

- (void)addMediaRating:(GDataMediaRating *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaRating class]]; 
}

// MediaRatings

- (NSArray *)mediaRestrictions {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaRestriction class]];
  return array;
}

- (void)setMediaRestrictions:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaRestriction class]]; 
}

- (void)addMediaRestriction:(GDataMediaRestriction *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaRestriction class]]; 
}

// MediaThumbnails

- (NSArray *)mediaThumbnails {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaThumbnail class]];
  return array;
}

- (void)setMediaThumbnails:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaThumbnail class]]; 
}

- (void)addMediaThumbnail:(GDataMediaThumbnail *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaThumbnail class]]; 
}

// MediaKeywords

- (GDataMediaKeywords *)mediaKeywords {
  GDataMediaKeywords *obj = 
      [self objectForExtensionClass:[GDataMediaKeywords class]];
  return obj;
}

- (void)setMediaKeywords:(GDataMediaKeywords *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaKeywords class]]; 
}

// MediaDescription

- (GDataMediaDescription *)mediaDescription {
  GDataMediaDescription *obj = 
      [self objectForExtensionClass:[GDataMediaDescription class]];
  return obj;
}

- (void)setMediaDescription:(GDataMediaDescription *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaDescription class]]; 
}

// MediaTitle

- (GDataMediaTitle *)mediaTitle {
  GDataMediaTitle *obj =
    [self objectForExtensionClass:[GDataMediaTitle class]];
  return obj;
}

- (void)setMediaTitle:(GDataMediaTitle *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaTitle class]]; 
}

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
