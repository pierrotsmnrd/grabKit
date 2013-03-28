
#!/bin/bash

#
# This file is part of the GrabKit package.
# Copyright (c) 2013 Pierre-Olivier Simonard <pierre.olivier.simonard@gmail.com>
#  
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
# associated documentation files (the "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#  
# The above copyright notice and this permission notice shall be included in all copies or substantial 
# portions of the Software.
#  
# The Software is provided "as is", without warranty of any kind, express or implied, including but not 
# limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no
# event shall the authors or copyright holders be liable for any claim, damages or other liability, whether
# in an action of contract, tort or otherwise, arising from, out of or in connection with the Software or the 
# use or other dealings in the Software.
#
# Except as contained in this notice, the name(s) of (the) Author shall not be used in advertising or otherwise
# to promote the sale, use or other dealings in this Software without prior written authorization from (the )Author.
#





installSubmodule() {

	SUBMODULE_NAME=$1		
	DEST_DIRECTORY=$2
	SUBMODULE_URL=$3
	
	# create the directory if it doesn't exist
	if [ ! -d $DEST_DIRECTORY ]; then
		mkdir $DEST_DIRECTORY
	fi
	
	# if the directory is empty
	if [ "$(ls -1 $DEST_DIRECTORY | wc -l)" -le 1 ]; then
		# download the archive from gitHub
		wget -nv --no-check-certificate $SUBMODULE_URL -O $DEST_DIRECTORY.zip
		# unzip it
		unzip $DEST_DIRECTORY.zip
		# move its content to the destination directory
		mv $SUBMODULE_NAME-master/.[^.]* $DEST_DIRECTORY
		mv $SUBMODULE_NAME-master/* $DEST_DIRECTORY
		# remove the zip
		rm $DEST_DIRECTORY.zip
		# remove the dir created when unzipping
		rmdir $SUBMODULE_NAME-master
	else
		# else, skip the step.
		echo $DEST_DIRECTORY" exists and is not empty. Step skipped"
		
	fi 

}


# Check that we have the write permission
if [  ! -w . ]
then
	echo "You must have the write permissions for the current directory. Aborting."
	exit 1
fi


# Check that we can use  wget and unzip 
command -v wget >/dev/null 2>&1 || { echo >&2 "You must have wget installed to proceed. Aborting."; exit 1; }

command -v unzip >/dev/null 2>&1 || { echo >&2 "You must have unzip installed to proceed. Aborting."; exit 1; }




# Install the submodules

installSubmodule MBProgressHUD MBProgressHUD "https://github.com/jdg/MBProgressHUD/archive/master.zip"

installSubmodule ISO8601DateFormatter ISO8601DateFormatter "https://github.com/keithpitt/ISO8601DateFormatter/archive/master.zip"

installSubmodule NVUIGradientButton NVUIGradientButton "https://github.com/nverinaud/NVUIGradientButton/archive/master.zip"

installSubmodule objectiveflickr objectiveflickr "https://github.com/lukhnos/objectiveflickr/archive/master.zip"

installSubmodule PSTCollectionView PSTCollectionView "https://github.com/steipete/PSTCollectionView/archive/master.zip"




# Install Picasa's lib

DEST_DIRECTORY=./Picasa/

if [ ! -d $DEST_DIRECTORY ]; then
	mkdir $DEST_DIRECTORY
fi

if [ "$(ls -1 $DEST_DIRECTORY | wc -l)" -ge 2 ]; then
	echo $DEST_DIRECTORY" exists and is not empty. Step skipped"
	exit
fi


# GData ObjectiveC Client

SVN_SOURCE=http://gdata-objectivec-client.googlecode.com/svn/trunk/Source/

svn export $SVN_SOURCE"ACL/" $DEST_DIRECTORY"ACL/"

svn export $SVN_SOURCE"BaseClasses/" $DEST_DIRECTORY"BaseClasses/"

svn export $SVN_SOURCE"Clients/Photos" $DEST_DIRECTORY"Clients/Photos"

svn export $SVN_SOURCE"Elements/" $DEST_DIRECTORY"Elements/"

svn export $SVN_SOURCE"Geo/" $DEST_DIRECTORY"Geo/"

svn export $SVN_SOURCE"Introspection/" $DEST_DIRECTORY"Introspection/"

svn export $SVN_SOURCE"Media/" $DEST_DIRECTORY"Media/"

svn export $SVN_SOURCE"Networking/" $DEST_DIRECTORY"Networking/"

svn export $SVN_SOURCE"XMLSupport/" $DEST_DIRECTORY"XMLSupport/"

svn export $SVN_SOURCE"GDataDefines.h" $DEST_DIRECTORY"GDataDefines.h"

svn export $SVN_SOURCE"GData.h" $DEST_DIRECTORY"GData.h"

svn export $SVN_SOURCE"GDataFramework.h" $DEST_DIRECTORY"GDataFramework.h"

svn export $SVN_SOURCE"GDataFramework.m" $DEST_DIRECTORY"GDataFramework.m"

svn export $SVN_SOURCE"GDataTargetNamespace.h" $DEST_DIRECTORY"GDataTargetNamespace.h"

svn export $SVN_SOURCE"GDataUtilities.h" $DEST_DIRECTORY"GDataUtilities.h"

svn export $SVN_SOURCE"GDataUtilities.m" $DEST_DIRECTORY"GDataUtilities.m"


# HTTPFetcher
mkdir $DEST_DIRECTORY"HTTPFetcher/"

SVN_SOURCE=http://gtm-http-fetcher.googlecode.com/svn/trunk/Source/

svn export $SVN_SOURCE"GTMGatherInputStream.h" $DEST_DIRECTORY"HTTPFetcher/GTMGatherInputStream.h"

svn export $SVN_SOURCE"GTMGatherInputStream.m" $DEST_DIRECTORY"HTTPFetcher/GTMGatherInputStream.m"

svn export $SVN_SOURCE"GTMHTTPFetcher.h" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcher.h"

svn export $SVN_SOURCE"GTMHTTPFetcher.m" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcher.m"

svn export $SVN_SOURCE"GTMHTTPFetcherLogging.h" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcherLogging.h"

svn export $SVN_SOURCE"GTMHTTPFetcherLogging.m" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcherLogging.m"

svn export $SVN_SOURCE"GTMHTTPFetcherService.h" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcherService.h"

svn export $SVN_SOURCE"GTMHTTPFetcherService.m" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetcherService.m"

svn export $SVN_SOURCE"GTMHTTPFetchHistory.h" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetchHistory.h"

svn export $SVN_SOURCE"GTMHTTPFetchHistory.m" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPFetchHistory.m"

svn export $SVN_SOURCE"GTMHTTPUploadFetcher.h" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPUploadFetcher.h"

svn export $SVN_SOURCE"GTMHTTPUploadFetcher.m" $DEST_DIRECTORY"HTTPFetcher/GTMHTTPUploadFetcher.m"

svn export $SVN_SOURCE"GTMMIMEDocument.h" $DEST_DIRECTORY"HTTPFetcher/GTMMIMEDocument.h"

svn export $SVN_SOURCE"GTMMIMEDocument.m" $DEST_DIRECTORY"HTTPFetcher/GTMMIMEDocument.m"

svn export $SVN_SOURCE"GTMReadMonitorInputStream.h" $DEST_DIRECTORY"HTTPFetcher/GTMReadMonitorInputStream.h"

svn export $SVN_SOURCE"GTMReadMonitorInputStream.m" $DEST_DIRECTORY"HTTPFetcher/GTMReadMonitorInputStream.m"

# OAuth 2
mkdir $DEST_DIRECTORY"OAuth2"

SVN_SOURCE=http://gtm-oauth2.googlecode.com/svn/trunk/Source/

svn export  $SVN_SOURCE"GTMOAuth2Authentication.h" $DEST_DIRECTORY"OAuth2/GTMOAuth2Authentication.h"

svn export  $SVN_SOURCE"GTMOAuth2Authentication.m" $DEST_DIRECTORY"OAuth2/GTMOAuth2Authentication.m"

svn export  $SVN_SOURCE"GTMOAuth2SignIn.h" $DEST_DIRECTORY"OAuth2/GTMOAuth2SignIn.h"

svn export  $SVN_SOURCE"GTMOAuth2SignIn.m" $DEST_DIRECTORY"OAuth2/GTMOAuth2SignIn.m"

svn export  $SVN_SOURCE"Touch" $DEST_DIRECTORY"OAuth2/Touch"

