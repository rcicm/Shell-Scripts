#!/bin/bash
#######################################################################################################
### This script manage Account Information in the Google App API                                    ###
###                                                                                                 ###
### Reference: https://developers.google.com/google-apps/email-audit/#accessing_account_information ###
###                                                                                                 ###
### Author: Rafael Campos / 2013-07-24                                                              ###
#######################################################################################################

#Usage example
function usage {
        echo "Usage: $0 action login (Ex.: $0 statusrequest all)"
        echo ""
        echo "Options:"
        echo " $0 accountinforequest userlogin   - Request a user account information"
        echo " $0 statusrequest all              - Retrieving all requests for account information"
        echo " $0 downloadaccountinfo URL        - Downloading an account information log"
        echo ""

        exit 1;
}

#Check the number of parameters
if [ $# -ne 2 ]
then
        usage
fi

#Adding constant
DirApp=$(dirname $0)
. $DirApp/myadmin.conf

ACTION=$1
PARAM2=$2
REPORTDATE=`date "+%Y-%m-%d %H:%M" --date "1 month ago"`

# Get you Authorization
AUTH=$(wget -O - -o /dev/null --post-data "Email=$MYADMINEMAIL&Passwd=$MYADMINPASSWD&accountType=HOSTED&service=apps&source=$MYCOMPANYNAME-$MYAPPNAME-$MYAPPVERSION" https://www.google.com/accounts/ClientLogin |grep "^Auth" |sed -e 's/Auth=//g')


case $ACTION in
    accountinforequest)
        # Request the Account Information from a specific userlogin
        curl -X POST -d "@emptybody.xml" --header "Content-type: application/atom+xml" --header "Authorization: GoogleLogin auth=$AUTH" "https://apps-apis.google.com/a/feeds/compliance/audit/account/$MYDOMAIN/$PARAM2"
        ;;
    statusrequest)
        #Check the staus of all the Account Information Requests made in the last month and save the result in the file "statusGmailFull.xml"
        wget -O statusGmailFull.xml --header="Content-type: application/atom+xml" --header="Authorization: GoogleLogin auth=$AUTH" "https://apps-apis.google.com/a/feeds/compliance/audit/account/$MYDOMAIN?fromDate=$REPORTDATE"
        #Check the staus of an especific request (You can get the [REQUEST_ID] in the result of a statusrequest. Property "requestId")
        #wget -O statusgmailId.xml --header="Content-type: application/atom+xml" --header="Authorization: GoogleLogin auth=$AUTH" "https://apps-apis.google.com/a/feeds/compliance/audit/account/$MYDOMAIN/$PARAM2/[REQUEST_ID]"
        ;;
    downloadaccountinfo)
        #Downloading the account information file and save it with the name "accountInformation" (You can get the [url] in the result of a statusrequest. Property "fileUrl0")
        wget -O accountInformation --header="Content-type: application/atom+xml" --header="Authorization: GoogleLogin auth=$AUTH" "$PARAM2"
        ;;

    *)
        usage
        ;;
esac
