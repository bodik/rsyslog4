#!/bin/sh

. /puppet/metalib/bin/lib.sh

CURL="curl --silent --insecure"


/usr/lib/nagios/plugins/check_procs --argument-array=/usr/share/jenkins/jenkins.war -c 2:2
if [ $? -ne 0 ]; then
	rreturn 1 "$0 check_procs"
fi

AGE=$(ps h -o etimes $(pgrep -f /usr/share/jenkins/jenkins.war|tail -1))
if [ $AGE -lt 30 ] ; then
	echo "INFO: jenkins service warming up"
	sleep 30
fi

${CURL} "http://$(facter fqdn):8081/" | grep '<title>Dashboard \[Jenkins\]</title>'
if [ $? -ne 0 ]; then
	rreturn 1 "$0 web interface not found"
fi


rreturn 0 "$0"
