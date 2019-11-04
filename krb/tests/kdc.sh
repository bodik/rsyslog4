#!/bin/sh

. /puppet/metalib/bin/lib.sh


/usr/lib/nagios/plugins/check_procs -C kdc -c 2:
if [ $? -ne 0 ]; then
	rreturn 1 "$0 kdc check_procs"
fi

kadmin.heimdal --local get testroot@RSTEST 1>/dev/null
if [ $? -ne 0 ]; then
	rreturn 1 "$0 test principal not found"
fi


rreturn 0 "$0"
