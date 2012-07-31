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
//  GDataAtomCollection.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION

#import "GDataAtomCollection.h"
#import "GDataAtomCategoryGroup.h"
#import "GDataBaseElements.h"

static NSString* const kHrefAttr = @"href";
static NSString *const kTitleAttr = @"title";


@implementation GDataAtomAccept
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"accept"; }
@end


@implementation GDataAtomCollection
// a collection in a service document for introspection,
// per http://tools.ietf.org/html/rfc5023#section-8.3.3
//
// For example,
//  <app:collection href="http://photos.googleapis.com/data/feed/api/user/user%40gmail.com?v=2">
//    <atom:title>gregrobbins</atom:title>
//    <app:accept>image/jpeg</app:accept>
//    <app:accept>video/*</app:accept>
//    <app:categories fixed="yes">
//      <atom:category scheme="http://example.org/extra-cats/" term="joke" />
//    </app:categories>
//  </app:collection>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"collection"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObject:kHrefAttr];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAtomCategoryGroup class],
   [GDataAtomAccept class],
   [GDataAtomTitle class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"title",         @"title.stringValue",    kGDataDescValueLabeled },
    { @"href",          @"href",                 kGDataDescValueLabeled },
    { @"categoryGroup", @"categoryGroup",        kGDataDescValueLabeled },
    { @"accepts",       @"serviceAcceptStrings", kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)href {
  return [self stringValueForAttribute:kHrefAttr];
}

- (void)setHref:(NSString *)str {
  [self setStringValue:str forAttribute:kHrefAttr];
}

- (GDataTextConstruct *)title {
  return [self objectForExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (GDataAtomCategoryGroup *)categoryGroup {
  return [self objectForExtensionClass:[GDataAtomCategoryGroup class]];
}

- (void)setCategoryGroup:(GDataAtomCategoryGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomCategoryGroup class]];
}

- (NSArray *)serviceAcceptStrings {
  NSArray *acceptObjs;

  acceptObjs = [self objectsForExtensionClass:[GDataAtomAccept class]];

  if ([acceptObjs count] > 0) {
    // using KVC, make an array of the strings in each accept element
    return [acceptObjs valueForKey:@"stringValue"];
  }
  return nil;
}

- (void)setServiceAcceptStrings:(NSArray *)array {
  NSMutableArray *objArray = nil;

  // make an accept object for each string in the array
  NSUInteger numberOfStrings = [array count];
  if (numberOfStrings > 0) {

    objArray = [NSMutableArray arrayWithCapacity:numberOfStrings];

    for (NSString *str in array) {
      [objArray addObject:[GDataAtomAccept valueWithString:str]];
    }
  }

  // if objArray is still nil, the extensions will be removed
  [self setObjects:objArray forExtensionClass:[GDataAtomAccept class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION
