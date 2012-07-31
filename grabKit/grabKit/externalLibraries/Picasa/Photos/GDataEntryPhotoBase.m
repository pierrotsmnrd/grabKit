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
//  GDataEntryPhotoBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#define GDATAPHOTOBASE_DEFINE_GLOBALS 1
#import "GDataEntryPhotoBase.h"
#import "GDataPhotoConstants.h"

@implementation GDataEntryPhotoBase

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

// like in the Java library, we'll rename summary as description

- (GDataTextConstruct *)photoDescription {
  return [self summary]; 
}

- (void)setPhotoDescription:(GDataTextConstruct *)obj {
  [self setSummary:obj];
}

- (void)setPhotoDescriptionWithString:(NSString *)str {
  [self setSummary:[GDataTextConstruct textConstructWithString:str]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
