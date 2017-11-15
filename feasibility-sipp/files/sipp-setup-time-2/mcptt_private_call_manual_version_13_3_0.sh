#!/bin/bash

INPUT=$2

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

USER_ID=`cat $INPUT | awk 'BEGIN{ RS = "" ; FS = ";" }{ print $2  }'`

INPUT=port_$USER_ID.inf


while read -r port
do
	PORT=$port
	sudo sipp -sf mcptt_private_call_manual_version_13_3_0.xml -inf $2 -i $1 -p $PORT -mi $1 -mp 12000 -m 1 -trace_err -trace_logs -nd -fd 5 -trace_rtt -rtt_freq 1 $3:5070 
done < $INPUT


sudo killall nc
DATE_STRING=`date "+%d-%m-%y_%H-%M-%S"`
ORIG_FILENAME=`ls | grep -e mcptt_private_call_manual_version_13_3_0.*_rtt`
sudo mv $ORIG_FILENAME setup_time_$DATE_STRING.csv