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
//  GDataServiceACL.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataServiceACL.h"
#import "GDataEntryACL.h"

@implementation GDataServiceGoogle (GDataServiceACLAdditions)


// ACL feed and entry support

- (GDataServiceTicket *)fetchACLFeedWithURL:(NSURL *)feedURL
                                   delegate:(id)delegate
                          didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:feedURL
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchACLEntryByInsertingEntry:(GDataEntryACL *)entryToInsert
                                           forFeedURL:(NSURL *)feedURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector {
  // add ACL namespaces, if needed
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[[entryToInsert class] ACLNamespaces]];
  }

  return [self fetchEntryByInsertingEntry:entryToInsert
                               forFeedURL:feedURL
                                 delegate:delegate
                        didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchACLEntryByUpdatingEntry:(GDataEntryACL *)entryToUpdate
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector {

  // add ACL namespaces, if needed
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[[entryToUpdate class] ACLNamespaces]];
  }

  return [self fetchEntryByUpdatingEntry:entryToUpdate
                                delegate:delegate
                       didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchACLEntryByUpdatingEntry:(GDataEntryACL *)entryToUpdate
                                         forEntryURL:(NSURL *)entryURL
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector {

  // add ACL namespaces, if needed
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[[entryToUpdate class] ACLNamespaces]];
  }

  return [self fetchEntryByUpdatingEntry:entryToUpdate
                             forEntryURL:entryURL
                                delegate:delegate
                       didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)deleteACLEntry:(GDataEntryACL *)entryToDelete
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector {

  return [self deleteEntry:entryToDelete
                  delegate:delegate
         didFinishSelector:finishedSelector];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
