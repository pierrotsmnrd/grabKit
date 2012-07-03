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
//  GDataFeedPhotoBase.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataFeedBase.h"

@class GDataEntryPhotoBase;

@interface GDataFeedPhotoBase : GDataFeedBase {
}


- (Class)classForEntries;


- (NSString *)GPhotoID;
- (void)setGPhotoID:(NSString *)str;

// like in the Java library, we'll rename subtitle as description
- (GDataTextConstruct *)photoDescription;
- (void)setPhotoDescription:(GDataTextConstruct *)obj;
- (void)setPhotoDescriptionWithString:(NSString *)str;

// convenience accessors
- (id)entryForGPhotoID:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
