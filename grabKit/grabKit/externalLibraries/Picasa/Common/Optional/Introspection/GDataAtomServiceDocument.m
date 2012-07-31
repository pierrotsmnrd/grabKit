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
//  GDataAtomServiceDocument.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION

// app:service, an Atom service document,
// per http://tools.ietf.org/html/rfc5023#section-8.3.1

#import "GDataAtomServiceDocument.h"
#import "GDataAtomWorkspace.h"

@implementation GDataAtomServiceDocument

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataAtomWorkspace class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"workspaces", @"workspaces", kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSArray *)workspaces {
  NSArray *array = [self objectsForExtensionClass:[GDataAtomWorkspace class]];
  return array;
}

- (void)setWorkspaces:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAtomWorkspace class]];
}

- (GDataAtomWorkspace *)primaryWorkspace {
  NSArray *workspaces = [self workspaces];

  if ([workspaces count] > 0) {
    return [workspaces objectAtIndex:0];
  }

  return nil;
}

+ (NSString *)defaultServiceVersion {
  return @"2.0";
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION
