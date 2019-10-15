#!/bin/sh

apt-get update
apt-get install -y git puppet

if [ ! -d /puppet ]; then
	git clone https://rsyslog.metacentrum.cz/rsyslog4.git /opt/rsyslog4
	ln -sf /opt/rsyslog4 /puppet
	cd /puppet
	git remote set-url origin --push bodik@rsyslog.metacentrum.cz:/data/rsyslog4.git
else
	cd /puppet
	git pull
fi
