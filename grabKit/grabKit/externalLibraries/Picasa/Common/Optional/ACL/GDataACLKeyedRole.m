/* Copyright (c) 2010 Google Inc.
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
//  GDataACLRole.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataACLKeyedRole.h"

#import "GDataEntryACL.h" // for namespace

static NSString* const kKeyAttr = @"key";

@implementation GDataACLKeyedRole

// a key which specifies a role, such as
//
//  <gAcl:withKey key="A123B">
//    <gAcl:role value='owner'></gAcl:role>
//  </gAcl:withKey>

+ (NSString *)extensionElementURI       { return kGDataNamespaceACL; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceACLPrefix; }
+ (NSString *)extensionElementLocalName { return @"withKey"; }

+ (GDataACLKeyedRole *)keyedRoleWithKey:(NSString *)key
                                  value:(NSString *)value {
  GDataACLKeyedRole *obj = [self object];
  [obj setKey:key];
  [obj setRole:[GDataACLRole roleWithValue:value]];
  return obj;
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  // this element may contain a gAcl:role element
  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataACLRole class],
   [GDataACLAdditionalRole class],
   nil];
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObject:kKeyAttr];
  [self addLocalAttributeDeclarations:attrs];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"role",       @"role",            kGDataDescValueLabeled },
    { @"additional", @"additionalRoles", kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)key {
  return [self stringValueForAttribute:kKeyAttr];
}

- (void)setKey:(NSString *)str {
  [self setStringValue:str forAttribute:kKeyAttr];
}

#pragma mark -

- (GDataACLRole *)role {
  return [self objectForExtensionClass:[GDataACLRole class]];
}

- (void)setRole:(GDataACLRole *)obj {
  [self setObject:obj forExtensionClass:[GDataACLRole class]];
}

- (NSArray *)additionalRoles {
  return [self objectsForExtensionClass:[GDataACLAdditionalRole class]];
}

- (void)setAdditionalRoles:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataACLAdditionalRole class]];
}

- (void)addAdditionalRole:(GDataACLAdditionalRole *)obj {
  [self addObject:obj forExtensionClass:[GDataACLAdditionalRole class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
