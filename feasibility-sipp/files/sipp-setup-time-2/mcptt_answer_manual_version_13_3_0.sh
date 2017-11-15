#!/bin/bash

INPUT=$2

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

USER_ID=`cat $INPUT | awk 'BEGIN{ RS = "" ; FS = ";" }{ print $2  }'`

INPUT=port_$USER_ID.inf
sudo killall nc
while read -r port
do
	PORT=$port
	sudo sipp -sf mcptt_answer_manual_version_13_3_0.xml -inf $2 -m 1 -i $1 -p $PORT -mi $1 -mp 14000 -bg -trace_err -trace_logs -nd -fd 5 -trace_rtt -rtt_freq 1 $3:5070 
done < $INPUT
