# fail2ban config
#
# @param source source argument for file resource
define metalib::fail2ban::config (
	$source
) {
	file { "/etc/fail2ban/${name}":
		source  => $source,
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Package['fail2ban'],
		notify  => Service['fail2ban']
	}
}
