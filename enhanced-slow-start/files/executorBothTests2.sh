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

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=cubic < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -e$preTest
cp outputData.txt /monroe/results/outputData-"$1"-"$2"-"$threads"Tcubic.txt
cp /opt/monroe/out-"$1"-"$2".txt /monroe/results/resultTCP-"$1"-"$2"-"$threads"Tcubic.txt
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 '$threads'Tcubic"

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=reno < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t1 -e$preTest
cp outputData.txt /monroe/results/outputData-"$1"-"$2"-1Treno.txt
cp /opt/monroe/out-"$1"-"$2".txt /monroe/results/resultTCP-"$1"-"$2"-1Treno.txt
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 1Treno"

rate=`cat /opt/monroe/out-"$1"-"$2".txt | grep 'Total Down' | tail -1 | cut -d ' ' -f3`
latency=`cat /opt/monroe/out-"$1"-"$2".txt | grep -A5 'Total Down' | grep 'Ping' | tail -1 | cut -d ' ' -f8 | cut -d . -f1`
echo "rate $rate latency $latency"
increment=10
latencyFinal=`echo "$latency + $increment" | bc -l | cut -d. -f1`
echo "latency2 $latencyFinal"
percentage=0.8
rate1=`echo "$rate * $percentage" | bc -l | cut -d. -f1`
percentage=0.9
rate2=`echo "$rate * $percentage" | bc -l | cut -d. -f1`
percentage=1
rate3=`echo "$rate * $percentage" | bc -l | cut -d. -f1`
cd maril-Model
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
./bin/mbm_client --socket_type=udp --port=42042 --rtt=$latencyFinal --rate=$rate1 --server=$host
sleep 60
./bin/mbm_client --socket_type=udp --port=42042 --rtt=$latencyFinal --rate=$rate2 --server=$host
sleep 60
./bin/mbm_client --socket_type=udp --port=42042 --rtt=$latencyFinal --rate=$rate3 --server=$host
cp /opt/monroe/out-"$1"-"$2".txt /monroe/results/resultModel-"$1"-"$2"-Model.txt
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2 Model"

#ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=reno < /dev/null > /dev/null 2>&1"
#percentage=0.8
#rate2=`echo "$rate * $percentage" | bc -l`
