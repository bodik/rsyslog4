#!/bin/sh
set -e

. /puppet/metalib/bin/lib.sh

TESTID="ti$(date +%s)"
COUNT=11
DISRUPT="none"
FORWARD_TYPE="omfwd"
CLOUD="openstack"
WAITRECOVERY=120

usage() { echo "Usage: $0 [-t <TESTID>] [-c <COUNT>] [-d <DISRUPT>] [-f <FORWARD_TYPE>]" 1>&2; exit 1; }
while getopts "t:c:d:f:" o; do
	case "${o}" in
		t) TESTID=${OPTARG} ;;
		c) COUNT=${OPTARG} ;;
		d) DISRUPT=${OPTARG} ;;
		f) FORWARD_TYPE=${OPTARG} ;;
		*) usage ;;
	esac
done
shift "$(($OPTIND-1))"
CLOUDBIN="/puppet/jenkins/bin/${CLOUD}.init"


echo "INFO: begin phase -- setup"

NODES=$(${CLOUDBIN} list -f value -c Name | grep "rs-client" | awk '{print $1}')
NODESCOUNT=$(echo ${NODES} | wc -w)
SERVER_IP=$(openstack.init list -f value -c Name -c Networks | grep 'rs-server' | awk '{print $3}')
SERVER_HOSTNAME=$(host ${SERVER_IP} | rev | awk '{print $1}' | rev | sed 's/\.$//')
CLIENT_MANIFEST="class {'rsyslog::client': forward_type => 'omfwd', rsyslog_server => '${SERVER_HOSTNAME}'}"
echo "DEBUG: nodescount ${NODESCOUNT}"
echo "DEBUG: server_hostname ${SERVER_HOSTNAME}"

${CLOUDBIN} ssh_multi 'rs-' "cd /puppet && sh bootstrap.install.sh 1>/dev/null 2>/dev/null"
${CLOUDBIN} ssh_multi 'rs-client' "pa.sh -e \"${CLIENT_MANIFEST}\" 1>/dev/null 2>/dev/null"
${CLOUDBIN} ssh_multi 'rs-client' "cd /puppet && rsyslog/test04/logs_clean.sh 1>/dev/null 2>/dev/null"
${CLOUDBIN} ssh_multi 'rs-server' "cd /puppet && rsyslog/test04/logs_clean.sh 1>/dev/null 2>/dev/null"

for all in $NODES; do
	echo "INFO: node $all config"
	VMNAME=${all} ${CLOUDBIN} ssh "dpkg -l rsyslog | tail -n1; cat -n /etc/rsyslog.d/meta-remote.conf" 2>&1 | sed "s/^/$all /"
done

echo "INFO: reconnecting all nodes"
${CLOUDBIN} ssh_multi 'rs-server' 'service rsyslog stop'
${CLOUDBIN} ssh_multi 'rs-server' 'service rsyslog start'
${CLOUDBIN} ssh_multi 'rs-client' "service rsyslog restart"
sleep 10

${CLOUDBIN} ssh_multi 'rs-server' 'netstat -nlpa | grep rsyslog | grep ESTA | grep ":51[456] "'
CONNS=$(${CLOUDBIN} ssh_multi 'rs-server' 'netstat -nlpa | grep rsyslog | grep ESTA | grep ":51[456] " | wc -l' | head -n1)
echo "INFO: connected nodes ${CONNS}"
if [ ${CONNS} -ne ${NODESCOUNT} ]; then
	rreturn 1 "$0 missing nodes on startup"
fi

echo "INFO: end phase -- setup"


echo "INFO: phase begin -- body"

for all in ${NODES}; do
	echo "INFO: node ${all} test_run.sh"
	VMNAME=${all} ${CLOUDBIN} ssh "/puppet/rsyslog/test04/test_run.sh -t ${TESTID} -c ${COUNT} </dev/null 1>/dev/null 2>/dev/null" &
done

# disrupts
sleep 10
echo "INFO: disrupt ${DISRUPT} begin"
case ${DISRUPT} in
	restart)
		${CLOUDBIN} ssh_multi 'rs-server' 'service rsyslog restart'
	;;

	killserver)
		${CLOUDBIN} ssh_multi 'rs-server' 'kill -9 `pidof rsyslogd`'
		${CLOUDBIN} ssh_multi 'rs-server' 'service rsyslog restart'
	;;

	tcpkill)
		${CLOUDBIN} ssh_multi 'rs-server' "/usr/bin/timeout 180 /puppet/rsyslog/test04/tcpkill -i eth0 port 515 or port 514 or port 516 2>/dev/null || /bin/true"
	;;

	ipdrop)
		${CLOUDBIN} ssh_multi 'rs-server' 'iptables -I INPUT -m multiport -p tcp --dport 514,515,516 -j DROP'
		sleep 180
		${CLOUDBIN} ssh_multi 'rs-server' 'iptables -D INPUT -m multiport -p tcp --dport 514,515,516 -j DROP'
	;;
esac
echo "INFO: disrupt ${DISRUPT} end"

echo "INFO: waiting for nodes to finish"
wait
echo "INFO: nodes finished"
echo "INFO: waiting to sync ${WAITRECOVERY} secs"
sleep ${WAITRECOVERY}

echo "INFO: phase end -- body"


echo "INFO: phase begin -- results"

## test results
for all in ${NODES}; do
	NODEIP=$(VMNAME=${all} ${CLOUDBIN} ip)
	${CLOUDBIN} ssh_multi 'rs-server' "/puppet/rsyslog/test04/result_client.py -n ${NODEIP} -t ${TESTID} -c ${COUNT} 1>>/tmp/test_results.${TESTID}.log 2>&1"
done
${CLOUDBIN} ssh_multi 'rs-server' "cat /tmp/test_results.${TESTID}.log"
${CLOUDBIN} ssh_multi 'rs-server' "/puppet/rsyslog/test04/result_test.py -t ${TESTID} -c ${COUNT} -n ${NODESCOUNT} -D ${DISRUPT} -f ${FORWARD_TYPE} -l /tmp/test_results.${TESTID}.log --debug"
RET=$?

echo "INFO: phase end -- results"

rreturn ${RET} "$0"
