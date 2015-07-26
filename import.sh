#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
CVS_MODULE=$1
CVS_ROOT=:ext:anoncvs@cvs.orca.med.or.jp:/cvs
AUTHORS_FILE=$ROOT_DIR/authors.$CVS_MODULE.txt
LOG_DIR=$ROOT_DIR/logs
LOG_FILE=$LOG_DIR/import.$CVS_MODULE.$(date '+%Y-%m-%d--%H-%M-%S').log
SYSLOG_TAG=cvsimporter
SYSLOG_FACILITY=local0

if [ -z "$CVS_MODULE" ]; then
    echo "Usage: $0 <module>" >&2
    exit 9
fi

log() {
    declare dt="$(date '+%Y-%m-%dT%H:%M:%S%z')"
    declare level=$1
    shift
    declare msg="$*"

    echo "$dt $level - $msg"
}

log_syslog() {
    declare priority=$1
    shift
    declare level=$1
    shift
    declare msg="$*"

    logger -t $SYSLOG_TAG -p ${SYSLOG_FACILITY}.${priority} "$level - $msg"
}

log_info() {
    log INFO "$*"
    log_syslog info INFO "$*"
}

log_warn() {
    log WARN "$*" >&2
    log_syslog warn WARN "$*"
}

log_error() {
    log ERROR "$*" >&2
    log_syslog err ERROR "$*"
}

import() {
    mkdir -p $LOG_DIR

    log_info "Start importing $CVS_MODULE"

    log_info "Updating cvsps cache for $CVS_MODULE ..."
    cvsps -u --cvs-direct --root $CVS_ROOT $CVS_MODULE 2>&1
    retval=$?
    if [ $retval -eq 0 ]; then
        log_info "Updated cvsps cache for $CVS_MODULE"
    else
        log_error "Failed to Update cvsps cache for $CVS_MODULE"
        return 1
    fi

    cvsps -q --cvs-direct --root $CVS_ROOT $CVS_MODULE 2>/dev/null | grep '^Author: ' | sort -u |
        perl -pne 's|^Author: (.+)$|$1=$1 <$1\@> Asia/Tokyo|' > $AUTHORS_FILE

    log_info "Running git-cvsimport for $CVS_MODULE ..."
    git cvsimport -v -i -R -A $AUTHORS_FILE -d $CVS_ROOT -C $ROOT_DIR/$CVS_MODULE $CVS_MODULE 2>&1
    retval=$?
    if [ $retval -eq 0 ]; then
        log_info "Finished git-cvsimport for $CVS_MODULE"
    else
        log_error "Failed git-cvsimport for $CVS_MODULE"
        return 2
    fi

    log_info "Pushing to remote for $CVS_MODULE ..."
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git push --mirror origin
    if [ $retval -eq 0 ]; then
        log_info "Pushed to remote for $CVS_MODULE"
    else
        log_error "Failed to push to remote for $CVS_MODULE"
        return 3
    fi

    return 0
}

import $CVS_MODULE 2>&1 | tee $LOG_FILE
retval=${PIPESTATUS[0]}

gzip $LOG_FILE

exit $retval
