# Class will ensure installation of rsyslog packages and configures daemon to
# client mode eg. forwards all logs to rsyslog server using omrelp or omgssapi
# on krb5 enabled nodes
#
class rsyslog::client (
	$rsyslog_server = undef,
	$forward_type   = 'omfwd',
) {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	require rsyslog::install
	service { 'rsyslog': ensure => running, }

	file { '/etc/rsyslog.d/meta-remote.conf':
		ensure  => $rsyslog_server ? { undef => absent, default => present },
		content => template("${module_name}/client/meta-remote-${forward_type}.conf.erb"),
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		notify  => Service['rsyslog'],
	}
}
