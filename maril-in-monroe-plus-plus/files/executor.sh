#!/bin/bash
cd /opt/monroe
#java maril.client.marilClientLaunch -d3 -h158.227.68.19 -p3446 -t3
python experiment4.py &
java maril.client.marilClientLaunch -d5 -h85.17.254.6 -p3446 -t3
cp outputData.txt /monroe/results/
