#!/bin/bash

PORT=$4

INPUT=$2

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

USER_ID=`cat $INPUT | awk 'BEGIN{ RS = "" ; FS = ";" }{ print $2  }'`
echo $PORT > "port_$USER_ID.inf"
sudo killall nc

sipp -sf register_client_mcptt.xml -inf $2 -m 1 -i $1 -p $PORT -trace_err -bg -nd -fd 5 $3:5070 