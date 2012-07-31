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
//  GDataMediaContent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

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

@interface GDataMediaContent : GDataObject <GDataExtension>

+ (GDataMediaContent *)mediaContentWithURLString:(NSString *)urlString;


- (NSString *)URLString;
- (void)setURLString:(NSString *)str;

- (NSNumber *)fileSize; // long long
- (void)setFileSize:(NSNumber *)num;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)medium;
- (void)setMedium:(NSString *)str;

- (NSNumber *)isDefault; // bool
- (void)setIsDefault:(NSNumber *)num;

- (NSString *)expression;
- (void)setExpression:(NSString *)str;

- (NSDecimalNumber *)bitrate;
- (void)setBitrate:(NSDecimalNumber *)num;

- (NSDecimalNumber *)framerate;
- (void)setFramerate:(NSDecimalNumber *)num;

- (NSDecimalNumber *)samplingrate;
- (void)setSamplingrate:(NSDecimalNumber *)num;

- (NSNumber *)channels; // int
- (void)setChannels:(NSNumber *)num;

- (NSNumber *)duration; // int
- (void)setDuration:(NSNumber *)num;

- (NSNumber *)height; // int
- (void)setHeight:(NSNumber *)num;

- (NSNumber *)width; // int
- (void)setWidth:(NSNumber *)num;

- (NSString *)lang; // int
- (void)setLang:(NSString *)str;
@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
