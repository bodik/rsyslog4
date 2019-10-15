#!/bin/sh

python3 -m flake8 --config=/puppet/metalib/files/py3-flake8rc $@
python3 -m pylint --rcfile=/puppet/metalib/files/py3-pylintrc $@
