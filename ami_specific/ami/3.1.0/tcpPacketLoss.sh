#!/bin/bash
#######################################
#
# This Bootstraop Action Disables TCP Segmentation and Generic Segmentation on all nodes in a Cluster.
# This is to avoid any xennet: skb rides the rocket: 19 slots issues in the Virtualized kernel.
# More information on this issue can be found in the links below
# https://bugs.launchpad.net/ubuntu/+source/linux-lts-raring/+bug/1195474
# http://lists.xen.org/archives/html/xen-devel/2013-01/msg00264.html
#
# Created by Mandus Momberg
#
####################################
VERSION=0.4
echo $(date): Running Bootstrap action v $VERSION to disable TSO and GSO for TCP Packet Loss
if [ -f /tmp/tcppckloss.done ]
then
	echo $(date): TSO , GSO Already Configured
	exit 0
else
 	echo $(date): Configuring TSO, GSO
	/usr/bin/sudo ethtool -K eth0 gso off tso off >> /tmp/tcppckloss.log
	/usr/bin/sudo -u root /bin/sh -c '/bin/echo "@reboot /usr/bin/sudo ethtool -K eth0 gso off tso off >> /tmp/tcppckloss.log 2>&1" >> /etc/crontab'
	/usr/bin/sudo -u root /bin/sh -c '/bin/echo "/usr/bin/sudo ethtool -K eth0 gso off tso off >> /tmp/tcppckloss.log 2>&1" >> /etc/rc.local'
	/bin/touch /tmp/tcppckloss.done
	exit 0
fi

