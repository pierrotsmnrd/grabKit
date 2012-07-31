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
//  GDataExifTags.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"

//
// an exif tag, like <exif:name>value</exif:name>
//
@interface GDataEXIFTag : GDataValueElementConstruct <GDataExtension>

+ (GDataEXIFTag *)tagWithName:(NSString *)name
                            value:(NSString *)value;
- (NSString *)name;

@end

//
// a group of exif tags, like 
//
// <exif:tags> 
//   <exif:fstop>0.0</exif:fstop>
//   <exif:make>Nokia</exif:make> 
// </exif:tags>
//

@interface GDataEXIFTags : GDataObject <NSCopying, GDataExtension> {
}

+ (GDataEXIFTags *)EXIFTags;

- (NSArray *)tags;
- (void)setTags:(NSArray *)tags;
- (void)addTag:(GDataEXIFTag *)tag;

// utilities for accessing individual tags
- (NSString *)valueForTagName:(NSString *)name;
- (void)removeTagWithName:(NSString *)name;
- (void)setTagWithName:(NSString *)name
                 textValue:(NSString *)value;

// tagDictionary returns a dictionary of exif tags, with
// tag names as keys, and tag values as objects.  
// This is to facilitate key-value coding access to the tags.
- (NSDictionary *)tagDictionary;


@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
