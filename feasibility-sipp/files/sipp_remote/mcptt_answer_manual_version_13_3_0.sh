#!/bin/bash

PORT=$(shuf -i 13000-13999 -n 1)

sipp -sf register_client_mcptt.xml -inf $2 -m 1 -i $1 -p $PORT -trace_err -nd -fd 5 $3:5070
killall nc
sipp -sf mcptt_answer_manual_version_13_3_0.xml -inf $2 -m 1 -i $1 -p $PORT -mi $1 -mp 14000 -trace_err -trace_logs -nd -fd 5 $3:5070
killall nc
sipp -sf unregister_client_mcptt.xml -inf $2 -m 1 -i $1 -p $PORT -trace_err -nd -fd 5 $3:5070
