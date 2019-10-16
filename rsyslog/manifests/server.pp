# Ensures installation of rsyslog packages from metacentrum repository and
# configures service to central logging server
#
class rsyslog::server (
	$perhost         = false,
	$pertime         = true,
) {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	require rsyslog::install
	service { 'rsyslog': ensure => running, }

	rsyslog::server::config { [
		'00-server-globals.conf',

		'05-input-imudp.conf',
		'05-input-imtcp.conf',
		'05-input-imrelp.conf',

		'10-log-service-auth.conf',
		'10-log-service-modules.conf',
		'10-log-service-pbs.conf',

		'zz_stopnonlocalhost.conf'
		]:
	}

	if ($perhost) { rsyslog::server::config { '10-log-perhost.conf': } }
	if ($pertime) { rsyslog::server::config { '10-log-pertime.conf': } }

	if (file_exists ('/etc/krb5.keytab') == 1) {
		rsyslog::server::config { '05-input-imgssapi.conf': }
	        notice('imgssapi ACTIVE')
	}
}
