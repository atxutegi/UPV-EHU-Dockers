#!/bin/sh
ip=`ifconfig | grep 172.17 | awk '{print $2}'`
sum=1
port2=`echo "$1 + $sum" | bc -l | cut -d. -f1`
./register.sh $ip mcptt_caller_A.csv demo.nemergent.com $1
./register.sh $ip mcptt_caller_B.csv demo.nemergent.com $port2

./mcptt_answer_manual_version_13_3_0.sh $ip mcptt_caller_B.csv demo.nemergent.com

./mcptt_private_call_manual_version_13_3_0.sh $ip mcptt_caller_A.csv demo.nemergent.com
