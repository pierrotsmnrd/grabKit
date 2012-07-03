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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

//  Time specification object which tries to conform to section 3.6
//  of RFC 2326 (Normal Play Time).  http://www.ietf.org/rfc/rfc2326.txt
//
//  It does not support ranges.
//
//  It only supports a millisecond precision. Any time more precise than
//  that will be lost when parsing.

@interface GDataNormalPlayTime : NSObject {
  long long ms_;
  BOOL isNow_;
}

+ (GDataNormalPlayTime *)normalPlayTimeWithString:(NSString *)str;

- (long long)timeOffsetInMilliseconds; // -1 if "now"
- (void)setTimeOffsetInMilliseconds:(long long)ms;

- (BOOL)isNow;
- (void)setIsNow:(BOOL)isNow;

- (NSString *)HHMMSSString;  // hh:mm:ss.fraction or "now"
- (NSString *)secondsString; // seconds.fraction or "now"

- (void)setFromString:(NSString *)str;
@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
