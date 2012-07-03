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
//  GDataEntryACL.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#define GDATAENTRYACL_DEFINE_GLOBALS 1
#import "GDataEntryACL.h"

#import "GDataACLRole.h"
#import "GDataACLScope.h"
#import "GDataACLKeyedRole.h"

@implementation GDataEntryACL

+ (NSDictionary *)ACLNamespaces {
  NSMutableDictionary *namespaces;
  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceACL
                                                  forKey:kGDataNamespaceACLPrefix];

  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];

  return namespaces;
}

+ (id)ACLEntryWithScope:(GDataACLScope *)scope
                   role:(GDataACLRole *)role {

  GDataEntryACL *obj = [self object];
  [obj setNamespaces:[self ACLNamespaces]];
  [obj setScope:scope];
  [obj setRole:role];
  return obj;
}

+ (NSString *)standardEntryKind {
  return kGDataCategoryACL;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  // ACLEntry extensions

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataACLRole class],
   [GDataACLScope class],
   [GDataACLKeyedRole class],
   [GDataACLAdditionalRole class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"role",       @"role",            kGDataDescValueLabeled },
    { @"keyedRole",  @"keyedRole",       kGDataDescValueLabeled },
    { @"scope",      @"scope",           kGDataDescValueLabeled },
    { @"additional", @"additionalRoles", kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (void)setRole:(GDataACLRole *)obj {
  [self setObject:obj forExtensionClass:[GDataACLRole class]];
}

- (GDataACLRole *)role {
  return [self objectForExtensionClass:[GDataACLRole class]];
}

- (void)setKeyedRole:(GDataACLKeyedRole *)obj {
  [self setObject:obj forExtensionClass:[GDataACLKeyedRole class]];
}

- (GDataACLKeyedRole *)keyedRole {
  return [self objectForExtensionClass:[GDataACLKeyedRole class]];
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

- (void)setScope:(GDataACLScope *)obj {
  [self setObject:obj forExtensionClass:[GDataACLScope class]];
}

- (GDataACLScope *)scope {
  return [self objectForExtensionClass:[GDataACLScope class]];
}

#pragma mark -

- (GDataLink *)controlledObjectLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelControlledObject];
}

@end

@implementation GDataEntryBase (GDataACLLinks)
- (GDataLink *)ACLLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelACL];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
