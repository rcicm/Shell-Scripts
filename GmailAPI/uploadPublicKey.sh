#!/bin/bash
#######################################################################################################
### This script inserts your PublicKey in the Google App API                                        ###
###                                                                                                 ###
### Reference: https://developers.google.com/google-apps/email-audit/auth#uploading_the_public_key  ###
###                                                                                                 ###
### Author: Rafael Campos / 2013-07-24                                                              ###
#######################################################################################################

#Adding constant
DirApp=$(dirname $0)
. $DirApp/myadmin.conf

# Get you Authorization
AUTH=$(wget -O - -o /dev/null --post-data "Email=$MYADMINEMAIL&Passwd=$MYADMINPASSWD&accountType=HOSTED&service=apps&source=$MYCOMPANYNAME-$MYAPPNAME-$MYAPPVERSION" https://www.google.com/accounts/ClientLogin |grep "^Auth" |sed -e 's/Auth=//g')

# Request to upload your public key
wget --header="Content-type: application/atom+xml" --header="Authorization: GoogleLogin auth=$AUTH" --post-file publickey.xml https://apps-apis.google.com/a/feeds/compliance/audit/publickey/$MYDOMAIN
