#!/bin/bash
#############################################
#
# Show the TOP 10 senders in a Postfix Queue
#
# 2012/04/16 - Rafael Campos
#############################################

MONTH=`/bin/date +%b`
echo "TOP 10 Senders:"
/usr/sbin/postqueue -p |grep $MONTH | awk '{print $7}' | sort|uniq -c |sort -rn|head -10
