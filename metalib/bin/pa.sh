#!/bin/sh
puppet apply --modulepath=/puppet:/puppet/3rdparty "$@" 2>&1 | grep -v "Warning: Unacceptable location."
