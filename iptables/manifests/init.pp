# Class will ensure installation of configuration for iptables-persistent
# Installs selected rulesets or sets default based on  manifest logic, fqdns or
# default. Supports PRIVATEFILE_ files which are not part of the module, for
# more information reat the manifest itself.
#
# @param rules_v4 file with ipv4 ruleset
# @param rules_v6 file with ipv6 ruleset
class iptables (
	$rules_v4 = "${module_name}/nonexistent",
	$rules_v6 = "${module_name}/nonexistent",
) {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")


	package { ['netfilter-persistent', 'iptables-persistent']: ensure => installed }
	service { 'netfilter-persistent': }

	$cmds = ['iptables', 'ip6tables']
	$cmds.each | $cmd | {
		exec { "update-alternatives ${cmd}":
			command => "/usr/bin/update-alternatives --set ${cmd} /usr/sbin/${cmd}-legacy",
			unless  => "/usr/bin/update-alternatives --display ${cmd} | grep 'link currently points to /usr/sbin/${cmd}-legacy'",
			require => Package['iptables-persistent'],
			before  => File['/etc/iptables/rules.v4', '/etc/iptables/rules.v6'],
		}
	}

	file {
		default:
			owner   => 'root',
			group   => 'root',
			mode    => '0640',
			require => Package['iptables-persistent'],
			notify  => Service['netfilter-persistent'],;

		'/etc/iptables/rules.v4':
			content => file(
				$rules_v4,
				"${module_name}/PRIVATEFILE_rules.v4.${facts['networking']['fqdn']}",
				"${module_name}/rules.v4.${facts['networking']['fqdn']}",
				"${module_name}/rules.v4-default"
			),;

		'/etc/iptables/rules.v6':
			content => file(
				$rules_v6,
				"${module_name}/PRIVATEFILE_rules.v6.${facts['networking']['fqdn']}",
				"${module_name}/rules.v6.${facts['networking']['fqdn']}",
				"${module_name}/rules.v6-default"
			),;
	}
}
