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
//  GDataEXIFTag.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataEXIFTags.h"
#import "GDataPhotoConstants.h"

@implementation GDataEXIFTag 

+ (NSString *)extensionElementPrefix { return kGDataNamespacePhotosEXIFPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespacePhotosEXIF; }
+ (NSString *)extensionElementLocalName { 
  // wildcard * matches all elements with the proper namespace URI
  return @"*"; 
}

#pragma mark -

+ (GDataEXIFTag *)tagWithName:(NSString *)name
                        value:(NSString *)value {
  GDataEXIFTag *obj = [GDataEXIFTag valueWithString:value];

  NSString *qualifiedName = [NSString stringWithFormat:@"%@:%@",
                             kGDataNamespacePhotosEXIFPrefix, name];
  [obj setElementName:qualifiedName];
  return obj;
}

- (NSString *)name {
  NSString *qualifiedName = [self elementName];
  NSString *localName = [NSXMLNode localNameForName:qualifiedName];
  return localName;
}

@end

@implementation GDataEXIFTags 
// for exif:tags, like 
// <exif:tags> 
//   <exif:fstop>0.0</exif:fstop>
//   <exif:make>Nokia</exif:make> 
// </exif:tags>

+ (NSString *)extensionElementURI       { return kGDataNamespacePhotosEXIF; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosEXIFPrefix; }
+ (NSString *)extensionElementLocalName { return @"tags"; }

+ (GDataEXIFTags *)EXIFTags {
  GDataEXIFTags *obj = [self object];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // media:group may contain media:content
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataEXIFTag class]];  
}


- (BOOL)isEqual:(GDataEXIFTags *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEXIFTags class]]) return NO;
  
  return [super isEqual:other];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEXIFTags* newObj = [super copyWithZone:zone];
  return newObj;
}


#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  // make an array of "name:value" items for each tag
  NSArray *tags = [self tags];
  NSEnumerator *tagsEnum = [tags objectEnumerator];
  NSMutableArray *tagsArray = [NSMutableArray array];
  GDataEXIFTag *tag;
  while ((tag = [tagsEnum nextObject]) != nil) {
    NSString *string = [NSString stringWithFormat:@"%@:%@", 
                        [tag name], [tag stringValue]];
    [tagsArray addObject:string];
  }
 
  
  [self addToArray:items
 objectDescriptionIfNonNil:[tagsArray componentsJoinedByString:@" "]
          withName:@"tags"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"exif:tags"];
  return element;
}

#pragma mark -

- (NSArray *)tags {
  NSArray *tags = [self objectsForExtensionClass:[GDataEXIFTag class]];
  return tags;
}

- (void)setTags:(NSArray *)tags {
  [self setObjects:tags forExtensionClass:[GDataEXIFTag class]];   
}

- (void)addTag:(GDataEXIFTag *)tag {
  [self addObject:tag forExtensionClass:[GDataEXIFTag class]];
}

#pragma mark -

- (GDataEXIFTag *)tagWithName:(NSString *)name {
  NSArray *tags = [self tags];
  GDataEXIFTag *tag = nil;

  for (tag in tags) {
    if (AreEqualOrBothNil([tag name], name)) {
      break;
    }
  }
  return tag;
}

- (NSString *)valueForTagName:(NSString *)name {
  return [[self tagWithName:name] stringValue];
}

- (void)removeTagWithName:(NSString *)name {
  GDataEXIFTag *tag = [self tagWithName:name];
  if (tag) {
    [self removeObject:tag forExtensionClass:[GDataEXIFTag class]]; 
  }
}

- (void)setTagWithName:(NSString *)name
             textValue:(NSString *)value {
  [self removeTagWithName:name];

  GDataEXIFTag *newTag = [GDataEXIFTag tagWithName:name value:value];

  [self addObject:newTag forExtensionClass:[GDataEXIFTag class]];
}


// EXIFTagDictionary returns a dictionary of exif tags, with
// xml element names as keys, and tag values as values.  
// This is to facilitate key-value coding access to the attributes
- (NSDictionary *)tagDictionary {
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSArray *tags = [self tags];

  // Add in reverse order so the first tag in the array wins in the case of
  // duplicates.
  for (NSInteger idx = [tags count] - 1; idx >= 0; idx--) { 
    
    GDataEXIFTag *tag = [tags objectAtIndex:idx];
    [dict setObject:[tag stringValue] forKey:[tag name]];
  }
  return dict;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
