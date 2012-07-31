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
//  GDataPhotoElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAPHOTOELEMENTS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

// values for GDataPhotoAccess
_EXTERN NSString* const kGDataPhotoAccessPrivate _INITIALIZE_AS(@"private");
_EXTERN NSString* const kGDataPhotoAccessProtected _INITIALIZE_AS(@"protected"); // "sign-in required"
_EXTERN NSString* const kGDataPhotoAccessPublic _INITIALIZE_AS(@"public");
_EXTERN NSString* const kGDataPhotoAccessAll _INITIALIZE_AS(@"all");

// values for GDataPhotoVideoStatus
_EXTERN NSString* const kGDataPhotoStatusPending _INITIALIZE_AS(@"pending");
_EXTERN NSString* const kGDataPhotoStatusReady   _INITIALIZE_AS(@"ready");
_EXTERN NSString* const kGDataPhotoStatusFinal   _INITIALIZE_AS(@"final");
_EXTERN NSString* const kGDataPhotoStatusFailed  _INITIALIZE_AS(@"failed");


// http://code.google.com/apis/picasaweb/reference.html#gphoto_reference

// album id, like <gphoto:albumid>5024425138</gphoto:albumid>
@interface GDataPhotoAlbumID : GDataValueElementConstruct <GDataExtension>
@end

// comment count, like <gphoto:commentCount>11</gphoto:commentCount>
@interface GDataPhotoCommentCount : GDataValueElementConstruct <GDataExtension>
@end

// comment count, like <gphoto:commentingEnabled>true</gphoto:commentingEnabled>
@interface GDataPhotoCommentingEnabled : GDataValueElementConstruct <GDataExtension>
@end

// photo ID, like <gphoto:id>512131187</gphoto:id>
@interface GDataPhotoGPhotoID : GDataValueElementConstruct <GDataExtension>
@end

// max photos per album, like <gphoto:maxPhotosPerAlbum>1000</gphoto:maxPhotosPerAlbum>
@interface GDataPhotoMaxPhotosPerAlbum : GDataValueElementConstruct <GDataExtension>
@end

// nickname, like <gphoto:nickname>Jane Smith</gphoto:nickname>
@interface GDataPhotoNickname : GDataValueElementConstruct <GDataExtension>
@end

// current quota, like <gphoto:quotacurrent>312459331</gphoto:quotacurrent>
@interface GDataPhotoQuotaUsed : GDataValueElementConstruct <GDataExtension>
@end

// max quota, like <gphoto:quotalimit>1385222385</gphoto:quotalimit>
@interface GDataPhotoQuotaLimit : GDataValueElementConstruct <GDataExtension>
@end

// thumbnail URL, like <gphoto:thumbnail>http://picasaweb.google.com/image/.../Hello.jpg</gphoto:thumbnail>
@interface GDataPhotoThumbnail : GDataValueElementConstruct <GDataExtension>
@end

// user, like <gphoto:user>Jane</gphoto:user>
@interface GDataPhotoUser : GDataValueElementConstruct <GDataExtension>
@end

// access, like <gphoto:access>public</gphoto:access>
@interface GDataPhotoAccess : GDataValueElementConstruct <GDataExtension>
@end

// current album bytes, like <gphoto:bytesUsed>11876307</gphoto:bytesUsed>
@interface GDataPhotoBytesUsed : GDataValueElementConstruct <GDataExtension>
@end

// location, like <gphoto:location>Tokyo, Japan</gphoto:location>
@interface GDataPhotoLocation : GDataValueElementConstruct <GDataExtension>
@end

// number of photos in an album, <gphoto:numphotos>237</gphoto:numphotos>
@interface GDataPhotoNumberUsed : GDataValueElementConstruct <GDataExtension>
@end

// remaining photos which may be added to album,
// <gphoto:numphotosremaining>763</gphoto:numphotosremaining>
@interface GDataPhotoNumberLeft : GDataValueElementConstruct <GDataExtension>
@end

// checksum for optimistic concurrency, <gphoto:checksum>987123</gphoto:checksum>
@interface GDataPhotoChecksum : GDataValueElementConstruct <GDataExtension>
@end

// photo height in pixels, like <gphoto:height>1200</gphoto:height>
@interface GDataPhotoHeight : GDataValueElementConstruct <GDataExtension>
@end

// unapplied rotation in int degrees, <gphoto:rotation>90</gphoto:rotation>  
@interface GDataPhotoRotation : GDataValueElementConstruct <GDataExtension>
@end

// photo size in bytes <gphoto:size>149351</gphoto:size> 
@interface GDataPhotoSize : GDataValueElementConstruct <GDataExtension>
@end

// photo timestamp, in milliseconds since 1-January-1970, 
// like <gphoto:timestamp>1168640584000</gphoto:timestamp>  
@interface GDataPhotoTimestamp : GDataValueElementConstruct <GDataExtension>
+ (GDataPhotoTimestamp *)timestampWithDate:(NSDate *)date;
- (NSDate *)dateValue;
- (void)setDateValue:(NSDate *)date;
@end

// photo width in pixels, <gphoto:width>1600</gphoto:width>
@interface GDataPhotoWidth : GDataValueElementConstruct <GDataExtension>
@end

// video upload status, like <gphoto:videostatus>pending</gphoto:videostatus>
//
// see constants listed above
@interface GDataPhotoVideoStatus : GDataValueElementConstruct <GDataExtension>
@end

// photo ID for the current comment, <gphoto:photoid>301521187</gphoto:photoid>
@interface GDataPhotoPhotoID : GDataValueElementConstruct <GDataExtension>
@end

// number of appearances of the current tag, <gphoto:weight>3</gphoto:weight>
@interface GDataPhotoWeight : GDataValueElementConstruct <GDataExtension>
@end

//
// elements introduced in V2
//

// description of containing album, like
// <gphoto:albumdesc>My picture collection</gphoto:albumdesc>
@interface GDataPhotoAlbumDesc : GDataValueElementConstruct <GDataExtension>
@end

// title of containing, like
// <gphoto:albumtitle>My album</gphoto:albumtitle>
@interface GDataPhotoAlbumTitle : GDataValueElementConstruct <GDataExtension>
@end

// snippet matching search text, like
// <gphoto:snippet>...happy birthday...</gphoto:snippet>
@interface GDataPhotoSnippet : GDataValueElementConstruct <GDataExtension>
@end

// type of snippet from search text, like
// <gphoto:snippettype>PHOTO_DESCRIPTION<gphoto:snippettype>
@interface GDataPhotoSnippetType : GDataValueElementConstruct <GDataExtension>
@end

// truncation flag for serach results, like
// <gphoto:truncated>1<gphoto:truncated>
@interface GDataPhotoTruncated : GDataValueElementConstruct <GDataExtension>
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
