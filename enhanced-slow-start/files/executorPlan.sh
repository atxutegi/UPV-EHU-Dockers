#!/bin/sh
cd /opt/monroe

result=`cat /monroe/config | sed -e $'s/,/\\\n/g'`
echo "RESULT `echo $result`"
echo "lines `echo $result | wc -l`"

python experimentXplore.py > /opt/monroe/metaStart.txt
ifconfig >> /opt/monroe/metaStart.txt
route -n >> /opt/monroe/metaStart.txt
ip route list >> /opt/monroe/metaStart.txt
cp /opt/monroe/metaStart.txt /monroe/results/
id=`cat /opt/monroe/metaStart.txt | grep NodeId | head -1 | cut -d: -f 6 | sed 's/ //g' | sed 's/Timestamp//'`

cat /opt/monroe/metaStart.txt | grep maril | cut -d: -f 9 | sed 's/ //' | sed 's/ CID//' | sort | uniq | sed 's/ /\\s/g' > operators.txt
operators2=`cat operators.txt | tr '\n' ' '`
echo $operators2
for oper in $operators2;do
	cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 14 | sed 's/ //g' | sed 's/IMEI//' >> addresses.txt
	cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 15 | sed 's/ //g' | sed 's/RSRQ//' >> imeis.txt
	cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 20 | sed 's/ //g' | sed 's/InternalIPAddress//' >> interfaces.txt
	cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 21 | sed 's/ //g' | sed 's/InternalInterface//' >> internalAddresses.txt
	cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 22 | sed 's/ //g' | sed 's/GPS//' >> internalInterfaces.txt
done
paste operators.txt imeis.txt internalInterfaces.txt internalAddresses.txt interfaces.txt addresses.txt | pr -t -e24 > wholeNodeInterfacesInfo.txt
cp wholeNodeInterfacesInfo.txt /monroe/results/

python experimentMetaInfo.py & > /opt/monroe/metaExecution.txt

for o in $operators2;do
	echo "The iteration is o=$o" >> /opt/monroe/metaStart.txt
	cat /opt/monroe/metaStart.txt | grep '^default' | sort | uniq | awk '{print $3" "$5}' >> /opt/monroe/defaults.txt
	def=`cat /opt/monroe/metaStart.txt | grep '^default' | sort | uniq | awk '{print $5}' | tr '\n' ' '`
	for j in $def;do
		line=`cat /opt/monroe/defaults.txt | grep -n $j | cut -d: -f1`
		inst=`cat /opt/monroe/defaults.txt | head -$line | tail -1`
		echo "Instruction deleting $inst" >> /opt/monroe/metaStart.txt		
		route del -net default netmask 0.0.0.0 gw $inst
	done
	o2=`echo "$o" | sed 's/\\\s/\\\\\\\\\s/'`
	A=`cat wholeNodeInterfacesInfo.txt | grep $o2 | awk '{print $4}' | cut -d. -f1`
	B=`cat wholeNodeInterfacesInfo.txt | grep $o2 | awk '{print $4}' | cut -d. -f2`
	C=`cat wholeNodeInterfacesInfo.txt | grep $o2 | awk '{print $4}' | cut -d. -f3`
	interface=`cat wholeNodeInterfacesInfo.txt | grep $o2 | awk '{print $3}'`
	ip route list >> /opt/monroe/metaStart.txt
	echo "The iteration is $o"
	echo "About to change with route add -net default netmask 0.0.0.0 gw $A.$B.$C.1 $interface" >> /opt/monroe/metaStart.txt
	route add -net default netmask 0.0.0.0 gw $A.$B.$C.1 $interface 
	ip route list >> /opt/monroe/metaStart.txt
	cp /opt/monroe/metaStart.txt /monroe/results/metaStart2.txt
	sh serverInit.sh $interface
	sh executorSingle.sh Node$id $o 	
done
cp /opt/monroe/metaStart.txt /monroe/results/metaStart2.txt
echo "FINISHED"
kill -9 `ps -ef | grep "[e]xperimentMetaInfo" | awk '{print $2}'` 
cp /opt/monroe/metaExecution.txt /monroe/results/
