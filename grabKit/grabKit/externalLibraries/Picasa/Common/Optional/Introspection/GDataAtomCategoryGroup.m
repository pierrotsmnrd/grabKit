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
//  GDataAtomCategoryGroup.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION

#import "GDataAtomCategoryGroup.h"
#import "GDataCategory.h"

static NSString* const kHrefAttr = @"href";
static NSString* const kSchemeAttr = @"scheme";
static NSString* const kFixedAttr = @"fixed";

@implementation GDataAtomCategoryGroup
// a collection in a service document for introspection,
// per http://tools.ietf.org/html/rfc5023#section-7.2
//
//  <categories fixed="yes">
//    <atom:category scheme="http://example.org/extra-cats/" term="joke" />
//    <atom:category scheme="http://example.org/extra-cats/" term="serious" />
//  </categories>
//
//  or
//
//  <categories href="http://example.com/cats/forMain.cats" />

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"categories"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kHrefAttr, kSchemeAttr, kFixedAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataCategory class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"fixed",      @"isFixed",    kGDataDescBooleanPresent },
    { @"href",       @"href",       kGDataDescValueLabeled },
    { @"scheme",     @"scheme",     kGDataDescValueLabeled },
    { @"categories", @"categories", kGDataDescArrayDescs },
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

- (NSString *)scheme {
  return [self stringValueForAttribute:kSchemeAttr];
}

- (void)setScheme:(NSString *)str {
  [self setStringValue:str forAttribute:kSchemeAttr];
}

- (BOOL)isFixed {
  // absence of the fixed attribute means no
  NSString *str = [self stringValueForAttribute:kFixedAttr];
  if (str == nil) return NO;

  return ([str caseInsensitiveCompare:@"yes"] == NSOrderedSame);
}

- (void)setIsFixed:(BOOL)flag {
  [self setStringValue:(flag ? @"yes" : nil) forAttribute:kFixedAttr];
}

- (NSArray *)categories {
  return [self objectsForExtensionClass:[GDataCategory class]];
}

- (void)setCategories:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCategory class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION
