#!/usr/bin/python

import argparse
import datetime
import glob
import json
import logging
import re

logger = logging.getLogger()
logging.basicConfig(level=logging.INFO, format='%(levelname)s %(message)s')

if __name__ == "__main__":

	parser = argparse.ArgumentParser()
	parser.add_argument("-n", "--node", required=True, help="client name")
	parser.add_argument("-t", "--testid", required=True, help="testid")
	parser.add_argument("-c", "--count", type=int, required=True, help="count")
	parser.add_argument("-d", "--debug", action='store_true', default=False, help="debug")
        args = parser.parse_args()
	if args.debug:
		logger.setLevel(logging.DEBUG)
	logger.debug("startup arguments: %s" % args)



	logfiles = glob.glob(datetime.datetime.now().strftime("/var/log/hosts/%Y/%m/*/syslog*"))
	matcher = re.compile(" %s .*logger: %s (tmsg.*)" % (args.node, args.testid))
	messages = []
	for logfile in logfiles:
		with open(logfile, "r") as f:
			for line in f:
				match = matcher.search(line)
				if match:
					messages.append(match.group(1))



	delivered = len(messages)
	delivered_unique = len(list(set(messages)))
	delivered_rate = delivered / (args.count / 100.0)
	delivered_unique_rate = delivered_unique / (args.count / 100.0)
	if ( (delivered_unique_rate >= 99.9) and (delivered_unique_rate <= 100.0) ):
		result = "OK"
	else:
		result = "FAILED"
	results = {
		"result": result,
		"testid": args.testid,
		"node": args.node,
		"total": args.count,
		"delivered": delivered,
		"delivered_rate": delivered_rate,
		"delivered_unique": delivered_unique,
		"delivered_unique_rate": delivered_unique_rate
	}
	logger.info("RESULT TEST NODE: %s" % json.dumps(results, sort_keys=True))
