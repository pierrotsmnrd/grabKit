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
//  GDataMediaRestriction.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

// like <media:restriction relationship="allow" type="country">au us</media:restriction>
//
// http://search.yahoo.com/mrss

@interface GDataMediaRestriction : GDataObject <GDataExtension> {
}

+ (GDataMediaRestriction *)mediaRestrictionWithString:(NSString *)str
                                         relationship:(NSString *)rel
                                                 type:(NSString *)type;

- (NSString *)relationship;
- (void)setRelationship:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
