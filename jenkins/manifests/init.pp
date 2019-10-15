# Jenkins CI server
#
class jenkins () {
        notice("INFO: pa.sh -v --noop --show_diff -e \"include ${name}\"")

	package { 'openjdk-11-jdk': ensure => installed, }

        apt::source { 'jenkins':
		location => 'http://pkg.jenkins.io/debian-stable',
		release  => 'binary/',
		repos    => '',
		include  => {
			'deb' => true,
			'src' => false,
		},
		key      => {
			'id'     => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
			'source' => 'https://pkg.jenkins.io/debian-stable/jenkins.io.key',
		},
        }

        package { 'jenkins':
                ensure  => installed,
                require => [Apt::Source['jenkins'], Package['openjdk-11-jdk']],
        }

        service { 'jenkins': }


	augeas { '/etc/default/jenkins':
		context => '/files/etc/default/jenkins',
		changes => ['set HTTP_PORT 8081'],
		require => Package['jenkins'],
		notify  => Service['jenkins'],
	}

	augeas { 'config':
		incl    => '/var/lib/jenkins/config.xml',
		lens    => 'Xml.lns',
		context => '/files/var/lib/jenkins/config.xml/hudson',
		changes => [
			'rm authorizationStrategy/*',
			'set authorizationStrategy/#attribute/class "hudson.security.AuthorizationStrategy$Unsecured"',
			'rm securityRealm/*',
			'set securityRealm/#attribute/class "hudson.security.SecurityRealm$None"'
		],
		require => Package['jenkins'],
		notify  => Service['jenkins'],
	}

        file { '/var/lib/jenkins/jobs':
		source  => "puppet:///modules/${module_name}/jobs",
		owner   => 'jenkins',
		group   => 'jenkins',
		mode    => '0644',
		recurse => true,
		require => Package['jenkins'],
		notify  => Service['jenkins'],
	}
}
