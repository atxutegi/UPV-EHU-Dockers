#!/bin/sh
#leNodeInterfacesInfo.txt | sed 's/.*op2.*//' | sed '/^$/d'
cd /opt/monroe

#iterations="1 2 3 4 5 6 7 8"
#iterations="1 2 3 4"
iterations="5 6 7 8"
#iterations="9 10 11 12"
#iterations="13 14 15 16"

ip route list >> /opt/monroe/metaStart.txt

#sleep 5
#fping 8.8.8.8 -c 3 -I op0 | tee /monroe/results/ping1.txt
#sleep 5
#fping 8.8.8.8 -c 3 -I op1 | tee /monroe/results/ping2.txt
#sleep 5
#fping 8.8.8.8 -c 3 -I op2 | tee /monroe/results/ping3.txt
#sleep 5

eval `ssh-agent`
ssh-add id_rsa_kau_optiplex

for ite in $iterations; do

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.core.default_qdisc=pfifo_fast < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo tc qdisc add dev enp0s31f6 root pfifo_fast < /dev/null > /dev/null 2>&1"

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.ipv4.tcp_congestion_control=cubicLog < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://130.243.26.62:3446/testFile100MB
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 CUBIC-$ite"

sleep 5

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.ipv4.tcp_congestion_control=cubic3Log < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://130.243.26.62:3446/testFile100MB
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 CUBIC3-$ite"

sleep 5

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.ipv4.tcp_congestion_control=reno < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://130.243.26.62:3446/testFile100MB
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 RENO-$ite"

sleep 5

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo tc qdisc del dev enp0s31f6 root pfifo_fast < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.core.default_qdisc=fq < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo tc qdisc add dev enp0s31f6 root fq < /dev/null > /dev/null 2>&1"

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo sysctl -w net.ipv4.tcp_congestion_control=bbr < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://130.243.26.62:3446/testFile100MB
ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 BBR-$ite"

ssh -o "StrictHostKeyChecking no" eneko@130.243.26.62 "sudo tc qdisc del dev enp0s31f6 root fq < /dev/null > /dev/null 2>&1"

sleep 5

done
