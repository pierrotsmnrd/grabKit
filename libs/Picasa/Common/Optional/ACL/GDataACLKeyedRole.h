/* Copyright (c) 2010 Google Inc.
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
//  GDataKeyedRole.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataObject.h"
#import "GDataACLRole.h"

// a key which specifies a role, such as
//
//  <gAcl:withKey key="A123B">
//    <gAcl:role value='owner'></gAcl:role>
//  </gAcl:withKey>

@interface GDataACLKeyedRole : GDataObject <GDataExtension>
+ (GDataACLKeyedRole *)keyedRoleWithKey:(NSString *)key
                                  value:(NSString *)value;

- (NSString *)key;
- (void)setKey:(NSString *)str;

- (GDataACLRole *)role;
- (void)setRole:(GDataACLRole *)obj;

- (NSArray *)additionalRoles;
- (void)setAdditionalRoles:(NSArray *)array;
- (void)addAdditionalRole:(GDataACLAdditionalRole *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
