#!/bin/sh
cd /opt/monroe
#sh executorVariousWgetKAU_2.sh $1 $2 2>&1 > /opt/monroe/out-"$1"-"$2".txt
sh executorVariousWgetKAU.sh $1 $2 2>&1 > /opt/monroe/out-"$1"-"$2".txt
