#!/bin/bash
##############################################################
# Script to verify the read/write actions in a Redis instance 
# and the memory usage of this instance.
# It send an alert to Nagios case the memory usage is higher
# than $WARNMEM or if it couldnt insert/read a new key.
# 
# 2012/11/21 - Rafael Campos
##############################################################

#Usage example
if [ $# -ne 2 ]
then
        echo "Usage: $0 product instance (Ex.: $0 images farm)"
        exit 1;
fi

PRODUCT=$1
INSTANCE=$2

#Nagios Variables
HOST=`hostname`
IP=`hostname -i`
CFG="/etc/nagios/send_nsca.cfg"
NSCA="/usr/sbin/send_nsca"
NSCA_SERVER="nsca.mydomain.com"

#Nagios Messages
CMDLINEWRITEERRO="$HOST-$IP;Redis - $PRODUCT-$INSTANCE;2;Error during the read/write action. Try restart"
CMDLINEERRO="$HOST-$IP;Redis - $PRODUCT-$INSTANCE;2;The Memory usage is Higher than expected. Contact the Support Team"
CMDLINEWARN="$HOST-$IP;Redis - $PRODUCT-$INSTANCE;1;The Memory usage is Higher than expected. Open a Ticket"
CMDLINEOK="$HOST-$IP;Redis - $PRODUCT-$INSTANCE;0;OK"


#Script variables
REDISCONFPATH="/opt/$PRODUCT/redis-$INSTANCE/conf/redis.conf"   # Adapt it to your redis.conf path
REDISCLIPATH="/opt/generic/redis"
REDISPORT=`grep ^port $REDISCONFPATH |cut -d" " -f 2`
REDISPASS=`grep ^requirepass $REDISCONFPATH |cut -d\" -f 2`
MAXMEM=`grep ^maxmemory $REDISCONFPATH |cut -d" " -f 2 |sed -e 's/MB/*1024*1024/g' |sed -e 's/G/*1024*1024*1024/g' |sed -e 's/K/*1024/g' | bc`
USEDMEM=$(echo info | $REDISCLIPATH/redis-cli -h localhost -a $REDISPASS -p $REDISPORT  |grep used_memory: |cut -d: -f2 | sed -e 's/\r//g')
WARNMEM="85" #Percentage to WARNING (without '%')
CRITMEM="95" #Percentage to CRITICAL (without '%')


#Setting a new key in Redis
echo "set writetest 1" | $REDISCLIPATH/redis-cli -h localhost -a $REDISPASS -p $REDISPORT
#Recovering the key inserted
RESULT=$(echo "get writetest" | $REDISCLIPATH/redis-cli -h localhost -a $REDISPASS -p $REDISPORT)
#Removing the key inserted, to avoid future confusing
echo "del writetest" | $REDISCLIPATH/redis-cli -h localhost -a $REDISPASS -p $REDISPORT


if [ $RESULT -eq 1 ]
then
       if [ $USEDMEM -lt $(echo "scale=0; ($MAXMEM*$WARNMEM)/100" | bc) ]
       then
              echo $CMDLINEOK | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
       else
              if [ $USEDMEM -lt $(echo "scale=0; ($MAXMEM*$CRITMEM)/100" | bc) ]
              then
                     echo $CMDLINEWARN | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
              else
                     echo $CMDLINEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
              fi
       fi
else
       echo $CMDLINEWRITEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
fi
