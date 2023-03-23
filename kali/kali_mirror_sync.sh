#!/bin/bash
#
# kali_mirror_sync.sh
#
# This script is setup to sync a local Kali mirror
# with a remote mirror.
#
# REF:
# https://www.kali.org/docs/community/setting-up-a-kali-linux-mirror/
#

KALI_MIRROR="mirrors.ocf.berkeley.edu::kali"

REPOS_PATH=/var/mirrors/repos
KALI_REPO_PATH=$REPOS_PATH/kali
LOG_PATH=/var/log/mirror
LOG_FILE=$LOG_PATH/kali_repo_sync.log


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

# Make sure the log path exists
if [ ! -d $LOG_PATH ]; then
    mkdir -p $LOG_PATH
fi

# Make sure the repos path exists
if [ ! -d $REPOS_PATH ]; then
    mkdir -p $REPOS_PATH
fi

if [ ! -d $KALI_REPO_PATH ]; then
    mkdir -p $KALI_REPO_PATH
fi

# trap cntl-c
trap ctrl_c INT

function ctrl_c() {
    log "CNTL-C received. Stopping Kali repo sync"
    exit 255
}

log "Kali repo path: $KALI_REPO_PATH"
log "Starting Kali repo sync"

printf "Kali repo path: $KALI_REPO_PATH \n"
printf "Starting Kali repo sync \n"

rsync -qaH $KALI_MIRROR $KALI_REPO_PATH
if [ $(echo $?) -ne 0 ]; then
    log "Kali repo sync failed"
    exit 3
fi

log "Completed Kali repo sync"

printf "Completed Kali repo sync \n"
printf "See log file for more details: $LOG_FILE \n"
printf "\n"
