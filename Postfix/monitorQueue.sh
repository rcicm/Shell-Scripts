#!/bin/bash

######################################################
#
# Script to check the postfix queue and send an alarm 
# to nagios case some sender has more than $MAXMSG
# 
# 2012/04/17 - Rafael Campos
######################################################

HOST=`hostname`
IP=`hostname -i`
CFG="/etc/nagios/send_nsca.cfg"
NSCA="/usr/sbin/send_nsca"
NSCA_SERVER="nsca.internal.com"

MONTH=`/bin/date +%b` 
MAXMSG=1000
TOPSENDER=`/usr/sbin/postqueue -p |grep $MONTH | awk '{print $7}' | sort|uniq -c |sort -rn|head -1`
MSG=`echo $TOPSENDER | awk '{print $1}'`
SENDER=`echo $TOPSENDER | awk '{print $2}'`

CMDLINEERRO="$HOST-$IP;Queue SMTPAR;2;Many messages queued in postfix queue"
CMDLINEOK="$HOST-$IP;Queue SMTPAR;0;OK"


if [ $MAXMSG -le $MSG ]
then
	echo $CMDLINEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
        echo "The Postfix Queue has more than $MAXMSG messages from the sender $SENDER"
else
	echo $CMDLINEOK | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
fi
