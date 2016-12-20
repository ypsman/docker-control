#!/bin/bash
#
# author: Yves Sanderbrand <yvessander@gmail.com>
#
# Script zum starten von Containern mit docker-compose
set -e

# Setup some vars
DOCKERCOMPOSEFILE="./docker-compose.yml"
CONTAINER_NAME=""

function getContainerName {
  test -e $DOCKERCOMPOSEFILE && \
	CONTAINER_NAME=$(cat $DOCKERCOMPOSEFILE  | grep container_name | awk '{print $2}') && \
	outputter "Ok" "Found Container: $CONTAINER_NAME"  \
	|| outputter "Error" "$DOCKERCOMPOSEFILE not found in current folder.\n Use: $0 help  for help"
}

function start_container {
  getContainerName
  echo -e "\e[33m$FUNCNAME: $CONTAINER_NAME\e[0m"
  docker-compose start && \
  outputter "Ok" "$FUNCNAME" || \
  outputter "Error" "at $FUNCNAME" 
}

function stop_container {
  getContainerName
  echo -e "\e[33m$FUNCNAME: $CONTAINER_NAME\e[0m"
  docker-compose stop && \
  outputter "Ok" "$FUNCNAME" || \
  outputter "Error" "at $FUNCNAME" 
}

function fresh_build {
  getContainerName
  echo -e "\e[33m$FUNCNAME: $CONTAINER_NAME\e[0m"
  docker-compose build --force && \
  outputter "Ok" "$FUNCNAME" || \
  outputter "Error" "at $FUNCNAME" 
}

function shell {
  getContainerName
  echo -e "\e[33m$FUNCNAME: $CONTAINER_NAME\e[0m"
  docker  exec -it $CONTAINER_NAME /bin/bash && \
  outputter "Ok" "$FUNCNAME" \ || 
  outputter "Error" "at $FUNCNAME" 
}

function outputter() {
  case "$1" in
    	Ok)    echo -e "$2 ""\e[32m\e[1mOk \e[0m";;
    	Error) echo -e "\e[31m\e[1mError: \e[0m" "$2" && exit 1 ;;
  esac
}

function backup() {
  #echo "Write youre Backup in this Function"
}

function print_usage {
  echo -e "Usage:"
  echo -e "######"
  echo -e "in Folder with a docker-compose.yml:"
  echo -e ""
  echo -e "$0 start       - Container Start"
  echo -e "$0 stop        - Container Stop"
  echo -e "$0 rebuild     - Container Rebuild"
  echo -e "$0 backup      - backup container Volumes"
  echo -e "$0 shell       - Opens a Shell to Container"
  echo -e "$0 help        - shows usage"
  echo ""
}

function starter() {
  case "$1" in
  start)    start_container;;
  stop)     stop_container;;
	rebuild)  fresh_build;;
	shell)    shell;;
  backup)   backup;;
	help)     print_usage;;
  *)        echo   -e "Unknown parameter: $1\n" \ && print_usage
  esac
}

starter "$1"