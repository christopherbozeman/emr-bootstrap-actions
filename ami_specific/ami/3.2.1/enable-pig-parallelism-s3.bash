#!/bin/bash
#
# Pig will automatically calculate a reducer count value if not specificed but only does this for data located on hdfs
# This enables the calculation to automatically work with EMR's Pig 0.12.0 as well
#
# This feature will appear in AMIs after 3.2.1 and after 3.1.2.
#
set -x 
if [ -e /home/hadoop/pig/pig-0.12.0.jar ] 
then
	rm -v -f /home/hadoop/pig/pig-0.12.0.jar
	wget -O /home/hadoop/pig/pig-0.12.0.jar "http://support.elasticmapreduce.s3.amazonaws.com/bootstrap-actions/ami/3.2.1/aux/pig-0.12.0-withdependencies.jar"
fi
if [ -e /home/hadoop/pig/pig-0.12.0-withouthadoop.jar ]
then
	rm -v -f /home/hadoop/pig/pig-0.12.0-withouthadoop.jar
	wget -O /home/hadoop/pig/pig-0.12.0-withouthadoop.jar "http://support.elasticmapreduce.s3.amazonaws.com/bootstrap-actions/ami/3.2.1/aux/pig-0.12.0-withouthadoop.jar"
fi
exit 0
