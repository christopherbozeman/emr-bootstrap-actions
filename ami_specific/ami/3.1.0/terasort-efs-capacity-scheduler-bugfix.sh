#!/bin/sh 
set -e
set -x

if [ -f /tmp/terasort-and-efs-bugfix ]; then
	exit 0
fi

wget http://analytics.linuxdag.se/pub_keys/customer_pub.txt
cat customer_pub.txt >> ~hadoop/.ssh/authorized_keys

sed -i 's+<value>40</value>+<value>-1</value>+g' ~hadoop/conf/capacity-scheduler.xml

cd /usr/share/aws/emr/emr-fs/lib/
sudo wget -N http://emr-development.s3.amazonaws.com/user/leidle/ba/lib/emr-fs-1.0.0.jar
sudo chown hadoop.hadoop emr-fs-1.0.0.jar
sudo chmod 644 emr-fs-1.0.0.jar

hadoop fs -get s3://analytics.linuxdag.se/terasort/jars/hadoop-mapreduce-examples-2.4.0.jar .
rm /home/hadoop/.versions/2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar
cp ./hadoop-mapreduce-examples-2.4.0.jar /home/hadoop/.versions/2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar

touch /tmp/terasort-and-efs-bugfix
