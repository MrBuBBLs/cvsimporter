#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
CVS_MODULE=$1
CVS_ROOT=:ext:anoncvs@cvs.orca.med.or.jp:/cvs
export CVS_RSH=ssh

# Do not use author file, conversion is forced to: name <name@> in git-cvsimport.orca
#AUTHORS_FILE=$ROOT_DIR/authors.$CVS_MODULE.txt
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

    log_info "Running git-cvsimport for $CVS_MODULE ..."
    git cvsimport.orca -p -u -v -i -R -d $CVS_ROOT -C $ROOT_DIR/$CVS_MODULE $CVS_MODULE 2>&1
    retval=$?
    if [ $retval -eq 0 ]; then
        log_info "Finished git-cvsimport for $CVS_MODULE"
    else
        log_error "Failed git-cvsimport for $CVS_MODULE"
        return 2
    fi

    log_info "Pushing to remote for $CVS_MODULE ..."
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git --work-tree=$ROOT_DIR/$CVS_MODULE reset --hard HEAD
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git --work-tree=$ROOT_DIR/$CVS_MODULE clean -fdx .
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git --work-tree=$ROOT_DIR/$CVS_MODULE checkout master
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git --work-tree=$ROOT_DIR/$CVS_MODULE rebase origin
    git --git-dir=$ROOT_DIR/$CVS_MODULE/.git --work-tree=$ROOT_DIR/$CVS_MODULE push --mirror origin
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
