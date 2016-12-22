#!/bin/bash
#
# author: Yves Sanderbrand <yvessander@gmail.com>
#
# Script zum Backup von Docker Containern
set -e

# Set Variables
BACKUPDATE=$(date '+%Y%m%d')
BACKUPHOST=$(hostname)
BACKUPDIR="/backup"
# init var for input
CONTAINER_NAME=$1

function getContainer {
  docker ps | grep -q $CONTAINER_NAME && \
  getVolumes || \
  echo "$CONTAINER_NAME is not a running Container";
}

function getVolumes {
  VOLUMES=$(docker inspect $CONTAINER_NAME \
  | grep '"Destination": ' \
  | awk -F '"' {'print $4'});
  for VOL in $VOLUMES; do
    backup $VOL
    unset VOL
  done; 
}

function backup() {
    VOL="$1"
    FOLDERNAME=$(basename $VOL)
    BACKUPNAME="$BACKUPDATE-$BACKUPHOST-$CONTAINER_NAME-$FOLDERNAME"
    VOL=${VOL#/}
    /usr/bin/docker run --rm --volumes-from \
    $CONTAINER_NAME -v $BACKUPDIR:/backup \
    debian:8.6 \
    tar cfp /backup/$BACKUPNAME.tar -C / $VOL
    unset VOL
    postbackup
}

function postbackup() {
    /usr/local/sbin/s3backup.sh $CONTAINER_NAME $BACKUPDIR/$BACKUPNAME.tar 
}

function print_usage {
  echo -e "Usage:"
  echo -e "######"
  echo -e ""
  echo -e "$0 IMAGE_ID/CONTAINER_NAME  - backup all volumes from given Container"
  echo ""
}

getContainer
