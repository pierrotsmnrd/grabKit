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
//  GDataScope.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAACLSCOPE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataScopeTypeUser    _INITIALIZE_AS(@"user");
_EXTERN NSString* const kGDataScopeTypeDomain  _INITIALIZE_AS(@"domain");
_EXTERN NSString* const kGDataScopeTypeDefault _INITIALIZE_AS(@"default");
_EXTERN NSString* const kGDataScopeTypeGroup   _INITIALIZE_AS(@"group");


// an element with type and value attributes, as in
//  <gAcl:scope type='user' value='user@gmail.com'></gAcl:scope>
//
//  http://code.google.com/apis/calendar/reference.html#gacl_reference

@interface GDataACLScope : GDataObject <GDataExtension> 

+ (GDataACLScope *)scopeWithType:(NSString *)type value:(NSString *)value;

- (NSString *)value;
- (void)setValue:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)name;
- (void)setName:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
