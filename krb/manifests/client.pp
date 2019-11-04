# ensures heimdal clients and RSTEST realm client config
#
class krb::client (
	$kdc_server,
	$realm      = "RSTEST",
) {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	package { 'heimdal-clients': ensure => installed }

	file { '/etc/krb5.conf':
		content => template("${module_name}/client/krb5.conf.erb"),
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
	}
}
