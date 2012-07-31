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

#import "GDataFeedPhotoBase.h"
#import "GDataPhotoConstants.h"
#import "GDataPhotoElements.h"

@implementation GDataFeedPhotoBase

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // common photo extensions
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataPhotoGPhotoID class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  [self addToArray:items objectDescriptionIfNonNil:[self GPhotoID] withName:@"gphotoID"];
  return items;
}
#endif

- (Class)classForEntries {
  return kUseRegisteredEntryClass;
}

+ (NSString *)defaultServiceVersion {
  return kGDataPhotosDefaultServiceVersion;
}

#pragma mark -

- (NSString *)GPhotoID {
  
  GDataPhotoGPhotoID *obj = [self objectForExtensionClass:[GDataPhotoGPhotoID class]];
  
  return [obj stringValue];
}

- (void)setGPhotoID:(NSString *)str {
  
  if (str) {
    GDataPhotoGPhotoID *obj = [GDataPhotoGPhotoID valueWithString:str];
    
    [self setObject:obj forExtensionClass:[GDataPhotoGPhotoID class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataPhotoGPhotoID class]];
  }
}

// like in the Java library, we'll rename subtitle as description

- (GDataTextConstruct *)photoDescription {
  return [self subtitle]; 
}

- (void)setPhotoDescription:(GDataTextConstruct *)obj {
  [self setSubtitle:obj];
}

- (void)setPhotoDescriptionWithString:(NSString *)str {
  [self setSubtitle:[GDataTextConstruct textConstructWithString:str]]; 
}

#pragma mark -

- (id)entryForGPhotoID:(NSString *)str {
  GDataEntryPhotoBase *obj;

  obj = [GDataUtilities firstObjectFromArray:[self entries]
                                   withValue:str
                                  forKeyPath:@"GPhotoID"];
  return obj;
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
