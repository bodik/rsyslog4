#!/bin/sh

if [ -z "${BRANCH}" ]; then
	export BRANCH="master"
fi

export VMNAME="rs-server"
openstack.init build
openstack.init ssh 'wget https://gitlab.meta.zcu.cz/bodik/rsyslog4/raw/master/bootstrap.install.sh && sh -x bootstrap.install.sh'
openstack.init ssh "cd /puppet && git checkout ${BRANCH}"
openstack.init ssh 'cd /puppet && sh phase2.install.sh'
openstack.init ssh 'cd /puppet && sh metalib/tests/phase2.sh'
openstack.init ssh 'cd /puppet && sh rsyslog-server.install.sh'
openstack.init ssh 'cd /puppet && sh rsyslog/tests/server.sh'

export VMNAME="rs-client1"
openstack.init build
openstack.init ssh 'wget https://gitlab.meta.zcu.cz/bodik/rsyslog4/raw/master/bootstrap.install.sh && sh -x bootstrap.install.sh'
openstack.init ssh "cd /puppet && git checkout ${BRANCH}"
openstack.init ssh 'cd /puppet && sh phase2.install.sh'
openstack.init ssh 'cd /puppet && sh metalib/tests/phase2.sh'
openstack.init ssh 'cd /puppet && sh rsyslog-client.install.sh'
openstack.init ssh 'cd /puppet && sh rsyslog/tests/client.sh'
