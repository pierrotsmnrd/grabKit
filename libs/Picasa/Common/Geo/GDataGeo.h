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
//  GDataGeo.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE \
  || GDATA_INCLUDE_PHOTOS_SERVICE || GDATA_INCLUDE_YOUTUBE_SERVICE

// GDataGeo encapsulates three flavors of geo location in XML: W3X, GeoRSS,
// and GeoGML.  Each flavor requires a separate subclass of GDataGeo for
// parsing and XML generation.
//
// To make it easy for other classes to use GDataGeo, it provides three class
// methods to handle the nasty job of figuring out which subclass of
// GDataGeo is needed.  For a concise example of how to use GDataGeo, see
// the unit test class GDataGeoTestClass.

#import "GDataObject.h"
#import "GDataValueConstruct.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAGEO_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceGeoW3C       _INITIALIZE_AS(@"http://www.w3.org/2003/01/geo/wgs84_pos#");
_EXTERN NSString* const kGDataNamespaceGeoW3CPrefix _INITIALIZE_AS(@"geo");

_EXTERN NSString* const kGDataNamespaceGeoRSS       _INITIALIZE_AS(@"http://www.georss.org/georss");
_EXTERN NSString* const kGDataNamespaceGeoRSSPrefix _INITIALIZE_AS(@"georss");

_EXTERN NSString* const kGDataNamespaceGeoGML       _INITIALIZE_AS(@"http://www.opengis.net/gml");
_EXTERN NSString* const kGDataNamespaceGeoGMLPrefix _INITIALIZE_AS(@"gml");

@interface GDataGeoRSSFeatureName : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataGeoRSSRadius : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataGeo : GDataObject <NSCopying> {
  NSArray *values_; // One or more pairs of doubles (NSNumbers)
}

+ (NSDictionary *)geoNamespaces;

+ (id)geoWithLatitude:(double)latitude
            longitude:(double)longitude;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent; // asserts; must call a subclass instance to parse XML

- (NSXMLElement *)XMLElement;

- (NSArray *)values;
- (void)setValues:(NSArray *)array;

- (NSString *)coordinateString; // values joined by spaces

- (double)latitude;
- (double)longitude;

- (BOOL)isPoint;

+ (NSArray *)valuesWithCoordinateString:(NSString *)str;
+ (NSString *)coordinateStringWithValues:(NSArray *)values;

//
// helpers for other GData classes which have a Geo as an element
//

// call this when declaring extensions
+ (void)addGeoExtensionDeclarationsToObject:(GDataObject *)object
                             forParentClass:(Class)parentClass;

// call these from setters/getters
//
// setGeoLocation requires a subclass of GDataGeo, not an instance
// of GDataGeo itself
+ (GDataGeo *)geoLocationForObject:(GDataObject *)object;
+ (void)setGeoLocation:(GDataGeo *)obj forObject:(GDataObject *)object;
@end

// We have subclasses to handle parsing and generation of XML for each
// xml flavor of supported geo point.
//
// If a Geo point is created from scratch (not from XML) then it will
// emit XML as a GeoRSS simple point, like
//    <georss:point>45.256 -71.92</georss:point>


// W3C Point
//
// http://www.w3.org/2003/01/geo/
// xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
//  <geo:Point>
//    <geo:lat>55.701</geo:lat>
//    <geo:long>12.552</geo:long>
//  </geo:Point>
@interface GDataGeoW3CPoint : GDataGeo <GDataExtension>
@end

// GeoRSS simple point http://www.georss.org/
// <georss:point>45.256 -71.92</georss:point>
@interface GDataGeoRSSPoint : GDataGeo <GDataExtension>
@end

//  <georss:where>
//    <gml:Point>
//      <gml:pos>45.256 -71.92</gml:pos>
//    </gml:Point>
//  </georss:where>
@interface GDataGeoRSSWhere : GDataGeo <GDataExtension>
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
