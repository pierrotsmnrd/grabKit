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
//  GDataMediaKeywords.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"
// like <media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>
// http://search.yahoo.com/mrss

@interface GDataMediaKeywords : GDataValueElementConstruct <GDataExtension>

// array of strings
+ (GDataMediaKeywords *)keywordsWithStrings:(NSArray *)array;

// comma-separated list in a single string
+ (GDataMediaKeywords *)keywordsWithString:(NSString *)str;

- (NSArray *)keywords;
- (void)setKeywords:(NSArray *)array;
- (void)addKeyword:(NSString *)keyword;

// convenience utilities

// these are used to convert to and from the comma-separated keyword
// list in the element body
+ (NSString *)stringFromKeywords:(NSArray *)keywords;
+ (NSArray *)keywordsFromString:(NSString *)commaSeparatedString;

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
