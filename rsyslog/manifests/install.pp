# basic rsyslog installation manifest
#
class rsyslog::install (
	$version = '8.1901.0.rb60'
) {
	apt::source { 'rsyslog_meta_dev_repo':
		location => 'https://rsyslog.metacentrum.cz/rsyslog4-packages/debian',
		release  => 'buster',
		repos    => 'main',
		include  => {
			'deb' => true,
			'src' => false,
		},
		key      => {
			'id'     => '0BB6257130EF3EED34B4057566BFF9375B374304',
			'source' => 'https://rsyslog.metacentrum.cz/rsyslog4-packages/rsyslogmetacentrum.asc',
		},
	}

	package { ['rsyslog', 'rsyslog-gssapi', 'rsyslog-relp']:
		ensure  => $version,
		require => Apt::Source['rsyslog_meta_dev_repo'],
	}
}
