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
eval `ssh-agent`
ssh-add id_rsa
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
python experimentTXT.py &
#java maril.client.marilClientLaunch -d5 -h212.81.134.74 -p3446 -t3
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -e$preTest
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testKiller.sh'
cp outputData.txt /monroe/results/
