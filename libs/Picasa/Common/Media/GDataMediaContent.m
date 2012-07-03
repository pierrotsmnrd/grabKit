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
//  GDataMediaContent.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataMediaContent.h"
#import "GDataMediaGroup.h"

static NSString* const kURLAttr = @"url";
static NSString* const kFileSizeAttr = @"fileSize";
static NSString* const kTypeAttr = @"type";
static NSString* const kMediumAttr = @"medium";
static NSString* const kIsDefaultAttr = @"isDefault";
static NSString* const kExpressionAttr = @"expression";
static NSString* const kBitrateAttr = @"bitrate";
static NSString* const kFramerateAttr = @"framerate";
static NSString* const kSamplingRateAttr = @"samplingrate";
static NSString* const kChannelsAttr = @"channels";
static NSString* const kDurationAttr = @"duration";
static NSString* const kHeightAttr = @"height";
static NSString* const kWidthAttr = @"width";
static NSString* const kLangAttr = @"lang";

@implementation GDataMediaContent
// media:content element
//
//  <media:content 
//    url="http://www.foo.com/movie.mov" 
//    fileSize="12216320" 
//    type="video/quicktime"
//    medium="video"
//    isDefault="true" 
//    expression="full" 
//    bitrate="128" 
//    framerate="25"
//    samplingrate="44.1"
//    channels="2"
//    duration="185" 
//    height="200"
//    width="300" 
//    lang="en" />
//
// http://search.yahoo.com/mrss


+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"content"; }

+ (GDataMediaContent *)mediaContentWithURLString:(NSString *)urlString {
  
  GDataMediaContent *obj = [self object];
  [obj setURLString:urlString];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kURLAttr, kFileSizeAttr, kTypeAttr, 
                    kMediumAttr, kIsDefaultAttr, kExpressionAttr, 
                    kBitrateAttr, kFramerateAttr, kSamplingRateAttr,
                    kChannelsAttr, kDurationAttr, kHeightAttr, kWidthAttr,
                    kLangAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)URLString {
  return [self stringValueForAttribute:kURLAttr];
}
- (void)setURLString:(NSString *)str {
  [self setStringValue:str forAttribute:kURLAttr];
}

- (NSNumber *)fileSize {
  return [self longLongNumberForAttribute:kFileSizeAttr];
}
- (void)setFileSize:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kFileSizeAttr];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}
- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (NSString *)medium {
  return [self stringValueForAttribute:kMediumAttr];
}
- (void)setMedium:(NSString *)str {
  [self setStringValue:str forAttribute:kMediumAttr];
}

- (NSNumber *)isDefault {
  BOOL flag = [self boolValueForAttribute:kIsDefaultAttr defaultValue:NO];
  return flag ? [NSNumber numberWithBool:flag] : nil; 
}
- (void)setIsDefault:(NSNumber *)num {
  BOOL flag = [num boolValue];
  [self setBoolValue:flag defaultValue:NO forAttribute:kIsDefaultAttr];
}

- (NSString *)expression {
  return [self stringValueForAttribute:kExpressionAttr];
}
- (void)setExpression:(NSString *)str {
  [self setStringValue:str forAttribute:kExpressionAttr];
}

- (NSDecimalNumber *)bitrate {
  return [self decimalNumberForAttribute:kBitrateAttr];
}
- (void)setBitrate:(NSDecimalNumber *)num {
  [self setDecimalNumberValue:num forAttribute:kBitrateAttr];
}

- (NSDecimalNumber *)framerate {
  return [self decimalNumberForAttribute:kFramerateAttr];
}
- (void)setFramerate:(NSDecimalNumber *)num {
  [self setDecimalNumberValue:num forAttribute:kFramerateAttr];
}

- (NSDecimalNumber *)samplingrate {
  return [self decimalNumberForAttribute:kSamplingRateAttr];
}
- (void)setSamplingrate:(NSDecimalNumber *)num {
  [self setDecimalNumberValue:num forAttribute:kSamplingRateAttr];
}

- (NSNumber *)channels {
  return [self intNumberForAttribute:kChannelsAttr];
}
- (void)setChannels:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kChannelsAttr];
}

- (NSNumber *)duration {
  return [self intNumberForAttribute:kDurationAttr];
}
- (void)setDuration:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kDurationAttr];
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

- (NSString *)lang {
  return [self stringValueForAttribute:kLangAttr]; 
}
- (void)setLang:(NSString *)str {
  [self setStringValue:str forAttribute:kLangAttr];
}

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
