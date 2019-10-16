# config file resource
#
define rsyslog::server::config {
	file { "/etc/rsyslog.d/${name}":
		content => template("${module_name}/server/rsyslog.d/${name}.erb"),
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Package['rsyslog', 'rsyslog-gssapi', 'rsyslog-relp'],
		notify  => Service['rsyslog'],
	}
}
