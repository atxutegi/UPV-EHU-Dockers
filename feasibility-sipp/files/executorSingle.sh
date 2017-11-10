#!/bin/sh
cd /opt/monroe
sh executorVariousWget.sh $1 $2 2>&1 > /opt/monroe/out-"$1"-"$2".txt
