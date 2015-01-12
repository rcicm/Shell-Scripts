#!/bin/bash 
#####################################################################
# This script uploads a list o files to an Amazon S3 Bucket
# It's using curl, because a customer restrition over S3 cli
#
#  12/01/2015 - Rafael Campos
#####################################################################

pidfile=/tmp/UploadLogsS3Adobe.pid

if [ -f "$pidfile" ]; then
        echo "There is already a process running. Aborting!" >&2
        exit 1
else
        echo "$$" > $pidfile
fi

## Log function
function log {
        echo [$(date "+%Y/%m/%d %H:%M:%S")] - $@
}

CURLRESULT=/tmp/.UploadLogsS3Adobe_curl.txt
FILERPATH=/[PATH]/[MYFILES]/
FILENAME="myfiles.*.log.*[bm][zd][25]"
PROXY="http://myproxy.com:3128"

## S3Handler function
S3Handler(){
	file=$1
	contentType=$2
	method=$3
	bucket=[AWS NAME]
	resource="/${bucket}/${file}"
	dateValue=`date -R`
	stringToSign="$method\n\n${contentType}\n${dateValue}\n${resource}"
	s3Key=[ACCESS KEY]
	s3Secret=[SECRET KEY]
	signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

	curl -v --proxy $PROXY --retry 3 -X $method -T "${file}" -H "Host: ${bucket}.s3.amazonaws.com" -H "Date: ${dateValue}" -H "Content-Type: ${contentType}" -H "Authorization: AWS ${s3Key}:${signature}" https://${bucket}.s3.amazonaws.com/${file} > $CURLRESULT 2>&1
}

cd $FILERPATH
for FILE in `find . -mindepth 3 -maxdepth 3 -type f -name $FILENAME -ctime -1 |sed -e 's|\./||g'`
do
	YEARMONTH=$(echo $FILE |awk -F/ '{print $1}')
	DAY=$(echo $FILE |awk -F/ '{print $2}')
	mkdir -p $YEARMONTH/$DAY/UPLOADED
       	log "Uploading file '$FILE'"
	S3Handler $FILE "application/x-compressed-tar" PUT
       	log "Verifying the size of file '$FILE'"
	S3Handler $FILE "application/x-compressed-tar" HEAD
	LOCALSIZE=`stat -c %s  $FILE`
	dos2unix -q $CURLRESULT
	S3SIZE=`grep "Content-Length: " $CURLRESULT |awk '{print $NF}' |tail -1`
	if [ $LOCALSIZE == $S3SIZE ] 
	then
		log "The file has the same size locally and at the S3 Bucket. Upload OK!"
		mv $FILE $YEARMONTH/$DAY/UPLOADED/
	else
		log "The file is with a different size at S3 Bucket. I'll keep the file '$FILE' in the original path to retry in the future"
	fi
done

rm -rf $CURLRESULT
rm -rf $pidfile
