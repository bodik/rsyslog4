#!/bin/sh

DESTDIR="/etc/apache2/ssl"
FQDN="$(facter fqdn)"
DOCUMENTROOT="/var/www/server"
OPTS="--non-interactive --agree-tos --email bodik@cesnet.cz"

usage() {
	echo "Usage: $0 [-t] [-d DESTDIR]"
	echo "\t-t .. request certificate from test authority"
	echo "\t-d DESTDIR .. destination directory for links to live LE certificate"
	exit 1;
}
while getopts "td:h" o; do
	case "${o}" in
		t) OPTS="${OPTS} --test-cert --force-renewal" ;;
		d) DESTDIR=${OPTARG} ;;
		h|*) usage ;;
	esac
done



if [ -f "${DESTDIR}/${FQDN}.key" ]; then
        echo "ERROR: key ${DESTDIR}/${FQDN}.key already present"
        exit 1
fi

mkdir -p ${DESTDIR}
cd ${DESTDIR} || exit 1

certbot certonly ${OPTS} --webroot --webroot-path ${DOCUMENTROOT} --cert-name ${FQDN} -d ${FQDN}
if [ $? -ne 0 ]; then
	echo "ERROR: failed to request the certificate"
	exit 1
fi

rm -d ${DOCUMENTROOT}/.well-known
chmod 640 /etc/letsencrypt/live/${FQDN}/privkey.pem /etc/letsencrypt/live/${FQDN}/cert.pem /etc/letsencrypt/live/${FQDN}/chain.pem /etc/letsencrypt/live/${FQDN}/fullchain.pem

ln -s /etc/letsencrypt/live/${FQDN}/privkey.pem ${FQDN}.key
ln -s /etc/letsencrypt/live/${FQDN}/fullchain.pem ${FQDN}.crt
