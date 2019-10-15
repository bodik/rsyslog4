#!/bin/sh

DESTDIR="/etc/apache2/ssl"
FQDN="$(facter fqdn)"

usage() {
	echo "Usage: $0 [-t] [-d DESTDIR] [-f FQDN]"
	echo "\t-d DESTDIR .. destination directory for key/certificate files"
	echo "\t-f FQDN .. fqdn of the certificate"
	exit 1;
}
while getopts "d:f:h" o; do
	case "${o}" in
		d) DESTDIR=${OPTARG} ;;
		f) FQDN=${OPTARG} ;;
		h|*) usage ;;
	esac
done



if [ -f "${DESTDIR}/${FQDN}.key" ]; then
        echo "ERROR: key ${DESTDIR}/${FQDN}.key already present"
        exit 1
fi

mkdir -p ${DESTDIR}
cd ${DESTDIR} || exit 1

cat > ${FQDN}.cfg << __EOF__
[req]
default_bits = 4096
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = req_ext
prompt = no

[req_distinguished_name]
commonName = '${FQDN}'

[req_ext]
subjectAltName = 'DNS.1:${FQDN}'
__EOF__

openssl req -new -newkey rsa -nodes -x509 -days 365 -keyout ${FQDN}.key -out ${FQDN}.crt -config ${FQDN}.cfg
chmod 640 ${FQDN}.cfg ${FQDN}.key ${FQDN}.crt 
