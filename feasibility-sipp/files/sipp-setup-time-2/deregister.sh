#!/bin/bash

INPUT=$2

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

USER_ID=`cat $INPUT | awk 'BEGIN{ RS = "" ; FS = ";" }{ print $2  }'`

INPUT=port_$USER_ID.inf


while read -r port
do
	PORT=$port
	sipp -sf unregister_client_mcptt.xml -inf $2 -m 1 -i $1 -p $PORT -trace_err -bg -nd -fd 5 $3:5070 
done < $INPUT
