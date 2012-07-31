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
//  GDataQueryGooglePhotos.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#define GDATAQUERYGOOGLEPHOTOS_DEFINE_GLOBALS 1
#import "GDataQueryGooglePhotos.h"

#import "GDataServiceGooglePhotos.h"

static NSString *const kKindParamName = @"kind";
static NSString *const kAccessParamName = @"access";
static NSString *const kThumbsizeParamName = @"thumbsize";
static NSString *const kImageSizeParamName = @"imgmax";
static NSString *const kTagParamName = @"tag";

static NSString *const kImageSizeOriginalPhoto = @"d";

@implementation GDataQueryGooglePhotos

+ (GDataQueryGooglePhotos *)photoQueryWithFeedURL:(NSURL *)feedURL {
  return [self queryWithFeedURL:feedURL];   
}

+ (GDataQueryGooglePhotos *)photoQueryForUserID:(NSString *)userID
                                        albumID:(NSString *)albumIDorNil
                                      albumName:(NSString *)albumNameOrNil
                                        photoID:(NSString *)photoIDorNil {  
  NSURL *url;
  url = [GDataServiceGooglePhotos photoFeedURLForUserID:userID
                                                albumID:albumIDorNil
                                              albumName:albumNameOrNil
                                                photoID:photoIDorNil
                                                   kind:nil
                                                 access:nil];
  return [self photoQueryWithFeedURL:url];
}

- (NSString *)stringParamOrNilForInt:(NSInteger)val {
  if (val > 0) {
    return [NSString stringWithFormat:@"%ld", (long)val]; 
  }
  return nil;
}

- (void)setThumbsize:(NSInteger)val {
  [self addCustomParameterWithName:kThumbsizeParamName
                             value:[self stringParamOrNilForInt:val]];
}

- (NSInteger)thumbsize {
  return [self intValueForParameterWithName:kThumbsizeParamName
                      missingParameterValue:0];
}

- (void)setKind:(NSString *)str {
  [self addCustomParameterWithName:kKindParamName
                             value:str];
}

- (NSString *)kind {
  return [self valueForParameterWithName:kKindParamName];
}

- (void)setAccess:(NSString *)str {
  [self addCustomParameterWithName:kAccessParamName
                             value:str];
}

- (NSString *)access {
  return [self valueForParameterWithName:kAccessParamName];
}

- (void)setImageSize:(NSInteger)val {
  NSString *valStr;
  
  if (val == kGDataGooglePhotosImageSizeDownloadable) {
    valStr = kImageSizeOriginalPhoto; // imgmax=d
  } else {
    valStr = [self stringParamOrNilForInt:val];
  }
  
  [self addCustomParameterWithName:kImageSizeParamName
                             value:valStr]; 
}

- (NSInteger)imageSize {
  NSString *valStr = [self valueForParameterWithName:kImageSizeParamName];
  
  if ([valStr isEqual:kImageSizeOriginalPhoto]) {
    return kGDataGooglePhotosImageSizeDownloadable;
  }
  return [valStr intValue];
}

- (void)setTag:(NSString *)str {
  [self addCustomParameterWithName:kTagParamName
                             value:str];
}

- (NSString *)tag {
  return [self valueForParameterWithName:kTagParamName];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
