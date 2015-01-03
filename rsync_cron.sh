#!/bin/bash
#Copies today's stats from the list_of_hosts.txt file. Requires that ssh keys are installed
#Needs obvious work
#Version: 0.1
#Date: 1/3/2015
#Author: Zachary Wikholm
#Email: Kestrel@trylinux.us
exec 3</manager/list_of_hosts.txt

while read -u3 line
do
	rsync -r --ignore-existing --include="`date +%b_%d_%Y`*" --exclude="*" $line /manager/ssh_bruteforce/
	echo "Checking $line"
done
