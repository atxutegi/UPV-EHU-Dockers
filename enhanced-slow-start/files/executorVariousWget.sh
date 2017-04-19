#!/bin/sh
cd /opt/monroe
result=`cat /monroe/config | sed -e $'s/,/\\\n/g'`
echo "RESULT `echo $result`"
echo "lines `echo $result | wc -l`"
duration=`echo $result | grep duration | cut -d: -f2 | sed 's/ //g' | sed 's/"//g'`
host=`echo $result | grep host | cut -d: -f2 | sed 's/ //g' | sed 's/"//g'`
port=`echo $result | grep port | cut -d: -f2 | sed 's/ //g' | sed 's/"//g'`
threads=`echo $result | grep threads | cut -d: -f2 | sed 's/ //g' | sed 's/"//g'`
preTest=`echo $result | grep preTest | cut -d: -f2 | sed 's/ //g' | sed 's/"//g'`
echo "$duration $host $port $threads $preTest"
eval `ssh-agent`
ssh-add id_rsa

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=cubic < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "wget http://XXX.XXX.XXX.XXX:3446/testFile -O /monroe/results/testFileOutput.txt < /dev/null > /dev/null 2>&1 &"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 First"

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=reno < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 Second"


ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 Third"
