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
//  GDataFeedACL.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataFeedACL.h"

#import "GDataEntryACL.h"

@implementation GDataFeedACL

+ (id)ACLFeed {
  GDataFeedACL *feed = [self object];
  
  [feed setNamespaces:[GDataEntryACL ACLNamespaces]];
  
  return feed;
}

+ (id)ACLFeedWithXMLData:(NSData *)data {
  return [self feedWithXMLData:data];
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryACL;
}

+ (void)load {
  [self registerFeedClass];
}

- (Class)classForEntries {
  return [GDataEntryACL class];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
