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
ssh-add id_rsa_qone
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
#ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -e$preTest
cp outputData.txt /monroe/results/
cp /opt/monroe/out-"$1"-"$2".txt /monroe/results/resultTCP-"$1"-"$2".txt
rate=`cat /opt/monroe/out-"$1"-"$2".txt | grep 'Total Down' | cut -d ' ' -f3`
latency=`cat /opt/monroe/out-"$1"-"$2".txt | grep -A5 'Total Down' | grep 'Ping' | cut -d ' ' -f8 | cut -d . -f1`
echo "rate $rate latency $latency"
latencyFinal=`echo $latency'0'`
echo "latency2 $latencyFinal"
cd maril-Model
./bin/mbm_client --socket_type=udp --port=42042 --rtt=$latency --rate=$rate --server=$host
cp /opt/monroe/out-"$1"-"$2".txt /monroe/results/resultModel-"$1"-"$2".txt
ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testKiller.sh Node39 WIND'
#ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testKiller.sh'
