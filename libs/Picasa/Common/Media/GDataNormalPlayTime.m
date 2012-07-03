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

#import "GDataNormalPlayTime.h"

static NSString* const kNowString = @"now";

@implementation GDataNormalPlayTime

+ (GDataNormalPlayTime *)normalPlayTimeWithString:(NSString *)str {
  
  GDataNormalPlayTime *npt = [[[GDataNormalPlayTime alloc] init] autorelease];
  
  [npt setFromString:str];
  return npt;
}

- (long long)timeOffsetInMilliseconds { // -1 if "now"
  if (isNow_) return -1;
  return ms_;
}

- (void)setTimeOffsetInMilliseconds:(long long)ms {
  ms_ = ms;
  isNow_ = (ms == -1);
}

- (BOOL)isNow {
  return isNow_; 
}

- (void)setIsNow:(BOOL)isNow {
  isNow_ = isNow; 
}

- (NSString *)HHMMSSString { // hh:mm:ss.fraction or "now"
  if (isNow_) {
    return kNowString;
  }
  
  long fractional = (long) (ms_ % 1000LL);
  long totalSeconds = (long) (ms_ / 1000LL);
  long seconds = totalSeconds % 60L;
  long totalMinutes = totalSeconds / 60L;
  long minutes = totalMinutes % 60L;
  long hours = totalMinutes / 60L;
  
  if (fractional > 0) {
    return [NSString stringWithFormat:@"%ld:%02ld:%02ld.%03ld",
      hours, minutes, seconds, fractional];
  } 
  return [NSString stringWithFormat:@"%ld:%02ld:%02ld",
    hours, minutes, seconds];
}

- (NSString *)secondsString { // seconds.fraction or "now"
  if (isNow_) {
    return kNowString;
  }
  int seconds = (int) (ms_ / 1000LL);
  int fractional = (int) (ms_ % 1000LL);
  
  if (fractional == 0) {
    return [NSString stringWithFormat:@"%d", seconds];
  }
  return [NSString stringWithFormat:@"%d.%03d", seconds, fractional];
}

- (void)setFromString:(NSString *)str {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *trimmedStr = [str stringByTrimmingCharactersInSet:whitespace];
  
  // handle "now"
  if ([trimmedStr caseInsensitiveCompare:@"now"] == NSOrderedSame) {
    isNow_ = YES;
    ms_ = -1;
    return;
  }
  
  // parse hh:mm:ss.fff or ss.fff into milliseconds
  long seconds = 0;
  long thousandths = 0;
  
  NSScanner *scanner = [NSScanner scannerWithString:str];
  NSCharacterSet *period = [NSCharacterSet characterSetWithCharactersInString:@"."];
  NSCharacterSet *colon = [NSCharacterSet characterSetWithCharactersInString:@":"];
  
  int scannedInt;
  if ([scanner scanInt:&scannedInt]) {
    seconds = scannedInt;
    
    if ([scanner scanCharactersFromSet:colon intoString:NULL]
        && [scanner scanInt:&scannedInt]) {
      // push seconds to minutes
      seconds = seconds * 60 + scannedInt;
    }
  
    if ([scanner scanCharactersFromSet:colon intoString:NULL]
        && [scanner scanInt:&scannedInt]) {
      // push minutes to hours, seconds to minutes
      seconds = seconds * 60 + scannedInt;
    }
    
    if ([scanner scanCharactersFromSet:period intoString:NULL]
        && [scanner scanInt:&scannedInt]) {
      
      // append 000 and take the first 3 digits to create thousands
      NSString *paddedFraction = [NSString stringWithFormat:@"%d000", scannedInt];
      NSString *thousandthsStr = [paddedFraction substringToIndex:3];
      thousandths = [thousandthsStr intValue];
    }
  }    
  ms_ = seconds * 1000 + thousandths;
  isNow_ = NO;
}

- (BOOL)isEqual:(GDataNormalPlayTime *)other {
  if ([self isNow]) {
    return ([self isNow] == [other isNow]);
  }
  return ([self timeOffsetInMilliseconds] == [other timeOffsetInMilliseconds]);
}

- (id)copyWithZone:(NSZone *)zone {
  GDataNormalPlayTime* newObj = [[[self class] allocWithZone:zone] init];
  [newObj setTimeOffsetInMilliseconds:[self timeOffsetInMilliseconds]];
  [newObj setIsNow:[self isNow]];
  return newObj;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ %p: {%@}",
    [self class], self, [self HHMMSSString]];

}

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
