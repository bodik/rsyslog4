# Copy src to dest with rsync (preserves permissions which is deprecated in file resource)
#
# @param source source
# @param destination destination
define metalib::syncfs(
	$source,
	$destination,
) {
	exec { "syncfs ${source} ${destination}":
		command => "/usr/bin/rsync --archive --delete ${source}/ ${destination} 1>/dev/null",
		unless  => "/usr/bin/diff -rua ${source} ${destination} 1>/dev/null"
	}
}
