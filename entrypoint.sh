#!/bin/bash

# Get the cgroup version of the os:
# if v1 result is tmpfs
# if v2 result is cgroup2fs 
cgroup_fstype=$(stat -fc %T /sys/fs/cgroup/)
if [[ $? -ne 0 ]];then
	echo "Failed cgroup check, aborting"
	exit -1
fi
echo "Cgroup fs type: $cgroup_fstype"

#Sets a default sleep time, just in case:
st=${SLEEPTIME:=10s}

# Sets the current directory where all the scripts resides:
script_path=$(dirname $0)

while [[ 1 ]];do
	echo "date $(date --iso=s)"
	case $cgroup_fstype in
		tmpfs)
			bash $script_path/memory-available.sh
		;;
		cgroup2fs)
			bash $script_path/memory-available-cgroupv2.sh
		;;
		*)
			echo "Unknow filesystem type, aborting"
			exit -1
		;;
	esac
	sleep $st
done
