#!/bin/sh
cd /opt/monroe
sh executorBothTests.sh $1 $2 2>&1 > /opt/monroe/out-"$1"-"$2".txt
