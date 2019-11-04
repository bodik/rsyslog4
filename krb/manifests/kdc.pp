# ensures heimdal kdc in simple configuration
#
class krb::kdc (
	$realm = 'RSTEST',
) {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	package { 'heimdal-clients': ensure => installed }
	package { 'heimdal-kdc':
		ensure  => installed,
		require => Package['heimdal-clients'],
	}
	service { 'heimdal-kdc': }

	file { '/etc/heimdal-kdc/kdc.conf':
		source  => "puppet:///modules/${module_name}/kdc/kdc.conf",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Package['heimdal-kdc'],
		notify  => Service['heimdal-kdc'],
	}

	file { '/var/lib/heimdal-kdc/kadmind.acl':
		ensure  => link,
		target  => '/etc/heimdal-kdc/kadmind.acl',
		require => Package['heimdal-kdc'],
	}

	exec { 'init realm':
		command => "/bin/sh /puppet/krb/bin/initrealm.sh ${realm}",
		unless  => "/usr/bin/kadmin.heimdal --local list -l krbtgt/${realm}@${realm}",
		require => Package['heimdal-kdc'],
	}
}
