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
//  GDataMediaPlayer.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

// like <media:player url="http://www.foo.com/player?id=1111" height="200" width="400" />
//
// http://search.yahoo.com/mrss

@interface GDataMediaPlayer : GDataObject <GDataExtension> {
}

+ (GDataMediaPlayer *)mediaPlayerWithURLString:(NSString *)str;

- (NSString *)URLString;
- (void)setURLString:(NSString *)str;

- (NSNumber *)height; // int
- (void)setHeight:(NSNumber *)num;

- (NSNumber *)width; // int
- (void)setWidth:(NSNumber *)num;  
@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
