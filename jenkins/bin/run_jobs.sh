#!/bin/sh
set -e

NAMES="^auto"
if [ -n "$1" ]; then
	NAMES="$1"
	shift
fi
OPTS=$@


JENKINS_CLI="java -jar /puppet/jenkins/files/jenkins-cli.jar -s http://localhost:8081/"
for all in $(${JENKINS_CLI} list-jobs | grep "${NAMES}"); do
	${JENKINS_CLI} build ${all} -s ${OPTS}
done
