#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
CVS_MODULES=(jma-receipt jma-receipt-kk jma-receipt-forms ikensyo tokutei qkan pims)

for module in ${CVS_MODULES[*]}; do
    $ROOT_DIR/cvsimporter/import.sh $module >/dev/null 2>&1
done
