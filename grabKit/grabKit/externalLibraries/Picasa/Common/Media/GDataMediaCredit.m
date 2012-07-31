/* Copyright (c) 2007-2008 Google Inc.
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
//  GDataMediaCredit.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataMediaCredit.h"
#import "GDataMediaGroup.h"

static NSString* const kSchemeAttr = @"scheme";
static NSString* const kRoleAttr = @"role";

@implementation GDataMediaCredit
// like <media:credit role="producer" scheme="urn:ebu">entity name</media:credit>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"credit"; }

+ (GDataMediaCredit *)mediaCreditWithString:(NSString *)str {
  GDataMediaCredit* obj = [self object];
  [obj setStringValue:str];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kRoleAttr, kSchemeAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
  
  [self addContentValueDeclaration];
}

- (NSString *)role {
  return [self stringValueForAttribute:kRoleAttr];
}

- (void)setRole:(NSString *)str {
  [self setStringValue:str forAttribute:kRoleAttr];
}

- (NSString *)scheme {
  return [self stringValueForAttribute:kSchemeAttr];
}

- (void)setScheme:(NSString *)str {
  [self setStringValue:str forAttribute:kSchemeAttr];
}

- (NSString *)stringValue {
  return [self contentStringValue];
}

- (void)setStringValue:(NSString *)str {
  [self setContentStringValue:str];
}

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
