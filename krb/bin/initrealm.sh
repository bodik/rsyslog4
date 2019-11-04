#!/bin/sh

if [ -z "$1" ]; then
	echo "ERROR: realm argument required"
	exit 1
fi
REALM="$1"

service heimdal-kdc stop

rm /var/lib/heimdal-kdc/heimdal.db
rm /var/lib/heimdal-kdc/heimdal.mkey

kadmin.heimdal --local init --realm-max-ticket-life=10h --realm-max-renewable-life=10h ${REALM}
kadmin.heimdal --local ank --use-defaults --random-key testroot@${REALM}

service heimdal-kdc start
