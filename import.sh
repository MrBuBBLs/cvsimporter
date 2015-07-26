#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
CVS_MODULE=$1
CVS_ROOT=:ext:anoncvs@cvs.orca.med.or.jp:/cvs
AUTHORS_FILE=$ROOT_DIR/authors.$CVS_MODULE.txt
LOG_DIR=$ROOT_DIR/logs
LOG_FILE=$LOG_DIR/import.$CVS_MODULE.$(date '+%Y-%m-%d--%H-%M-%S').log

if [ -z "$CVS_MODULE" ]; then
    echo "Usage: $0 <module>" >&2
    exit 9
fi

mkdir -p $LOG_DIR

cvsps -q -u --cvs-direct --root $CVS_ROOT $CVS_MODULE 2>/dev/null | grep '^Author: ' | sort -u |
    perl -pne 's|^Author: (.+)$|$1=$1 <$1\@> Asia/Tokyo|' > $AUTHORS_FILE

git cvsimport -v -i -R -A $AUTHORS_FILE -d $CVS_ROOT -C $ROOT_DIR/$CVS_MODULE $CVS_MODULE 2>&1 | tee $LOG_FILE

gzip $LOG_FILE
