#!/bin/bash
#
# author: Yves Sanderbrand <yvessander@gmail.com>

set -e 

MYFILE=$2
BUCKETFOLDER=$1
BUCKETNAME="myBackupBucket"
PUBKEYNAME="myBackupgpgKey"
S3REGION="--region=eu-central-1"

### Funktionen
function argchecker {
  [ "$MYFILE" != "" ] || { echo "No File as Argument given"; exiter; }
  [ -f $MYFILE ] || { echo "Can not find File $MYFILE for backup to S3"; exiter; }
  [ -s $MYFILE ] || { echo "File $MYFILE is Empty"; exiter; }
  [ $(find "$MYFILE" -cmin -360) ] || { echo "File $MYFILE is older than 6 hours"; exiter; }
}

function encrypter {
	#echo "crypt"
	gpg --no-tty --batch -o $MYFILE.gpg --encrypt -r $PUBKEYNAME $MYFILE
}

function cleaner {
	#echo "clean"
	mv $MYFILE.gpg $MYFILE-LastUpload.gpg
}

function s3uploader {
	# just for Debug
	S3FILE=$(basename $MYFILE)
	#echo "$MYFILE.gpg s3://$BUCKETNAME/$BUCKETFOLDER/$S3FILE.gpg" #
	/usr/local/bin/aws s3 cp $MYFILE.gpg s3://$BUCKETNAME/$BUCKETFOLDER/$S3FILE.gpg $S3REGION --only-show-errors
}

function exiter {
  exit 2
}


argchecker
encrypter
s3uploader
cleaner
