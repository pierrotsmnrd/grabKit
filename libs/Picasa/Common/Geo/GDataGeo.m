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
//  GDataGeo.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE \
  || GDATA_INCLUDE_PHOTOS_SERVICE || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATAGEO_DEFINE_GLOBALS 1
#import "GDataGeo.h"
#include <math.h>

// http://www.w3.org/2003/01/geo/
// xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
//  <geo:Point>
//    <geo:lat>55.701</geo:lat>
//    <geo:long>12.552</geo:long>
//  </geo:Point>

@implementation GDataGeoW3CPoint
+ (NSString *)extensionElementURI       { return kGDataNamespaceGeoW3C; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGeoW3CPrefix; }
+ (NSString *)extensionElementLocalName { return @"Point"; }

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSXMLElement *latElem = [self childWithQualifiedName:@"geo:lat"
                                            namespaceURI:[element URI]
                                             fromElement:element];
    NSNumber *latNum = [self doubleNumberValueFromElement:latElem];

    NSXMLElement *longElem = [self childWithQualifiedName:@"geo:long"
                                             namespaceURI:[element URI]
                                              fromElement:element];
    NSNumber *longNum = [self doubleNumberValueFromElement:longElem];

    if (latNum && longNum) {
      [self setValues:[NSArray arrayWithObjects:latNum, longNum, nil]];
    }
  }
  return self;
}


- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"geo:Point"];
  NSArray *values = [self values];

  if ([self isPoint]) {
    NSNumber *latNum = [values objectAtIndex:0];
    NSNumber *longNum = [values objectAtIndex:1];

    // prefix is probably "geo" but it doesn't hurt to be dynamic
    NSString *nameFromXML = [self elementName];
    NSString *prefix = kGDataNamespaceGeoW3CPrefix;
    if (nameFromXML) {
      prefix = [NSXMLNode prefixForName:nameFromXML];
    }

    NSString *latName = [NSString stringWithFormat:@"%@:lat", prefix];
    NSString *longName = [NSString stringWithFormat:@"%@:long", prefix];

    [self addToElement:element
childWithStringValueIfNonEmpty:[latNum stringValue]
              withName:latName];

    [self addToElement:element
childWithStringValueIfNonEmpty:[longNum stringValue]
              withName:longName];
  }
  return element;
}

@end

// GeoRSS simple point http://www.georss.org/
//
// <georss:point>45.256 -71.92</georss:point>

@implementation GDataGeoRSSPoint
+ (NSString *)extensionElementURI       { return kGDataNamespaceGeoRSS; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGeoRSSPrefix; }
+ (NSString *)extensionElementLocalName { return @"point"; }

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {

    NSString *valueListStr = [self stringValueFromElement:element];
    if ([valueListStr length] > 0) {

      NSArray *values = [GDataGeo valuesWithCoordinateString:valueListStr];
      if ([values count] > 0) {

        [self setValues:values];
      }
    }
  }
  return self;
}


- (NSXMLElement *)XMLElement {

  // our superclass defaults to making a georss:point, so we'll call that
  return [super XMLElement];
}

@end

// GeoRSS gml:Point http://www.georss.org/gml.html
//
//  <georss:where>
//    <gml:Point>
//      <gml:pos>45.256 -110.45</gml:pos>
//    </gml:Point>
//  </georss:where>
//
// Note: georss:where has various other where constructs we're not currently
// handling, like
//  <georss:where> <gml:LineString> <gml:posList>
//        45.256 -110.45 46.46 -109.48 43.84 -109.86 45.8 -109.2
//      </gml:posList> </gml:LineString> </georss:where>

@implementation GDataGeoRSSWhere
+ (NSString *)extensionElementURI       { return kGDataNamespaceGeoRSS; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGeoRSSPrefix; }
+ (NSString *)extensionElementLocalName { return @"where"; }

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {

    NSXMLElement *gmlPointElem = [self childWithQualifiedName:@"gml:Point"
                                                 namespaceURI:kGDataNamespaceGeoGML
                                                  fromElement:element];
    if (gmlPointElem) {
      NSXMLElement *gmlPosElem = [self childWithQualifiedName:@"gml:pos"
                                                 namespaceURI:kGDataNamespaceGeoGML
                                                  fromElement:gmlPointElem];
      if (gmlPointElem) {

        NSString *valueListStr = [self stringValueFromElement:gmlPosElem];
        if ([valueListStr length] > 0) {

          NSArray *values = [GDataGeo valuesWithCoordinateString:valueListStr];
          if ([values count] > 0) {

            [self setValues:values];
          }
        }
      }
    }

  }
  return self;
}


- (NSXMLElement *)XMLElement {
  // generate
  // <georss:where> <gml:Point> <gml:pos>
  //    latitude longitude
  // </gml:pos> </gml:Point> </georss:where>

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"georss:where"];

  if ([self isPoint]) {

    NSString *valueListStr = [self coordinateString];

    NSXMLElement *gmlPointElem = [NSXMLElement elementWithName:@"gml:Point"];

    [self addToElement:gmlPointElem
childWithStringValueIfNonEmpty:valueListStr
              withName:@"gml:pos"];

    [element addChild:gmlPointElem];

  }
  return element;
}

@end

@implementation GDataGeo

+ (NSDictionary *)geoNamespaces {

  NSMutableDictionary *namespaces = [NSMutableDictionary dictionary];

  [namespaces setObject:kGDataNamespaceGeoRSS
                 forKey:kGDataNamespaceGeoRSSPrefix]; // "georss"

  [namespaces setObject:kGDataNamespaceGeoW3C
                 forKey:kGDataNamespaceGeoW3CPrefix]; // "geo"

  [namespaces setObject:kGDataNamespaceGeoGML
                 forKey:kGDataNamespaceGeoGMLPrefix]; // "gml"

  return namespaces;
}

