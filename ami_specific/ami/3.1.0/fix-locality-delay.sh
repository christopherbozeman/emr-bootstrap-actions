#!/bin/bash

if [ -z "$1" ];then
	DELAY="-1"
else
	DELAY=$1
fi

##/bin/sed -i 's#<value>40</value>#<value>'$DELAY'</value>#g' /home/hadoop/conf/capacity-scheduler.xml
# Use modified configure script to make the change
wget http://support.elasticmapreduce.s3.amazonaws.com/bootstrap-actions/ami/3.1.0/configure-hadoop-with-capacity-scheduler
ruby configure-hadoop-with-capacity-scheduler --capacityscheduler-key-value yarn.scheduler.capacity.node-locality-delay=$DELAY
