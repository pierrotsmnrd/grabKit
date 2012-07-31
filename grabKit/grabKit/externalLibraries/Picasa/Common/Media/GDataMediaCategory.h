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
//  GDataMediaCategory.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

// like <media:category scheme="http://search.yahoo.com/mrss/category_schema" label="foo">
//             music/artist/album/song</media:category>
// http://search.yahoo.com/mrss

@interface GDataMediaCategory : GDataObject <GDataExtension> {
}

+ (GDataMediaCategory *)mediaCategoryWithString:(NSString *)str;

- (NSString *)label;
- (void)setLabel:(NSString *)str;

- (NSString *)scheme;
- (void)setScheme:(NSString *)str;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
