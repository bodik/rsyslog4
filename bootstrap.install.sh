#!/bin/sh

apt-get update
apt-get install -y git puppet

if [ ! -d /puppet ]; then
	git clone https://gitlab.meta.zcu.cz/bodik/rsyslog4.git /opt/rsyslog4
	ln -sf /opt/rsyslog4 /puppet
	cd /puppet
	git remote set-url origin --push git@gitlab.meta.zcu.cz:bodik/rsyslog4.git
else
	cd /puppet
	git pull
fi
