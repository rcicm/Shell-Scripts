#!/bin/sh

######################################################
#
# Script to parse a web page and search for a string
# given as a parameter
# 
# 2012/04/27 - Rafael Campos
######################################################

if [ $# -ne 1 ]
then
        echo "Usage: $0 SEARCHSTRING (Ex.: $0 important)"
        exit 1;
fi

POSTDATA="param1=aaaa&param2=bbbb&param3=ccc"
URL="http://yourposturi.com/path/to/url"

FROM="username@yourdomain.com"
TO="destination@yourdomain.com"
CC="destination2@yourdomain.com"
SMTP="smtp.yourdomain.com"
USER="username"
PASS="password"

wget -O - --save-cookies /tmp/cookies.txt --post-data $POSTDATA $URL -o /dev/null |grep -i $1

if [ $? -eq 0 ]
then
        echo "The given string was found on the Page. Sending an e-mail"
        sendEmail -f $FROM -t $TO -cc $CC -u "Subject" -m "Message in the email body" -s $SMTP -o -xu $USER -xp $PASS
else
        echo "The given string wasnt found on the page."
fi
