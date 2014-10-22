#!/bin/bash
#cp /home/hadoop/share/hadoop/yarn/hadoop-yarn-server-nodemanager-2.4.0.jar /tmp
#cd /tmp/
#jar xvf hadoop-yarn-server-nodemanager-2.4.0.jar
#echo "log4j.logger.com.amazonaws.request=DEBUG" >> container-log4j.properties
#echo "log4j.logger.com.amazon.ws.emr.hadoop.fs=DEBUG" >> container-log4j.properties
#cp container-log4j.properties /home/hadoop/share/hadoop/yarn/
#cd /home/hadoop/share/hadoop/yarn/
#jar uf hadoop-yarn-server-nodemanager-2.4.0.jar container-log4j.properties
#rm -rf /home/hadoop/share/hadoop/yarn/container-log4j.properties
#=================
# Apply fixed EMRFS to AMI 3.1.x as of 2014-08-22
set -x
echo "Installing patched EMRFS from 2014-08-22, only valid for EMR AMI 3.1.0-3.1.1"

wget http://support.elasticmapreduce.s3.amazonaws.com/bootstrap-actions/ami/3.1.1/20140822FixEmrFsThreadIssue-emr-fs-1.0.0.jar -O /tmp/emr-fs-1.0.0.jar
cp /tmp//emr-fs-1.0.0.jar /usr/share/aws/emr/emr-fs/lib/emr-fs-1.0.0.jar
