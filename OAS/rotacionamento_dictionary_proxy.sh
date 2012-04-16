#!/usr/bin/env bash
# =============================================================
# Script to rsync the dictionary directories to the filer
#
#  25/11/2010 - Rafael Campos
# =============================================================
#

DATE=`date +%Y%m%d`

## Logging function
function log {
        echo [$(date "+%Y/%m/%d %H:%M:%S")] - $@
}

cd /opt/rmla/RealMedia/ads/OpenAd/

log "STARTING..."
log "INFO - Getting subdirectories under '/opt/rmla/RealMedia/ads/OpenAd/etc/Dictionary/' with more than 60 days"
for i in `find /opt/rmla/RealMedia/ads/OpenAd/etc/Dictionary/ -type d -name '201*' -mtime +8`
do
	log "INFO - Doing rsync of the dir '"$i"' to the filer"
	rsync -rqu --size-only $i /mnt/banner/Dictionary/
	if [ $? -eq 0 ]
	then
		log "INFO - Rsync executed with success. Compacting the dir '"$i"' in the filer"
		gzip -r /mnt/banner/Dictionary/$i
	else
		log "ERRO - The rsync of the dir '"$i"' wasnt executed correctly"
	fi
done

log "Processing done!"
