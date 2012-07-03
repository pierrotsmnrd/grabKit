/* Copyright (c) 2009 Google Inc.
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
//  GDataAtomCollection.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION

// a collection in a service document for introspection,
// per http://tools.ietf.org/html/rfc5023#section-8.3.3
//
// For example,
//  <app:collection href="http://photos.googleapis.com/data/feed/api/user/user%40gmail.com?v=2">
//    <atom:title>gregrobbins</atom:title>
//    <app:accept>image/jpeg</app:accept>
//    <app:accept>video/*</app:accept>
//    <app:categories fixed="yes">
//      <atom:category scheme="http://example.org/extra-cats/" term="joke" />
//    </app:categories>
//  </app:collection>

#import "GDataObject.h"
#import "GDataValueConstruct.h"

@class GDataAtomCategoryGroup;
@class GDataTextConstruct;


@interface GDataAtomAccept : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataAtomCollection : GDataObject <GDataExtension>

- (NSString *)href;
- (void)setHref:(NSString *)str;

- (GDataTextConstruct *)title;
- (void)setTitle:(GDataTextConstruct *)obj;

- (GDataAtomCategoryGroup *)categoryGroup;
- (void)setCategoryGroup:(GDataAtomCategoryGroup *)obj;

- (NSArray *)serviceAcceptStrings;
- (void)setServiceAcceptStrings:(NSArray *)array;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SERVICE_INTROSPECTION
