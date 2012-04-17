#!/bin/bash
#############################################
#
# Delete messages from a specific sender from
# a postfix Queue 
#
# 2012/04/16 - Rafael Campos
#############################################

if [ $? != 1 ]
then
        echo "Usage: $0 SENDER (Ex.: $0 test@test.com)"
        exit 1;
fi

SENDER=$1
MONTH=`/bin/date +%b`

echo "Removing from the Queue, the messages from $SENDER:"
for msg in $(/usr/sbin/postqueue -p |grep $MONTH |grep $SENDER |awk '{print $1}' |sed -e 's/*//g') ; do sudo /usr/sbin/postsuper -d $msg ; done
