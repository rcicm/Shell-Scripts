#!/bin/bash
###########################################################
#
# Script to read the last lines of a file ($1) since
# the last execution, and sent an alarm to nagios 
# case it found the SEARCHSTRING ($2)
# 
# 2012/07/23 - Rafael Campos
###########################################################

#Script Variables
OFFSETFILE='/tmp/mylog.offset'
SEARCHSTRING=$2

#Server Variables
HOST=`hostname`
IP=`hostname -i`

#Nagios server Configuration
CFG="/etc/nagios/send_nsca.cfg"
NSCA="/usr/sbin/send_nsca"
NSCA_SERVER="nsca.mydomain.com"
ALARMSTRING="My nagios alarm string"
ALARMDESCRIPTION="My nagios alarm description"
CMDLINEERRO="$HOST-$IP;$ALARMSTRING;2;$ALARMDESCRIPTION"
CMDLINEOK="$HOST-$IP;$ALARMSTRING;0;OK"




#Verifying if the OFFSET file exist
if [ -e $OFFSETFILE ]
then
   #If the OFFSET exist, check if it bigger than the current log I'm monitoring
   if [ $(cat $OFFSETFILE) -gt $(wc -c $1 |cut -f1 -d' ') ]
   then
      #If the current OFSET is bigger than my log file (possible because a log rotating), reset it to read the whole log file
      echo 1 > $OFFSETFILE
   fi
else
   #Case the OFFSET doesnt exist (Ex.: first execution), I'll create it to read the file from now.
   wc -c $1 > $OFFSETFILE
fi




if [ $(tail -c+$(cat $OFFSETFILE) $1 |grep -c $SEARCHSTRING) -gt 3 ]
then
   echo $CMDLINEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
else
   echo $CMDLINEOK | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
fi




#Setting the new value of the OFFSET
wc -c $1 |cut -f1 -d' ' > $OFFSETFILE
