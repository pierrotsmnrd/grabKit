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
//  GDataPhotoElements.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

// http://code.google.com/apis/picasaweb/reference.html#gphoto_reference

#define GDATAPHOTOELEMENTS_DEFINE_GLOBALS 1
#import "GDataPhotoElements.h"

#import "GDataPhotoConstants.h"

@implementation GDataPhotoAlbumID
// album id, like <gphoto:albumid>5024425138</gphoto:albumid>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"albumid"; }
@end

@implementation GDataPhotoCommentCount 
// comment count, like <gphoto:commentCount>11</gphoto:commentCount>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"commentCount"; }
@end

@implementation GDataPhotoCommentingEnabled 
// comment count, like <gphoto:commentingEnabled>true</gphoto:commentingEnabled>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"commentingEnabled"; }
@end

@implementation GDataPhotoGPhotoID
// photo ID, like<gphoto:id>512131187</gphoto:id>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"id"; }
@end

@implementation GDataPhotoMaxPhotosPerAlbum
// max photos per album, like <gphoto:maxPhotosPerAlbum>1000</gphoto:maxPhotosPerAlbum>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"maxPhotosPerAlbum"; }
@end

@implementation GDataPhotoNickname
// nickname, like <gphoto:nickname>Jane Smith</gphoto:nickname>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"nickname"; }
@end

@implementation GDataPhotoQuotaUsed
// current quota, like <gphoto:quotacurrent>312459331</gphoto:quotacurrent>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"quotacurrent"; }
@end

@implementation GDataPhotoQuotaLimit
// current quota, like <gphoto:quotalimit>312459331</gphoto:quotalimit>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"quotalimit"; }
@end

// thumbnail URL, like <gphoto:thumbnail>http://picasaweb.google.com/image/.../Hello.jpg</gphoto:thumbnail>
@implementation GDataPhotoThumbnail
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"thumbnail"; }
@end

@implementation GDataPhotoUser
// user, like <gphoto:user>Jane</gphoto:user>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"user"; }
@end

@implementation GDataPhotoAccess
// access, like <gphoto:access>public</gphoto:access>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"access"; }
@end

@implementation GDataPhotoBytesUsed
// current album bytes, like <gphoto:bytesUsed>11876307</gphoto:bytesUsed>
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"bytesUsed"; }
@end

// location, like <gphoto:location>Tokyo, Japan</gphoto:location>
@implementation GDataPhotoLocation
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"location"; }
@end

// number of photos in an album, <gphoto:numphotos>237</gphoto:numphotos>
@implementation GDataPhotoNumberUsed
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"numphotos"; }
@end

// remaining photos which may be added to album,
// <gphoto:numphotosremaining>763</gphoto:numphotosremaining>
@implementation GDataPhotoNumberLeft
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"numphotosremaining"; }
@end

// checksum for optimistic concurrency, <gphoto:checksum>987123</gphoto:checksum>
@implementation GDataPhotoChecksum
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"checksum"; }
@end

// photo height in pixels, like <gphoto:height>1200</gphoto:height>
@implementation GDataPhotoHeight
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"height"; }
@end

// unapplied rotation in int degrees, <gphoto:rotation>90</gphoto:rotation>  
@implementation GDataPhotoRotation
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"rotation"; }
@end

// photo size in bytes <gphoto:size>149351</gphoto:size> 
@implementation GDataPhotoSize
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"size"; }
@end

// photo timestamp, in milliseconds since 1-January-1970, 
// like <gphoto:timestamp>1168640584000</gphoto:timestamp>  
@implementation GDataPhotoTimestamp
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"timestamp"; }

+ (GDataPhotoTimestamp *)timestampWithDate:(NSDate *)date {
  GDataPhotoTimestamp *obj = [self object];
  [obj setDateValue:date];
  return obj;
}

- (NSDate *)dateValue {
  // date in XML here is like Java's date, milliseconds since 1970
  NSTimeInterval secs = [self doubleValue] / 1000.0;
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:secs]; 
  return date;
}

- (void)setDateValue:(NSDate *)date {
  NSTimeInterval secs = [date timeIntervalSince1970] * 1000.0;
  [self setDoubleValue:floor(secs)]; 
}

- (NSString *)description {
  return [[self dateValue] description]; 
}
@end

// photo width in pixels, <gphoto:width>1600</gphoto:width>
@implementation GDataPhotoWidth
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"width"; }
@end

// video upload status, like <gphoto:videostatus>pending</gphoto:videostatus>
@implementation GDataPhotoVideoStatus
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"videostatus"; }
@end

// photo ID for the current comment, <gphoto:photoid>301521187</gphoto:photoid>
// not to be confused with GDataPhotoGPhotoID
@implementation GDataPhotoPhotoID
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"photoid"; }
@end

// number of appearances of the current tag, <gphoto:weight>3</gphoto:weight>
@implementation GDataPhotoWeight
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"weight"; }
@end


//
// elements introduced in V2
//

// description of containing album, like
// <gphoto:albumdesc>My picture collection</gphoto:albumdesc>
@implementation GDataPhotoAlbumDesc
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"albumdesc"; }
@end

// title of containing, like
// <gphoto:albumtitle>My album</gphoto:albumtitle>
@implementation GDataPhotoAlbumTitle
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"albumtitle"; }
@end

// snippet matching search text, like
// <gphoto:snippet>...happy birthday...</gphoto:snippet>
@implementation GDataPhotoSnippet
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"snippet"; }
@end

// type of snippet from search text, like
// <gphoto:snippettype>PHOTO_DESCRIPTION<gphoto:snippettype>
@implementation GDataPhotoSnippetType
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"snippettype"; }
@end

// truncation flag for serach results, like
// <gphoto:truncated>1<gphoto:truncated>
@implementation GDataPhotoTruncated
+ (NSString *)extensionElementURI       { return kGDataNamespacePhotos; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespacePhotosPrefix; }
+ (NSString *)extensionElementLocalName { return @"truncated"; }
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
