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
//  GDataServiceGooglePhotos.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#define GDATASERVICEGOOGLEPHOTOS_DEFINE_GLOBALS 1
#import "GDataServiceGooglePhotos.h"
#import "GDataEntryPhotoBase.h"
#import "GDataQueryGooglePhotos.h"
#import "GDataPhotoConstants.h"

@implementation GDataServiceGooglePhotos

+ (NSURL *)photoFeedURLForUserID:(NSString *)userID
                         albumID:(NSString *)albumIDorNil
                       albumName:(NSString *)albumNameOrNil
                         photoID:(NSString *)photoIDorNil
                            kind:(NSString *)feedKindOrNil
                          access:(NSString *)accessOrNil {

  NSString *albumID = @"";
  if (albumIDorNil) {
    albumID = [NSString stringWithFormat:@"/albumid/%@",
               [GDataUtilities stringByURLEncodingForURI:albumIDorNil]];
  }

  NSString *albumName = @"";
  if (albumNameOrNil && !albumIDorNil) {
    albumName = [NSString stringWithFormat:@"/album/%@",
                 [GDataUtilities stringByURLEncodingForURI:albumNameOrNil]];
  }

  NSString *photo = @"";
  if (photoIDorNil) {
    photo = [NSString stringWithFormat:@"/photoid/%@", photoIDorNil];
  }

  // make an array for the kind and access query params, and join the arra items
  // into a query string
  NSString *query = @"";
  NSMutableArray *queryItems = [NSMutableArray array];
  if (feedKindOrNil) {
    feedKindOrNil = [GDataUtilities stringByURLEncodingStringParameter:feedKindOrNil];

    NSString *kindStr = [NSString stringWithFormat:@"kind=%@", feedKindOrNil];
    [queryItems addObject:kindStr];
  }

  if (accessOrNil) {
    accessOrNil = [GDataUtilities stringByURLEncodingStringParameter:accessOrNil];

    NSString *accessStr = [NSString stringWithFormat:@"access=%@", accessOrNil];
    [queryItems addObject:accessStr];
  }

  if ([queryItems count]) {
    NSString *queryList = [queryItems componentsJoinedByString:@"&"];

    query = [NSString stringWithFormat:@"?%@", queryList];
  }

  NSString *root = [self serviceRootURLString];

  NSString *templateStr = @"%@feed/api/user/%@%@%@%@%@";
  NSString *urlString = [NSString stringWithFormat:templateStr,
                         root, [GDataUtilities stringByURLEncodingForURI:userID],
                         albumID, albumName, photo, query];

  return [NSURL URLWithString:urlString];
}

+ (NSURL *)photoContactsFeedURLForUserID:(NSString *)userID {

  NSString *root = [self serviceRootURLString];

  NSString *templateStr = @"%@feed/api/user/%@/contacts?kind=user";

  NSString *urlString = [NSString stringWithFormat:templateStr,
                       root, [GDataUtilities stringByURLEncodingForURI:userID]];

  return [NSURL URLWithString:urlString];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"lh2";
}

+ (NSString *)serviceRootURLString {
  return @"https://photos.googleapis.com/data/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataPhotosDefaultServiceVersion;
}

+ (NSUInteger)defaultServiceUploadChunkSize {
  return kGDataStandardUploadChunkSize;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataPhotoConstants photoNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
