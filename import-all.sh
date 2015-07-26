#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
CVS_MODULES=(jma-receipt jma-receipt-kk jma-receipt-forms ikensyo tokutei qkan pims)

for module in ${CVS_MODULES[*]}; do
    echo "importing $module ..."
    $ROOT_DIR/cvsimporter/import.sh $module
    echo "imported $module"
done
