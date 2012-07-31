/* Copyright (c) 2009 Google Inc.
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
//  GDataAtomWorkspace.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION

#import "GDataAtomWorkspace.h"
#import "GDataAtomCollection.h"
#import "GDataBaseElements.h"

static NSString *const kTitleAttr = @"title";


@implementation GDataAtomWorkspace

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"workspace"; }

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAtomCollection class],
   [GDataAtomTitle class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"title",       @"title.stringValue", kGDataDescValueLabeled },
    { @"collections", @"collections",       kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (GDataTextConstruct *)title {
  return [self objectForExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (NSArray *)collections {
  NSArray *array = [self objectsForExtensionClass:[GDataAtomCollection class]];
  return array;
}

- (void)setCollections:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAtomCollection class]];
}

- (GDataAtomCollection *)primaryCollection {
  NSArray *collections = [self collections];

  if ([collections count] > 0) {
    return [collections objectAtIndex:0];
  }

  return nil;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION
