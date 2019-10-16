#!/bin/sh

SERVER_IP=$(openstack.init list -f value -c Name -c Networks | grep 'rs-server' | awk '{print $3}')
SERVER_HOSTNAME=$(host ${SERVER_IP} | rev | awk '{print $1}' | rev | sed 's/\.$//')
echo "DEBUG: server name ${SERVER_HOSTNAME}"

CLIENT_MANIFEST="class {'rsyslog::client': forward_type => 'omfwd', rsyslog_server => '${SERVER_HOSTNAME}'}"
openstack.init ssh_multi 'rs-client' "pa.sh -e \"${CLIENT_MANIFEST}\""