+ (id)geoWithLatitude:(double)latitude
            longitude:(double)longitude {
  GDataGeo* obj = [self object];

  NSNumber *latNum = [NSNumber numberWithDouble:latitude];
  NSNumber *longNum = [NSNumber numberWithDouble:longitude];
  [obj setValues:[NSArray arrayWithObjects:latNum, longNum, nil]];

  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {

    // to initialize from XML, this must be one of the
    // subclasses that parses the XML appropriately,
    // so we'll use a strict equal-to class test
    GDATA_ASSERT(![self isMemberOfClass:[GDataGeo class]],
                 @"Subclass of %@ should handle initWithXMLElement:", [self class]);
  }
  return self;
}

- (NSXMLElement *)XMLElement {
  // usually the subclass will generate the XML, but if we're here there's no
  // subclass
  //
  // generate a georss:point

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"georss:point"];

  if ([self isPoint]) {
    NSString *str = [self coordinateString];
    [element addStringValue:str];
  }
  return element;
}

- (void)dealloc {
  [values_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGeo* newObj = [super copyWithZone:zone];
  [newObj setValues:[GDataUtilities mutableArrayWithCopiesOfObjectsInArray:[self values]]];
  return newObj;
}

- (BOOL)isEqual:(GDataGeo *)other {

  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGeo class]]) return NO;

  return [super isEqual:other]
  && AreEqualOrBothNil([self values], [other values]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];

  [self addToArray:items objectDescriptionIfNonNil:values_ withName:@"values"];

  return items;
}
#endif

//
// getters and setters
//

- (NSArray *)values {
  return values_;
}

- (void)setValues:(NSArray *)array {
  [values_ autorelease];
  values_ = [array copy];
}

// convenience accessors
- (BOOL)isPoint {
  return ([values_ count] == 2);
}

- (NSString *)coordinateString {
  NSArray *values = [self values];
  NSString *str = [GDataGeo coordinateStringWithValues:values];
  return str;
}

- (double)latitude {
  if ([self isPoint]) {
    return [[values_ objectAtIndex:0] doubleValue];
  }
  return NAN;
}

- (double)longitude {
  if ([self isPoint]) {
    return [[values_ objectAtIndex:1] doubleValue];
  }
  return NAN;
}

//
// utility
//

// valuesWithCoordinateString returns an array of doubles
// scanned from |str|.  The values must be in pairs
+ (NSArray *)valuesWithCoordinateString:(NSString *)str {

  NSMutableArray *array = [NSMutableArray array];
  NSScanner *scanner = [NSScanner scannerWithString:str];

  // scan pairs of coordinates
  double val1, val2;
  while ([scanner scanDouble:&val1] && [scanner scanDouble:&val2]) {
    [array addObject:[NSNumber numberWithDouble:val1]];
    [array addObject:[NSNumber numberWithDouble:val2]];
  }

  return array;
}

+ (NSString *)coordinateStringWithValues:(NSArray *)values {
  return [values componentsJoinedByString:@" "];
}

#pragma mark Helpers for other objects using GDataGeo

// call this in addExtensionDeclarations
+ (void)addGeoExtensionDeclarationsToObject:(GDataObject *)object
                             forParentClass:(Class)parentClass {

  // we declare three different extensions which can be geoLocation

  [object addExtensionDeclarationForParentClass:parentClass
                                     childClass:[GDataGeoRSSPoint class]];
  [object addExtensionDeclarationForParentClass:parentClass
                                     childClass:[GDataGeoRSSWhere class]];
  [object addExtensionDeclarationForParentClass:parentClass
                                     childClass:[GDataGeoW3CPoint class]];
}

// utility for the getter for GDataGeo
+ (GDataGeo *)geoLocationForObject:(GDataObject *)object {

  // the location point may be any of GDataGeo's three subclass types

  GDataGeo *geo = [object objectForExtensionClass:[GDataGeoRSSPoint class]];
  if (!geo) {
    geo = [object objectForExtensionClass:[GDataGeoRSSWhere class]];
  }
  if (!geo) {
    geo = [object objectForExtensionClass:[GDataGeoW3CPoint class]];
  }
  return geo;
}

// utility for the setter for GDataGeo
+ (void)setGeoLocation:(GDataGeo *)geo forObject:(GDataObject *)object {

  // remove the previous geo, whatever class it was
  GDataGeo *oldGeo = [GDataGeo geoLocationForObject:object];
  if (oldGeo) {
    [object removeObject:oldGeo forExtensionClass:[oldGeo class]];
  }

  if (geo) {
    // GDataGeo itself lacks support for the GDataExtension protocol;
    // only instances of its subclasses can be used as extensions
    GDATA_ASSERT(![geo isMemberOfClass:[GDataGeo class]],
              @"setGeoLocation requires an instance of a subclass of GDataGeo");

    [object setObject:geo forExtensionClass:[geo class]];
  }
}

@end

#pragma mark -

@implementation GDataGeoRSSFeatureName
+ (NSString *)extensionElementURI       { return kGDataNamespaceGeoRSS; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGeoRSSPrefix; }
+ (NSString *)extensionElementLocalName { return @"featurename"; }
@end

@implementation GDataGeoRSSRadius
+ (NSString *)extensionElementURI       { return kGDataNamespaceGeoRSS; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGeoRSSPrefix; }
+ (NSString *)extensionElementLocalName { return @"radius"; }
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
