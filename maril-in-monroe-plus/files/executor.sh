#!/bin/sh
cd /opt/monroe
result=`echo $1 | sed -e $'s/,/\\\n/g'`
echo "$result"
echo "lines `echo $result | wc -l`"
duration=`echo $result | grep duration | cut -d: -f2 | sed 's/"//g'`
echo "$duration"
host=`echo $result | grep host | cut -d: -f2 | sed 's/"//g'`
echo "$host"
port=`echo $result | grep port | cut -d: -f2 | sed 's/"//g'`
echo "$port"
threads=`echo $result | grep threads | cut -d: -f2 | sed 's/"//g'`
echo "$threads"
preTest=`echo $result | grep preTest | cut -d: -f2 | sed 's/"//g'`
echo "$preTest"
echo "$duration $host $port $threads $preTest"

java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -e$preTest
cp outputData.txt /monroe/results/
