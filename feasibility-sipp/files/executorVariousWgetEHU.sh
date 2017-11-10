#!/bin/sh
cd /opt/monroe


iterations="1"

ip route list >> /opt/monroe/metaStart.txt

eval `ssh-agent`
ssh-add id_rsa_qone

for ite in $iterations; do

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=cubic < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://158.227.68.19:3446/testFile30MB
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 CUBIC-$ite"

sleep 5

ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sudo sysctl -w net.ipv4.tcp_congestion_control=reno < /dev/null > /dev/null 2>&1"
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 'sh wgetCCAsSlowStart/testLauncher.sh `wget http://ipinfo.io/ip -qO -` `date '+%F_%H-%M-%S'`  < /dev/null > /dev/null 2>&1'
sleep 5
wget http://158.227.68.19:3446/testFile30MB
ssh -o "StrictHostKeyChecking no" qospeter@158.227.68.19 "sh wgetCCAsSlowStart/testKiller.sh $1 $2 RENO-$ite"

sleep 5

done
