#!/bin/sh

. /puppet/metalib/bin/lib.sh


dpkg -l rsyslog | grep -E " 8\..+rb[0-9]{2}"
dpkg -l rsyslog-gssapi | grep -E " 8\..+rb[0-9]{2}"
dpkg -l rsyslog-relp | grep -E " 8\..+rb[0-9]{2}"

/usr/lib/nagios/plugins/check_procs -C rsyslogd -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 rsyslogd check_procs"
fi

netstat -nlpa | grep "$(pidof rsyslogd)/rsy" | grep LISTEN | grep :514
if [ $? -ne 0 ]; then
	rreturn 1 "$0 rsyslogd tcp listener"
fi

netstat -nlpa | grep "$(pidof rsyslogd)/rsy" | grep LISTEN | grep :516
if [ $? -ne 0 ]; then
	rreturn 1 "$0 rsyslogd relp listener"
fi

if [ -f /etc/krb5.keytab ]; then
	netstat -nlpa | grep "$(pidof rsyslogd)/rsy" | grep LISTEN | grep :515
	if [ $? -ne 0 ]; then
		rreturn 1 "$0 rsyslogd gssapi listener"
	fi
fi


rreturn 0 "$0"
