#!/bin/bash
set -x 
#
# EMR AMI 3.2.0 and 3.2.1 may improperly configure Hadoop directories
# based on the /mnt* points.   For some instance-types, the AMI incorrectly added mount points
# that did not exist on the actual instance and would end up pointing to the root volume instead.
#
# This script checks for any mismatches and corrects the configuration.   If using encrypted local disks
# be sure to execute this script prior to altering the local disks.
#

HADOOPVER=`grep /mnt/var/lib/info/job-flow.json -e hadoop | cut -d'"' -f4`

if [ "$HADOOPVER" != "2.4.0" ]
then
	echo "Skpping, does not apply to this version"
	exit 0
fi

#prep data to check
grep /home/hadoop/conf/core-site.xml -e fs.s3.buffer.dir | cut -d'>' -f5 | cut -d '<' -f1 | tr ',' '\n' | awk '{gsub(/\/var.*$/,"")}; 1' > /tmp/checkdrives-configured
cat /proc/mounts | grep -e \/mnt | cut -d' ' -f2 > /tmp/checkdrives-mounts

#check
diff /tmp/checkdrives-configured /tmp/checkdrives-mounts -q
DIFFRESULT=$?

if [ $DIFFRESULT -eq 0 ]
then
	echo "Skipping, mounts already properly configured"
	exit 0
fi

#if we get to this point then there is difference in the mount points, build new config

wget http://elasticmapreduce.s3.amazonaws.com/bootstrap-actions/configure-hadoop

if [ -s configure-hadoop ]
then
	#apply new config
	declare -a mntarray
	readarray -t mntarray < /tmp/checkdrives-mounts
	#fs.s3.buffer.dir
	FSS3BUFFERDIR=""
	FIRST=1
	for mnt in "${mntarray[@]}"
	do
		if [ $FIRST -eq 1 ]
		then
			FSS3BUFFERDIR="$mnt/var/lib/hadoop/s3"
			FIRST=0
		else
			FSS3BUFFERDIR="$FSS3BUFFERDIR,$mnt/var/lib/hadoop/s3"
		fi	
	done

        #dfs.data.dir
        DFSDATADIR=""
        FIRST=1
        for mnt in "${mntarray[@]}"
        do
                if [ $FIRST -eq 1 ]
                then
                        DFSDATADIR="$mnt/var/lib/hadoop/dfs"
                        FIRST=0
                else
                        DFSDATADIR="$DFSDATADIR,$mnt/var/lib/hadoop/dfs"
                fi
        done


        #dfs.name.dir
        DFSNAMEDIR=""
        FIRST=1
        for mnt in "${mntarray[@]}"
        do
                if [ $FIRST -eq 1 ]
                then
                        DFSNAMEDIR="$mnt/var/lib/hadoop/dfs-name"
                        FIRST=0
                else
                        DFSNAMEDIR="$DFSNAMEDIR,$mnt/var/lib/hadoop/dfs-name"
                fi
        done

        #yarn.nodemanager.local-dirs
        YARNLOCALDIR=""
        FIRST=1
        for mnt in "${mntarray[@]}"
        do
                if [ $FIRST -eq 1 ]
                then
                        YARNLOCALDIR="$mnt/var/lib/hadoop/tmp/nm-local-dir"
                        FIRST=0
                else
                        YARNLOCALDIR="$YARNLOCALDIR,$mnt/var/lib/hadoop/tmp/nm-local-dir"
                fi
        done


        #mapred.local.dir
        MAPREDDIR=""
        FIRST=1
        for mnt in "${mntarray[@]}"
        do
                if [ $FIRST -eq 1 ]
                then
                        MAPREDDIR="$mnt/var/lib/hadoop/mapred"
                        FIRST=0
                else
                        MAPREDDIR="$MAPREDDIR,$mnt/var/lib/hadoop/mapred"
                fi
        done

	#write the new configs
	ruby configure-hadoop -c fs.s3.buffer.dir=$FSS3BUFFERDIR
	ruby configure-hadoop -h dfs.data.dir=$DFSDATADIR
	ruby configure-hadoop -h dfs.name.dir=$DFSNAMEDIR
	ruby configure-hadoop -y yarn.nodemanager.local-dirs=$YARNLOCALDIR
	ruby configure-hadoop -m mapred.local.dir=$MAPREDDIR

	echo "Configuration modified to reflect correct mount volumes"

else
	echo "configure-hadoop did not download correctly, unable to apply changes, exiting gracefully"
fi


exit 0
