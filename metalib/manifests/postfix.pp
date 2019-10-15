# Installs postfix as local MTA
#
class metalib::postfix() {
        notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	package { 'postfix': ensure => installed }
	service { 'postfix': }

	augeas { 'postfix config':
		context => '/files/etc/postfix/main.cf',
		changes => ['set /files/etc/postfix/main.cf/inet_interfaces loopback-only'],
		require => Package['postfix'],
		notify  => Service['postfix']
	}

	file { '/etc/mailname':
		content => "${facts['networking']['fqdn']}\n",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
	}
}
