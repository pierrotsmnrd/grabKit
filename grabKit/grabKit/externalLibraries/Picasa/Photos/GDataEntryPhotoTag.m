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
//  GDataEntryPhotoTag.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataEntryPhotoTag.h"
#import "GDataPhotoElements.h"
#import "GDataPhotoConstants.h"

@implementation GDataEntryPhotoTag

+ (GDataEntryPhotoTag *)tagEntryWithString:(NSString *)tagStr {
  
  GDataEntryPhotoTag *entry = [self object];

  [entry setNamespaces:[GDataPhotoConstants photoNamespaces]];
  
  [entry setTitle:[GDataTextConstruct textConstructWithString:tagStr]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryPhotosTag;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // common photo extensions
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoWeight class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self weight] withName:@"weight"];
  
  return items;
}
#endif

#pragma mark -

- (NSNumber *)weight {
  // int
  GDataPhotoWeight *obj = [self objectForExtensionClass:[GDataPhotoWeight class]];
  return [obj intNumberValue];
}

- (void)setWeight:(NSNumber *)num {
  GDataPhotoWeight *obj = [GDataPhotoWeight valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
