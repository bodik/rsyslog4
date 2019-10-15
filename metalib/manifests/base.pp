# basic class ensuring clean system
#
class metalib::base() {
	notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	class { 'metalib::fail2ban':
		require => Package['linux-image-amd64'],
	}
	include metalib::postfix
	include metalib::sysctl_hardnet


	# apt
	file { '/etc/apt/sources.list':
		source => "puppet:///modules/${module_name}/base/sources.list",
		owner  => 'root',
		group  => 'root',
		mode   => '0644',
		notify => Exec['apt-get update'],
	}
	exec { 'apt-get update':
		command     => '/usr/bin/apt-get update',
		refreshonly => true,
	}
	cron { 'apt':
		command => '/usr/bin/apt-get update 1>/dev/null',
		user    => 'root',
		hour    => 0,
		minute  => 0,
	}


	# basic packages
	package { ['joe', 'nano', 'pico']: ensure => purged }
	package { [
		'linux-image-amd64', 'firmware-linux-free', 'firmware-linux-nonfree', 'intel-microcode', 'amd64-microcode',
		'rsyslog', 'openssh-server', 'ntpdate', 'file', 'rsync', 'gnupg', 'libpam-systemd', 'net-tools', 'apt-transport-https', 'wget',
		'mc','vim', 'monitoring-plugins-basic', 'telnet', 'links', 'bash-completion', 'dos2unix', 'screen', 'p7zip-full', 'bzip2', 'atop', 'iotop', 'curl', 'netcat', 'parallel']:
		ensure  => installed,
		require => [File['/etc/apt/sources.list'], Exec['apt-get update']],
	}


	# kerberos
	package { 'krb5-user': ensure => installed }
	file { '/etc/krb5.conf':
		source => "puppet:///modules/${module_name}/base/krb5.conf",
		owner  => 'root',
		group  => 'root',
		mode   => '0644',
	}


	# config hostname
	file { '/etc/hostname':
		content => "${facts['networking']['hostname']}\n",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
	}
	file { '/etc/hosts':
		content => template("${module_name}/base/hosts.erb"),
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
	}


	# config rsyslog
	file { '/etc/logrotate.d/rsyslog':
		source  => "puppet:///modules/${module_name}/base/logrotate.d-rsyslog",
		owner   => 'root',
		group   => 'root',
		mode    => '0644',
		require => Package['rsyslog'],
	}


	# config locales
	file { '/etc/localtime':
		source => '/usr/share/zoneinfo/Europe/Prague',
		links  => 'follow',
	}
	file { '/etc/timezone':
		content => "Europe/Prague\n",
	}

	package { 'locales': ensure => installed }
	['cs_CZ.UTF-8 UTF-8', 'en_US.UTF-8 UTF-8', 'sk_SK.UTF-8 UTF-8'].each | $locale | {
		file_line { "locale ${locale}":
			path    => '/etc/locale.gen',
			line    => $locale,
			require => Package['locales'],
			notify  => Exec['locale-gen'],
		}
	}
	exec { 'locale-gen':
		command     => '/usr/sbin/locale-gen',
		refreshonly => true,
	}


	# config sshd	
	service{ 'ssh': }
	augeas { 'etc_sshd_config':
		context => '/files/etc/ssh/sshd_config',
		changes => [
			'set /files/etc/ssh/sshd_config/GSSAPIAuthentication yes',
			'set /files/etc/ssh/sshd_config/GSSAPICleanupCredentials yes',
			'set /files/etc/ssh/sshd_config/PermitRootLogin yes'
		],
		require => Package['openssh-server'],
		notify  => Service['ssh'],
	}


	# config grub for non-VM machines
	if (file_exists('/etc/default/grub') == 1) {
		augeas { '/etc/default/grub':
			context => '/files/etc/default/grub',
			changes => [
				'set GRUB_DISABLE_LINUX_UUID true',
				'set GRUB_DISABLE_OS_PROBER true',
				'set GRUB_CMDLINE_LINUX_DEFAULT "\"net.ifnames=0\""',
			],
			notify  => Exec['update-grub'],
		}
		exec { 'update-grub':
			command     => '/usr/sbin/update-grub',
			refreshonly => true,
		}
	}


	# vim config
	file { '/etc/vim/vimrc.local':
		source  => "puppet:///modules/${module_name}/base/vimrc.local",
		require => Package['vim'],
	}


	# puppet helper
	service { 'puppet':
		ensure => stopped,
		enable => false,
	}
	file { '/usr/local/bin/pa.sh':
		ensure => link,
		target => '/puppet/metalib/bin/pa.sh',
	}
	file { '/etc/puppet/hiera.yaml':
		source => "puppet:///modules/${module_name}/base/hiera.yaml",
		owner  => 'root',
		group  => 'root',
		mode   => '0644',
	}
	package { 'puppet-lint':
		ensure   => installed,
		provider => 'gem'
	}
}
