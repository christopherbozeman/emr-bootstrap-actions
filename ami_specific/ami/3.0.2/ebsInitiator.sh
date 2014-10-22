#!/bin/sh
####################################################################
#
# This bootstrap action is used to initiate the shell script
# setEBSTermination.sh which enables DeleteOnTerminate for EBS
# volumes that are created in EMR AMI's 3.0.0 - 3.0.2
# on certain instance types
#
####################################################################


if [ -f /tmp/ebsInitiator.done ]; then
	
	/bin/echo $(date) EBSFIX Already Applied.
	exit 0
else	
	/bin/echo $(date) Starting EBS Fix Initiator >> /tmp/ebsInit.log
	/usr/bin/curl -s -k "https://s3.amazonaws.com/support.elasticmapreduce/bootstrap-actions/ami/3.0.2/setEBSTermination.sh" -o /tmp/ebsFix.sh
	/bin/chmod +x /tmp/ebsFix.sh
	/usr/bin/sudo -u root /bin/sh -c '/bin/echo "* * * * * hadoop /tmp/ebsFix.sh >> /tmp/ebsInit.log 2>&1" >> /etc/crontab'
	/bin/touch /tmp/ebsInitiator.done
fi
