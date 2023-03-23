#!/bin/bash
#
# ubuntu_mirror_sync.sh
#
# This script uses apt-mirror to sync a local Ubuntu mirror
# with a remote mirror.
#
# REF:
# https://github.com/Stifler6996/apt-mirror
#

REPOS_PATH=/var/mirrors/repos
UBUNTU_REPO_PATH=$REPOS_PATH/ubuntu
LOG_PATH=/var/log/mirror
LOG_FILE=$LOG_PATH/ubuntu_repo_sync.log


function log()
{
    local current_date=`date +"%Y-%m-%d %H:%M:%S"`
    local msg="$@"

    printf "$current_date - $msg \n" >> $LOG_FILE
}

# Need to be root to run script!
if [ $(id -u) -ne 0 ]; then
    printf "Must be root to run this script"
    printf "\n"
    exec sudo "$0" "$@"
fi

if [ $(id -u) -ne 0 ]; then
    printf "Failed to elevate privileges!"
    printf "\n"
    exit 1
fi

if [ $(which apt-mirror; echo $?) -ne 0 ]; then
    printf "Failed to find apt-mirror command!"
    printf "\n"
    exit 2
fi

# Make sure the log path exists
if [ ! -d $LOG_PATH ]; then
	mkdir -p $LOG_PATH
fi

# Make sure the repos path exists
if [ ! -d $REPOS_PATH ]; then
	mkdir -p $REPOS_PATH
fi

if [ ! -d $UBUNTU_REPO_PATH ]; then
    mkdir -p $UBUNTU_REPO_PATH
fi

# trap cntl-c
trap ctrl_c INT

function ctrl_c() {
    log "CNTL-C received. Stopping Ubuntu repo sync"
	exit 255
}

log "Path to mirror: $UBUNTU_REPO_PATH"
log "Starting Ubuntu repo sync"

printf "Path to mirror: $UBUNTU_REPO_PATH \n"
printf "Starting Ubuntu repo sync \n"

apt-mirror 2>&1 | tee -a $LOG_FILE
if [ $(echo $?) -ne 0 ]; then
    log "Ubuntu repo sync failed"
    exit 3
fi

log "Completed Ubuntu repo sync"

printf "Completed Ubuntu repo sync \n"
printf "See log file for more details: $LOG_FILE \n"
printf "\n"
