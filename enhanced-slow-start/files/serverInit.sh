#!/bin/sh
#sudo ethtool -K $1 tso off
#sudo ethtool -K $1 gro off
#sudo ethtool -K $1 gso off

sysctl -w net.ipv4.tcp_no_metrics_save=1 #no TCP record of previous connections whatsoever #QUESTION 1
/sbin/modprobe tcp_hybla
/sbin/modprobe tcp_westwood
/sbin/modprobe tcp_illinois
/sbin/modprobe tcp_yeah
sysctl -w net.ipv4.tcp_allowed_congestion_control="cubic reno hybla westwood illinois yeah"
sysctl -w net.ipv4.tcp_available_congestion_control="cubic reno hybla westwood illinois yeah"
