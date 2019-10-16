#!/bin/sh

. /puppet/metalib/bin/lib.sh


dpkg -l rsyslog | grep -E " 8\..+rb[0-9]{2}"
dpkg -l rsyslog-gssapi | grep -E " 8\..+rb[0-9]{2}"
dpkg -l rsyslog-relp | grep -E " 8\..+rb[0-9]{2}"

/usr/lib/nagios/plugins/check_procs -C rsyslogd -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 rsyslogd check_procs"
fi


rreturn 0 "$0"
