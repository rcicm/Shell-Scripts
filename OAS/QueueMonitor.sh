#!/usr/bin/env bash
# ====================================================================
#  Script responsable to check the messages ready on RabbitMQ queues
#  and sent an Nagios alert case a Queue has more than $CRIT messages
#
#  04/12/2013 - rafael_rci@yahoo.com.br
# =====================================================================
#

pidfile=/tmp/QueueMonitor.pid

if [ -f "$pidfile" ]; then
        echo "There is already a process running. Aborting!" >&2
        exit 1
else
        echo "$$" > $pidfile
fi

#Host Variables
HOST=`hostname`
IP=`hostname -i`

#Nagios Variables
CFG="/etc/nagios/send_nsca.cfg"
NSCA="/usr/sbin/send_nsca"
NSCA_SERVER="nsca.mydomain.com"

CMD="/usr/local/bin/rabbitmqadmin list queues name messages_ready"
QUEUES=$($CMD |egrep -v "name|\-\-\-" |awk '{print $2}')
CRIT=1000

## Log function
function log {
        echo [$(date "+%Y/%m/%d %H:%M:%S")] - $@
}

for fila in `echo $QUEUES`
do
	MESSAGES=$($CMD |grep "$fila" |awk '{print $4}')
	if [ $MESSAGES -gt $CRIT ]
	then
		CMDLINEERRO="$HOST.mydomain.com-$IP;Banner RabbitMQ (Queue $fila);2;Many messages queued in the Queue '$fila'"
		log "The Queue '$fila' have more than '$CRIT' messages Enqueued. Sending an Alert to nagios."
		echo '$CMDLINEERRO | $NSCA -H $NSCA_SERVER -d ";" -c $CFG'
	else
		CMDLINEOK="$HOST.mydomain.com-$IP;Banner RabbitMQ (Queue $fila);0;OK - Queue '$fila'"
		echo $CMDLINEOK | $NSCA -H $NSCA_SERVER -d ";" -c $CFG
	fi
done

rm -rf "$pidfile"
