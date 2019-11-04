#!/bin/sh
# cloud dev helper to kinit for TGT and TGS to current git repository origin
# required when developing on the nodes with test realm

REMOTE=$(git remote show origin -n | grep 'Push  URL')
REMOTE_USER=$(echo ${REMOTE} | sed 's/.*: \(.\+\)@.*/\1/')
REMOTE_HOSTNAME=$(echo ${REMOTE} | sed 's/.*@\(.\+\):.*/\1/')

KRB5_CONFIG=/puppet/metalib/files/base/krb5.conf kinit ${REMOTE_USER}
KRB5_CONFIG=/puppet/metalib/files/base/krb5.conf kgetcred host/${REMOTE_HOSTNAME}
