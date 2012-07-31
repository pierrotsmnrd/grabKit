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
//  GDataMediaKeywords.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataMediaKeywords.h"
#import "GDataMediaGroup.h"

@interface GDataMediaKeywords (PrivateMethods)
+ (NSString *)trimString:(NSString *)str;
@end

@implementation GDataMediaKeywords
// like <media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"keywords"; }

+ (GDataMediaKeywords *)keywordsWithStrings:(NSArray *)array {
  GDataMediaKeywords* obj = [self object];
  [obj setKeywords:array];
  return obj;
}

+ (GDataMediaKeywords *)keywordsWithString:(NSString *)str {
  // takes a string with a comma-separated list of keywords
  GDataMediaKeywords* obj = [self object];
  
  NSArray *array = [GDataMediaKeywords keywordsFromString:str];
  [obj setKeywords:array];
  return obj;
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"keywords", @"stringValue", kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSArray *)keywords {
  NSString *str = [self stringValue];
  NSArray *array = [GDataMediaKeywords keywordsFromString:str];
  return array;
}

- (void)setKeywords:(NSArray *)array {
  NSString *str = [GDataMediaKeywords stringFromKeywords:array];
  [self setStringValue:str];
}

- (void)addKeyword:(NSString *)str {
  str = [GDataMediaKeywords trimString:str];
  if ([str length] > 0) {

    NSArray *array = [self keywords];

    if ([array count] == 0) {
      // this is the first keyword
      [self setStringValue:str];
    } else {
      // check that this is not already in the array
      if (! [array containsObject:str]) {
        NSMutableArray *mutableArray = [[array mutableCopy] autorelease];
        [mutableArray addObject:str];
        [self setKeywords:mutableArray];
      }
    }
  }
}

#pragma mark Utilities

+ (NSString *)trimString:(NSString *)str {
  // remove leading and trailing whitespace from the string
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [str stringByTrimmingCharactersInSet:whitespace];
}

+ (NSArray *)keywordsFromString:(NSString *)commaSeparatedString {
  // split the words into strings at the commas
  NSArray *rawWordArray = [commaSeparatedString componentsSeparatedByString:@","];

  NSMutableArray *keywordArray = nil;
  for (NSString *word in rawWordArray) {

    // trim each word in the array, and if a trimmed word is non-empty,
    // add it to the array
    NSString *trimmedWord = [GDataMediaKeywords trimString:word];
    if ([trimmedWord length] > 0) {

      if (keywordArray == nil) {
        keywordArray = [NSMutableArray array];
      }
      [keywordArray addObject:trimmedWord];
    }
  }

  return keywordArray;
}

+ (NSString *)stringFromKeywords:(NSArray *)keywords {
  // join keywords with commas; return the string if it's non-empty,
  // or nil otherwise
  if ([keywords count] > 0) {
    return [keywords componentsJoinedByString:@", "];
  }
  return nil;
}
@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
