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
id=`cat /etc/nodeid`

sleep 5
fping 8.8.8.8 -c 3 -I op0 | tee /monroe/results/pingop0.txt
sleep 5
fping 8.8.8.8 -c 3 -I op1 | tee /monroe/results/pingop1.txt
sleep 5
fping 8.8.8.8 -c 3 -I op2 | tee /monroe/results/pingop2.txt
sleep 5
fping 8.8.8.8 -c 3 -I op3 | tee /monroe/results/pingop3.txt
sleep 5

operators3=`ls -altrh /monroe/results/ping* | awk '$5!=0 {print}' | sed 's/.*ping//' | sed 's/.txt//' | tr '\n' ' '`
operatorsNoConnection=`ls -altrh /monroe/results/ping* | awk '$5==0 {print}' | sed 's/.*ping//' | sed 's/.txt//' | tr '\n' ' '`
nothing=""
wwan0="wwan0"

#cat /opt/monroe/metaStart.txt | grep upvehu | cut -d: -f 8 | sed 's/ //' | sed 's/ CID//' | sort | uniq | sed 's/ /\\s/g' > operators.txt
#operators2=`cat operators.txt | tr '\n' ' '`
#echo $operators2
for oper in $operators3;do
        if [ `cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 21 | sed 's/ //g' | sed 's/GPS//'` == $nothing ]
	then
		echo "FAIL - $oper without metadata" >> /opt/monroe/metaStart.txt	
	else
		if [ `cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 19 | sed 's/ //g' | sed 's/InternalIPAddress//'` = $wwan0 ]
		then
			echo "FAIL - $oper is wwan0" >> /opt/monroe/metaStart.txt		
		else
			cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 8 | sed 's/ //g' | sed 's/ CID//' | sed 's/ /\\s/g' >> operators.txt
			cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 13 | sed 's/ //g' | sed 's/IMEI//' >> addresses.txt
			cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 14 | sed 's/ //g' | sed 's/RSRQ//' >> imeis.txt
			cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 19 | sed 's/ //g' | sed 's/InternalIPAddress//' >> interfaces.txt
			#cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 20 | sed 's/ //g' | sed 's/InternalInterface//' >> internalAddresses.txt
			cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 21 | sed 's/ //g' | sed 's/GPS//' >> internalInterfaces.txt
			interfaceInter=`cat /opt/monroe/metaStart.txt | grep ''$oper'' | head -1 | cut -d: -f 21 | sed 's/ //g' | sed 's/GPS//'`
        		cat /opt/monroe/metaStart.txt | grep -A1 ''$interfaceInter'' | grep 'inet addr' | awk '{print $2}' | cut -d: -f2 >> internalAddresses.txt
		fi
	fi
done
operators2=`cat operators.txt | grep Telia | tr '\n' ' '`
paste operators.txt imeis.txt internalInterfaces.txt internalAddresses.txt interfaces.txt addresses.txt | pr -t -e24 > wholeNodeInterfacesInfo.txt
rm operators.txt imeis.txt internalInterfaces.txt internalAddresses.txt interfaces.txt addresses.txt
cp wholeNodeInterfacesInfo.txt /monroe/results/

#python experimentMetaInfo.py & > /opt/monroe/metaExecution.txt

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
	route -n >> /opt/monroe/metaStart.txt
	echo "The iteration is $o"
	echo "About to change with route add -net default netmask 0.0.0.0 gw $A.$B.$C.1 $interface" >> /opt/monroe/metaStart.txt
	route add -net default netmask 0.0.0.0 gw $A.$B.$C.1 $interface 
	#route add default gw $A.$B.$C.1 $interface
	ip route list >> /opt/monroe/metaStart.txt
	route -n >> /opt/monroe/metaStart.txt
	traceroute www.google.es >> /opt/monroe/metaStart.txt
	cp /opt/monroe/metaStart.txt /monroe/results/metaStart2.txt
	

	sh executorSingleKAU.sh Node$id $o
 	
done

#ip route list >> /opt/monroe/metaStart.txt

#sh executorSingleKAU.sh Node$id YYY

cp /opt/monroe/metaStart.txt /monroe/results/metaStart.txt
echo "FINISHED"
kill -9 `ps -ef | grep "[e]xperimentMetaInfo" | awk '{print $2}'` 
cp /opt/monroe/metaExecution.txt /monroe/results/
