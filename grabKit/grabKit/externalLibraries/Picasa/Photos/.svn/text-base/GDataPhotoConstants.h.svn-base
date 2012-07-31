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
//  GDataPhotoConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataEntryBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAPHOTOCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataPhotosServiceV2 _INITIALIZE_AS(@"2.0");
_EXTERN NSString* const kGDataPhotosDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespacePhotos           _INITIALIZE_AS(@"http://schemas.google.com/photos/2007");
_EXTERN NSString* const kGDataNamespacePhotosPrefix     _INITIALIZE_AS(@"gphoto");

_EXTERN NSString* const kGDataNamespacePhotosEXIF       _INITIALIZE_AS(@"http://schemas.google.com/photos/exif/2007");
_EXTERN NSString* const kGDataNamespacePhotosEXIFPrefix _INITIALIZE_AS(@"exif");

_EXTERN NSString* const kGDataCategoryPhotosPhoto   _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#photo");
_EXTERN NSString* const kGDataCategoryPhotosAlbum   _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#album");
_EXTERN NSString* const kGDataCategoryPhotosUser    _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#user");
_EXTERN NSString* const kGDataCategoryPhotosTag     _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#tag");
_EXTERN NSString* const kGDataCategoryPhotosComment _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#comment");
_EXTERN NSString* const kGDataCategoryPhotosPerson  _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#person");

_EXTERN NSString* const kGDataPhotoSnippetTypePhotoDescription _INITIALIZE_AS(@"PHOTO_DESCRIPTION");
_EXTERN NSString* const kGDataPhotoSnippetTypePhotoTags        _INITIALIZE_AS(@"PHOTO_TAGS");
_EXTERN NSString* const kGDataPhotoSnippetTypeAlbumTitle       _INITIALIZE_AS(@"ALBUM_TITLE");
_EXTERN NSString* const kGDataPhotoSnippetTypeAlbumDescription _INITIALIZE_AS(@"ALBUM_DESCRIPTION");
_EXTERN NSString* const kGDataPhotoSnippetTypeAlbumLocation    _INITIALIZE_AS(@"ALBUM_LOCATION");

@interface GDataPhotoConstants : NSObject
+ (NSDictionary *)photoNamespaces;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
