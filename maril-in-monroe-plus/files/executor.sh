#!/bin/bash
cd /opt/monroe
#"key":number,"key":"string"
duration=`echo $1 | sed -e $'s/,/\\\n/g' | grep duration | cut -d: -f2 | sed 's/"//g'`
host=`echo $1 | sed -e $'s/,/\\\n/g' | grep host | cut -d: -f2 | sed 's/"//g'`
port=`echo $1 | sed -e $'s/,/\\\n/g' | grep port | cut -d: -f2 | sed 's/"//g'`
threads=`echo $1 | sed -e $'s/,/\\\n/g' | grep threads | cut -d: -f2 | sed 's/"//g'`
preTest=`echo $1 | sed -e $'s/,/\\\n/g' | grep preTest | cut -d: -f2 | sed 's/"//g'`

echo "$duration $host $port $threads $preTest"

#java maril.client.marilClientLaunch -d3 -h158.227.68.19 -p3446 -t3 -pre true
#java maril.client.marilClientLaunch -d5 -h85.17.254.6 -p3446 -t3 -pre true
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -pre $preTest
cp outputData.txt /monroe/results/
