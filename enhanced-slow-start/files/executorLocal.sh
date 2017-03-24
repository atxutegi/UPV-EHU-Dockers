#!/bin/sh
cd /opt/monroe
result=`echo $1 | sed -e $'s/,/\\\n/g'`
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
#ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
#ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh maril-in-monroe-TCPserver/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
java maril.client.marilClientLaunch -d$duration -h$host -p$port -t$threads -e$preTest | tee /opt/monroe/outTCP.txt
#cp outputData.txt /monroe/results/outputData.txt
cp /opt/monroe/outTCP.txt /monroe/results/
#rate=`cat /opt/monroe/outTCP.txt | grep 'Total Down' | cut -d ' ' -f3`
#latency=`cat /opt/monroe/outTCP.txt | grep -A5 'Total Down' | grep 'Ping' | cut -d ' ' -f8 | cut -d . -f1`
rate=`cat /monroe/results/outTCP.txt | grep 'Total Down' | cut -d ' ' -f3`
latency=`cat /monroe/results/outTCP.txt | grep -A5 'Total Down' | grep 'Ping' | cut -d ' ' -f8 | cut -d . -f1`
echo "rate $rate latency $latency"
latencyFinal=`echo $latency'000'`
echo "latency2 $latencyFinal"
percentage=0.3
rateFinal=`echo "$rate * $percentage" | bc -l | cut -d. -f1`
echo "rateFinal $rateFinal"
cd maril-Model
./bin/mbm_client --socket_type=udp --port=42042 --rtt=$latency --rate=$rateFinal --server=$host | tee /opt/monroe/outModel.txt
cp /opt/monroe/outModel.txt /monroe/results/
#ssh -o "StrictHostKeyChecking no" operario@mad.velocimetro.org 'sh maril-in-monroe-TCPserver/testKiller.sh $1 $2'
#ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh maril-in-monroe-TCPserver/testKiller.sh $1 $2"


#percentage=0.8
#rate2=`echo "$rate * $percentage" | bc -l`
