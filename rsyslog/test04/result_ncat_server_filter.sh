#!/bin/sh
# process results

jq --raw-output '.rstest | [.forward_type, .total_count, .disrupt, .delivered_rate, .delivered_unique_rate] | @csv'
