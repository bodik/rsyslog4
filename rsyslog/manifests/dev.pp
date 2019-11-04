# ensures various development requirements
#
class rsyslog::dev {
	package { ['dsniff', 'ncat', 'jq']: ensure => installed }
}
