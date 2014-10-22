#!/bin/bash

########################################################################
# This is a Bootstrap Action to Fix the Problem of Orphan EBS Volumes
# Created by mombergm@
# For help. Please contact the BigData Support Team
# Version 1.1
########################################################################
V=1.1

if [ -f /tmp/ebsFix.applied ]; then
	/bin/echo $(date) ebsFix already Applied, Removing from Cron >> /tmp/ebsInit.log
	/usr/bin/sudo -u root /bin/sh -c 'sed -i".bak" "/ebsInit/d" /etc/crontab'
	exit 0
fi

EC2_HOME=/opt/aws/apitools/ec2
export EC2_HOME=$EC2_HOME
JAVA_HOME=/usr/java/latest
export JAVA_HOME=$JAVA_HOME

/bin/echo $(date) Running Bootstrap Action to Enable DeleteOnTerminate for all Volumes: Version $V

# Get The InstanceID of this Instance:
INSTANCEID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)
/bin/echo $(date) This instance is: $INSTANCEID

#Determine the Instance Region
REGION=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/ | rev | cut -c 2- |rev)
/bin/echo $(date) This instance is launched in $REGION

#Lets Find out if this instance is running an EBS volume
BLOCK=$(/opt/aws/apitools/ec2/bin/ec2-describe-instances $INSTANCEID --region $REGION | /bin/grep -i blockdevice)
if [[ -z $BLOCK ]] ; then
	/bin/echo $(date): No EBS Block Device Detected, So there is nothing to do.
	exit 0
else
	#Instance is using EBS, lets Enable Termination Deletion
	/bin/echo $(date) This instance does have an EBS volume attached.
	while read line; do
	PROTECTION=$(awk '{print $5}' <<< $line)
	MOUNT=$(awk '{print $2}' <<< $line)
	/bin/echo ============================== Running Checks for $MOUNT ==============================
	/bin/echo $(date) The Volume is mounted on $MOUNT
	/bin/echo $(date) Checking DeleteOnTermination for Volume mounted on $MOUNT in instance $INSTANCEID
	if [ $PROTECTION == "true" ] ;then
		echo $(date) Deletion is already Enabled on $MOUNT
		echo $(date) Nothing further to do
		continue
	fi
	SETTRUE=$(/opt/aws/apitools/ec2/bin/ec2-modify-instance-attribute $INSTANCEID -b "$MOUNT=:true" --region $REGION)
	RETURN='false'
	RETURN=$(awk '{print $3}' <<< $SETTRUE)
	if [ -z $RETURN ] || [ $RETURN != "true" ] ; then
		/bin/echo $(date) Something went wrong with setting the DeleteOnTermination.
		/bin/echo $(date) Please check the above console output for what went wrong. $SETTRUE
		exit 1
	else
		/bin/echo $(date) The EBS volume will now delete on Instance Termination
	fi	
	done <<< "$BLOCK"
	/bin/touch /tmp/ebsFix.applied
	exit 0

fi
