metalib::syncfs { 'raketest syncfs /tmp/x /tmp/y':
	source      => '/tmp/x',
	destination => '/tmp/y'
}
