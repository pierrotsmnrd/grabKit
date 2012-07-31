/* Copyright (c) 2008 Google Inc.
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
//  GDataServiceGooglePhotos.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEPHOTOS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

// feed of all Google Photos photos, useful for queries searching for photos
_EXTERN NSString* const kGDataGooglePhotosAllFeed _INITIALIZE_AS(@"http://photos.googleapis.com/data/feed/api/all");

// values for photoFeedURLForUserID:
_EXTERN NSString* const kGDataGooglePhotosAccessAll       _INITIALIZE_AS(@"all");
_EXTERN NSString* const kGDataGooglePhotosAccessPublic    _INITIALIZE_AS(@"public");
_EXTERN NSString* const kGDataGooglePhotosAccessProtected _INITIALIZE_AS(@"protected"); // "sign-in required"
_EXTERN NSString* const kGDataGooglePhotosAccessPrivate   _INITIALIZE_AS(@"private");
_EXTERN NSString* const kGDataGooglePhotosAccessVisible   _INITIALIZE_AS(@"visible");

_EXTERN NSString* const kGDataGooglePhotosKindAlbum   _INITIALIZE_AS(@"album");
_EXTERN NSString* const kGDataGooglePhotosKindPhoto   _INITIALIZE_AS(@"photo");
_EXTERN NSString* const kGDataGooglePhotosKindComment _INITIALIZE_AS(@"comment");
_EXTERN NSString* const kGDataGooglePhotosKindTag     _INITIALIZE_AS(@"tag");
_EXTERN NSString* const kGDataGooglePhotosKindUser    _INITIALIZE_AS(@"user");

// inserting a photo into the feed for the default user and default album ID
// will post the photo into the user's "Drop Box" album
_EXTERN NSString* const kGDataGooglePhotosDropBoxUploadURL _INITIALIZE_AS(@"https://photos.googleapis.com/data/upload/resumable/media/create-session/feed/api/user/default/albumid/default");
_EXTERN NSString* const kGDataGooglePhotosDropBoxAlbumID   _INITIALIZE_AS(@"default");

@interface GDataServiceGooglePhotos : GDataServiceGoogle 

+ (NSString *)serviceRootURLString;

// utility for making a feed URL.  To set other query parameters, use the
// methods in GDataQueryGooglePhotos instead of this
+ (NSURL *)photoFeedURLForUserID:(NSString *)userID
                         albumID:(NSString *)albumIDorNil
                       albumName:(NSString *)albumNameOrNil
                         photoID:(NSString *)photoIDorNil
                            kind:(NSString *)feedKindOrNil
                          access:(NSString *)accessOrNil;

// utility for making a feed URL for a user's contacts feed
+ (NSURL *)photoContactsFeedURLForUserID:(NSString *)userID;

// clients may use these fetch methods of GDataServiceGoogle
//
//  - (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert forFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL ETag:(NSString *)etag delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed forBatchFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//
// finishedSelector has a signature like this for feed fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error;
//
// or this for entry fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryBase *)entry error:(NSError *)error;
//
// The class of the returned feed or entry is determined by the URL fetched.

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE
