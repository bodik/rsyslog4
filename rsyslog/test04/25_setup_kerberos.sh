#!/bin/sh

# resolve kdc
SERVER_IP=$(openstack.init list -f value -c Name -c Networks | grep 'rs-server' | awk '{print $3}')
SERVER_HOSTNAME=$(host ${SERVER_IP} | rev | awk '{print $1}' | rev | sed 's/\.$//')
echo "DEBUG: server name ${SERVER_HOSTNAME}"

# add kerberos configs on all nodes
CLIENT_MANIFEST="class {'krb::client': kdc_server => '${SERVER_HOSTNAME}'}"
openstack.init ssh_multi 'rs-' "pa.sh -e \"${CLIENT_MANIFEST}\""

# distribute keytabs

. /dev/shm/config
eval $(ssh-agent -s)
ssh-add ${SSHKEY}

for NODE_IP in $(openstack.init list -f value -c Name -c Networks | grep 'rs-' | awk '{print $3}'); do
	NODE_HOSTNAME=$(host ${NODE_IP} | rev | awk '{print $1}' | rev | sed 's/\.$//')
	echo "DEBUG: new key for ${NODE_HOSTNAME}"

        VMNAME=rs-server openstack.init ssh -A "
		rm -f /dev/shm/temporary.krb5.keytab;
		kadmin.heimdal --local get host/${NODE_HOSTNAME} 1>/dev/null || kadmin.heimdal --local ank --use-defaults --random-key host/${NODE_HOSTNAME};
		kadmin.heimdal --local cpw --random-key host/${NODE_HOSTNAME};
		kadmin.heimdal --local ext_keytab --keytab=/dev/shm/temporary.krb5.keytab host/${NODE_HOSTNAME};
		scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /dev/shm/temporary.krb5.keytab ${NODE_HOSTNAME}:/etc/krb5.keytab;
		rm -f /dev/shm/temporary.krb5.keytab
	"
done

eval $(ssh-agent -k)

# ensure imgssapi on server
VMNAME=rs-server openstack.init ssh "cd /puppet && sh rsyslog-server.install.sh"
