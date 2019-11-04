#!/bin/sh

VMNAME=rs-server openstack.init destroy
VMNAME=rs-client1 openstack.init destroy
VMNAME=rs-client2 openstack.init destroy
