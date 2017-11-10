#!/bin/sh
ip route list >> /opt/monroe/metaStart.txt

sleep 5
fping 8.8.8.8 -c 3 -I op0 | tee /monroe/results/ping1.txt
sleep 5
fping 8.8.8.8 -c 3 -I op1 | tee /monroe/results/ping2.txt
sleep 5
fping 8.8.8.8 -c 3 -I op2 | tee /monroe/results/ping3.txt
sleep 5
