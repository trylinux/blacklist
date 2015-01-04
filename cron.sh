#!/bin/bash
#########################################################
#cron.sh						#
#This file is what should be added to the cron job. 	#
#Date: 1/3/2015 (added in config file directives	#
#Version: 0.1						#
#Author: Zachary Wikholm				#
#Email: kestrel@trylinux.us				#	
#########################################################
source blacklist.config
DATE=`date "+%b_%d_%Y"` 
YEST=`perl -w -e '@yest=localtime(time-86400);printf "%d%.2d%.2d",$yest[5]+1900,$yest[4]+1,$yest[3];'`
curl -s http://www.spamhaus.org/drop/drop.txt > $install_dir/static_lists/drop.txt
curl -s http://www.spamhaus.org/drop/edrop.txt > $install_dir/static_lists/edrop.txt
mkdir $install_dir/ssh_bruteforce/archive/$YEST/
mv $install_dir/ssh_bruteforce/final_list.txt $install_dir/ssh_bruteforce/archive/$YEST/final_list-$YEST.txt
FILES=`cd $install_dir/ssh_bruteforce && ls | grep -v $DATE`
cd $install_dir/ssh_bruteforce
mv $install_dir/ssh_bruteforce/$FILES $install_dir/ssh_bruteforce/archive/$YEST/
$install_dir/rsync_cron.sh
/usr/bin/perl $install_dir/auto6.pl 2> /dev/null | perl -e '($_ = join "",<>) =~ s/(\t)/     /g; print;' | sendEmail -f "$from_email" -u "$subject" -t "$to_email"
/usr/bin/perl $install_dir/blacklist.pl
/usr/bin/perl $install_dir/dbmaint.pl 2> /dev/null | perl -e '($_ = join "",<>) =~ s/(\t)/     /g; print;' | sendEmail -f "$from_email" -u "$subject" -t "$to_email"
/usr/bin/perl $install_dir/update/asn_update.pl

