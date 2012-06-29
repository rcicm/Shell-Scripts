#!/bin/bash 
######################################################
#
# Script to check the twitter rate limit and send an
# alarm to nagios case it be out of the pre set limit
# 
# 2012/06/29 - Rafael Campos
######################################################

#Server Variables
HOST=`hostname`
IP=`hostname -i`

#Nagios server Configuration
CFG="/etc/nagios/send_nsca.cfg"
NSCA="/usr/sbin/send_nsca"
NSCA_SERVER="nsca.mydomain.com"
CMDLINEERRO="$HOST-$IP;Twitter - Autorization - Whitelist;2;Twitter limit values out of the range"
CMDLINEOK="$HOST-$IP;Twitter - Autorization - Whitelist;0;OK"

#PROXY configuration
http_proxy=http://proxy.mydomain.com:3128/
use_proxy=on
wait=15
export http_proxy use_proxy wait



remaininghits=`curl -s "http://api.twitter.com/1/account/rate_limit_status.xml" --compressed |grep remaining-hits |sed 's/<[^>]*>//g'`
hourlylimit=`curl -s "http://api.twitter.com/1/account/rate_limit_status.xml" --compressed |grep hourly-limit |sed 's/<[^>]*>//g'`


if [ $hourlylimit -gt 20001 ] || [ $remaininghits -lt 2000 ]
then
   echo remaining-hits - $remaininghits
   echo hourly-limit - $hourlylimit
   echo Problem detected. Notifying Nagios ...
   echo $CMDLINEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
else
   echo remaining-hits - $remaininghits
   echo hourly-limit - $hourlylimit
   echo Everything OK.
   echo $CMDLINEOK | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
fi
