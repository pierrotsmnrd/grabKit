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
//  GDataMediaGroup.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_PHOTOS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"
#import "GDataTextConstruct.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAMEDIAGROUP_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceMedia _INITIALIZE_AS(@"http://search.yahoo.com/mrss/");
_EXTERN NSString* const kGDataNamespaceMediaPrefix _INITIALIZE_AS(@"media");


@class GDataMediaContent;
@class GDataMediaThumbnail;
@class GDataMediaCredit;
@class GDataMediaKeywords;
@class GDataMediaRating;
@class GDataMediaRestriction;
@class GDataMediaCategory;
@class GDataMediaPlayer;

// GDataMediaGroup extension
@interface GDataMediaDescription : GDataTextConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

// GDataMediaTitle extension
@interface GDataMediaTitle : GDataTextConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end


// for media:group, like 
// <media:group> <media:contents  ... /> </media:group>

// TODO:  Currently, just the set needed for Google Photos is implemented
// Still needed:
//   MediaCopyright
//   MediaHash
//   MediaText
//   

@interface GDataMediaGroup : GDataObject <GDataExtension>

+ (id)mediaGroup;

// extension setters/getters

- (NSArray *)mediaCategories;
- (void)setMediaCategories:(NSArray *)array;
- (void)addMediaCategory:(GDataMediaCategory *)attribute;  

- (NSArray *)mediaContents;
- (void)setMediaContents:(NSArray *)array;
- (void)addMediaContent:(GDataMediaContent *)attribute;  

- (NSArray *)mediaCredits;
- (void)setMediaCredits:(NSArray *)array;
- (void)addMediaCredit:(GDataMediaCredit *)attribute;

- (NSArray *)mediaPlayers;
- (void)setMediaPlayers:(NSArray *)array;
- (void)addMediaPlayer:(GDataMediaPlayer *)attribute;

- (NSArray *)mediaRatings;
- (void)setMediaRatings:(NSArray *)array;
- (void)addMediaRating:(GDataMediaRating *)attribute;

- (NSArray *)mediaRestrictions;
- (void)setMediaRestrictions:(NSArray *)array;
- (void)addMediaRestriction:(GDataMediaRestriction *)attribute;

- (NSArray *)mediaThumbnails;
- (void)setMediaThumbnails:(NSArray *)array;
- (void)addMediaThumbnail:(GDataMediaThumbnail *)attribute;

- (GDataMediaKeywords *)mediaKeywords;
- (void)setMediaKeywords:(GDataMediaKeywords *)obj;

- (GDataMediaDescription *)mediaDescription;
- (void)setMediaDescription:(GDataMediaDescription *)obj;
  
- (GDataMediaTitle *)mediaTitle;
- (void)setMediaTitle:(GDataMediaTitle *)obj;

@end

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_*_SERVICE
