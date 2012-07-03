/* Copyright (c) 2008 Google Inc.
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
//  GDataMediaRestriction.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataMediaRestriction.h"
#import "GDataMediaGroup.h"

static NSString* const kRelationshipAttr = @"relationship";
static NSString* const kTypeAttr = @"type";

@implementation GDataMediaRestriction
// like <media:restriction relationship="allow" type="country">au us</media:restriction>
//
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"restriction"; }

+ (GDataMediaRestriction *)mediaRestrictionWithString:(NSString *)str
                                         relationship:(NSString *)rel
                                                 type:(NSString *)type {
  GDataMediaRestriction* obj = [self object];
  [obj setStringValue:str];
  [obj setRelationship:rel];
  [obj setType:type];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kRelationshipAttr, kTypeAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
  
  [self addContentValueDeclaration];
}

- (NSString *)relationship {
  return [self stringValueForAttribute:kRelationshipAttr];
}

- (void)setRelationship:(NSString *)str {
  [self setStringValue:str forAttribute:kRelationshipAttr];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (NSString *)stringValue {
  return [self contentStringValue];
}

- (void)setStringValue:(NSString *)str {
  [self setContentStringValue:str];
}
@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
