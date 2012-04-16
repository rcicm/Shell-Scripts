#!/bin/bash
#############################################
#
# Delete messages from a specific sender from
# a postfix Queue (Should run as root)
#
# 2012/04/16 - Rafael Campos
#############################################

SENDER=$1
MONTH=`/bin/date +%b`

echo "Removing from the Queue, the messages from $SENDER:"
for msg in $(/usr/sbin/postqueue -p |grep $MONTH |grep $SENDER |awk '{print $1}' |sed -e 's/*//g') ; do /usr/sbin/postsuper -d $msg ; done
