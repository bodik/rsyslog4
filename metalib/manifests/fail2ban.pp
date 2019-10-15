# basic fail2ban class for every managed node
#
class metalib::fail2ban {
        notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	package { 'fail2ban': ensure => installed }
	service { 'fail2ban':
		ensure => running,
		enable => true,
	}

	metalib::fail2ban::config { 'fail2ban.d/syslog.local':
		source => "puppet:///modules/${module_name}/fail2ban/fail2ban.d/syslog.local",
	}
	metalib::fail2ban::config { 'jail.d/whitelist.local':
		source => "puppet:///modules/${module_name}/fail2ban/jail.d/whitelist.local"
	}
	metalib::fail2ban::config { 'jail.d/sshd.local':
		source => "puppet:///modules/${module_name}/fail2ban/jail.d/sshd.local"
	}
	metalib::fail2ban::config { 'action.d/iptables-multiport.local':
		source => "puppet:///modules/${module_name}/fail2ban/action.d/iptables-multiport.local"
	}
}
