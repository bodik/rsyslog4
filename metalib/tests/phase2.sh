#!/bin/sh

. /puppet/metalib/bin/lib.sh



dpkg -l firmware-linux-nonfree 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	rreturn 1 "$0 apt/dpkg non-free not installed"
fi


/usr/lib/nagios/plugins/check_procs --argument-array=/usr/bin/fail2ban-server -c 1:1
if [ $? -ne 0 ]; then
	rreturn 1 "$0 fail2ban check_procs"
fi


/usr/lib/nagios/plugins/check_procs --argument-array=/usr/lib/postfix/sbin/master -c 1:1
if [ $? -ne 0 ]; then
        rreturn 1 "$0 postfix check_procs"
fi
mailq 1>/dev/null
if [ $? -ne 0 ]; then
        rreturn 1 "$0 postfix mailq"
fi


sh /puppet/iptables/tests/iptables.sh
if [ $? -ne 0 ]; then
	rreturn 1 "$0 iptables differs"
fi


sh /puppet/bacula/tests/client.sh
if [ $? -ne 0 ]; then
	rreturn 1 "$0 bacula-fd not runinng"
fi



rreturn 0 "$0"
