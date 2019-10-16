#!/bin/sh
set -e

mkdir -p /tmp/build_area
cd /tmp/build_area

# some tests are required to be run by non-root user to work properly
id builder || useradd --home-dir /tmp --no-create-home builder
chown builder /tmp/build_area

apt-get install --no-install-recommends -qqq build-essential fakeroot devscripts equivs git-buildpackage pristine-tar

if [ ! -d upstream-rsyslog ]; then
        git clone https://gitlab.meta.zcu.cz/bodik/upstream-rsyslog.git
        cd upstream-rsyslog
        git remote set-url origin --push bodik@gitlab.meta.zcu.cz:bodik/upstream-rsyslog.git
else
        cd upstream-rsyslog
        git pull
fi

if [ -z "${RBVERSION}" ]; then
       #by default we build latest revision found in collab sources
       RBVERSION=$(git branch -a | grep "\.rb[0-9]\+" | sed 's#remotes/origin/##' | sort -rV | head -1 | sed 's/[* ]//g')
fi
git checkout ${RBVERSION}

service rsyslog stop
yes | mk-build-deps --install --remove debian/control
sudo -u builder gbp buildpackage --git-export-dir=../builder -us -uc --git-debian-branch=${RBVERSION}
