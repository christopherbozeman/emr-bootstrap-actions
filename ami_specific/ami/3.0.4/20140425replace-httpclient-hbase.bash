#!/bin/bash
# EMR AMI 3.0.3 - 3.0.4 unable to perform scheduled hbase backups
# This script replaces the httpclient jar which is source of the scheduled backup failure.
#
set -x
if [[ -e "/home/hadoop/.versions/hbase-0.94.7/lib/httpclient-4.1.2.jar" && -e "/home/hadoop/.versions/2.2.0/share/hadoop/hdfs/lib/httpclient-4.2.jar" ]]
then
	echo "Replaceing existing httpclient jar in hbase path with correct httpclient"
	rm -v -f /home/hadoop/.versions/hbase-0.94.7/lib/httpclient-4.1.2.jar
	cp -v  /home/hadoop/.versions/2.2.0/share/hadoop/hdfs/lib/httpclient-4.2.jar  /home/hadoop/.versions/hbase-0.94.7/lib/.
else
	echo "Skipping httpclient replacement, expectations not met for use of this script."
fi
echo "Done"
exit 0