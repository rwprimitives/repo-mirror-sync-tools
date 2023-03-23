#!/bin/bash
#
# aosp_mirror_sync
#
# This script uses apt-mirror to sync a local AOSP mirror
# with a remote mirror.
#

REPOS_PATH=/var/mirrors/repos
AOSP_REPO_PATH=$REPOS_PATH/aosp
AOSP_REPO_INIT_PATH=$REPOS_PATH/aosp/.repo
LOG_PATH=/var/log/mirror
LOG_FILE=$LOG_PATH/aosp_repo_sync.log


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

if [ $(which repo &>/dev/null; echo $?) -ne 0 ]; then
    printf "Failed to find repo command!"
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

if [ ! -d $AOSP_REPO_PATH ]; then
    mkdir -p $AOSP_REPO_PATH
fi

# trap cntl-c
trap ctrl_c INT

function ctrl_c() {
	log "CNTL-C received. Stopping AOSP repo sync"
	exit 255
}

log "Path to mirror: $AOSP_REPO_PATH"
log "Starting AOSP repo sync"

printf "Path to mirror: $AOSP_REPO_PATH \n"
printf "Starting AOSP repo sync \n"

cd $AOSP_REPO_PATH

if [ ! -d $AOSP_REPO_INIT_PATH ]; then
    repo init 2>&1 | tee -a $LOG_FILE
    if [ $(echo $?) -ne 0 ]; then
        log "repo init failed"
        exit 3
    fi
fi

repo sync 2>&1 | tee -a $LOG_FILE
if [ $(echo $?) -ne 0 ]; then
    log "AOSP repo sync failed"
    exit 3
fi

log "Completed AOSP repo sync"

printf "Completed AOSP repo sync \n"
printf "See log file for more details: $LOG_FILE \n"
printf "\n"
