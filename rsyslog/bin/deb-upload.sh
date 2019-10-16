#!/bin/sh

SOURCE="/tmp/build_area/builder"
FRONT="bodik@rsyslog.metacentrum.cz"
BASE="/data/rsyslog4-packages"
GPGDIR="${BASE}/keys"
TARGET="${BASE}/debian"

ssh ${FRONT} "rm -r ${TARGET}; mkdir -p ${TARGET} ${TARGET}/conf ${TARGET}/incomming"
scp ${SOURCE}/*deb ${FRONT}:${TARGET}/incomming
scp /puppet/rsyslog/files/reprepro-distributions ${FRONT}:${TARGET}/conf/distributions
ssh ${FRONT} "reprepro --gnupghome ${GPGDIR} -b ${TARGET} includedeb buster ${TARGET}/incomming/*deb"
