#!/bin/bash
cd /opt/monroe
#java maril.client.marilClientLaunch -d3 -h158.227.68.19 -p3446 -t3
duration=`echo $1 | sed -e $'s/,/\\\n/g' | grep duration | cut -d: -f2 | sed 's/"//g'`
host=`echo $1 | sed -e $'s/,/\\\n/g' | grep host | cut -d: -f2 | sed 's/"//g'`
port=`echo $1 | sed -e $'s/,/\\\n/g' | grep port | cut -d: -f2 | sed 's/"//g'`
threads=`echo $1 | sed -e $'s/,/\\\n/g' | grep threads | cut -d: -f2 | sed 's/"//g'`
preTest=`echo $1 | sed -e $'s/,/\\\n/g' | grep preTest | cut -d: -f2 | sed 's/"//g'`
eval `ssh-agent`
ssh-add id_rsa
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
python experimentTXT.py &
#java maril.client.marilClientLaunch -d5 -h85.17.254.6 -p3446 -t3
#java maril.client.marilClientLaunch -d5 -h212.81.134.74 -p3446 -t3
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -pre $preTest
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testKiller.sh'
cp outputData.txt /monroe/results/
