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
//  GDataMediaPlayer.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataMediaPlayer.h"
#import "GDataMediaGroup.h"

static NSString* const kURLAttr = @"url";
static NSString* const kHeightAttr = @"height";
static NSString* const kWidthAttr = @"width";

@implementation GDataMediaPlayer
// like  <media:player url="http://www.foo.com/player?id=1111" height="200" width="400" />
//
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"player"; }

+ (GDataMediaPlayer *)mediaPlayerWithURLString:(NSString *)str {
  GDataMediaPlayer* obj = [self object];
  [obj setURLString:str];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kURLAttr, kHeightAttr, kWidthAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)URLString {
  return [self stringValueForAttribute:kURLAttr];
}

- (void)setURLString:(NSString *)str {
  [self setStringValue:str forAttribute:kURLAttr];
}

- (NSNumber *)height {
  return [self intNumberForAttribute:kHeightAttr];
}

- (void)setHeight:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kHeightAttr];
}

- (NSNumber *)width {
  return [self intNumberForAttribute:kWidthAttr];
}

- (void)setWidth:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kWidthAttr];
}


@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
