#!/bin/sh

. /puppet/metalib/bin/lib.sh


RUNNIG=$(iptables-save | grep INPUT | grep -v "f2b\-" | wc -l)
CONFIG=$(cat /etc/iptables/rules.v4 | grep INPUT | wc -l)

if [ "${RUNNIG}" != "${CONFIG}" ]; then
	rreturn 1 "$0 running firewall differs from config"
fi


RUNNIG=$(ip6tables-save | grep INPUT | grep -v "f2b\-" | wc -l)
CONFIG=$(cat /etc/iptables/rules.v6 | grep INPUT | wc -l)

if [ "${RUNNIG}" != "${CONFIG}" ]; then
	rreturn 1 "$0 running firewall6 differs from config"
fi


rreturn 0 "$0"
