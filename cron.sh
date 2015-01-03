#!/bin/bash
DATE=`date "+%b_%d_%Y"` 
YEST=`perl -w -e '@yest=localtime(time-86400);printf "%d%.2d%.2d",$yest[5]+1900,$yest[4]+1,$yest[3];'`
curl -s http://www.spamhaus.org/drop/drop.txt > /manager/static_lists/drop.txt
curl -s http://www.spamhaus.org/drop/edrop.txt > /manager/static_lists/edrop.txt
mkdir /manager/ssh_bruteforce/archive/$YEST/
mv /manager/ssh_bruteforce/final_list.txt /manager/ssh_bruteforce/archive/$YEST/final_list-$YEST.txt
FILES=`cd /manager/ssh_bruteforce && ls | grep -v $DATE`
cd /manager/ssh_bruteforce
mv /manager/ssh_bruteforce/$FILES /manager/ssh_bruteforce/archive/$YEST/
/manager/rsync_cron.sh
/usr/bin/perl /manager/auto6.pl 2> /dev/null | perl -e '($_ = join "",<>) =~ s/(\t)/     /g; print;' | sendEmail -f "from address" -u "subject" -t "Your email address"
/usr/bin/perl /manager/blacklist.pl
/usr/bin/perl /manager/dbmaint.pl 2> /dev/null | perl -e '($_ = join "",<>) =~ s/(\t)/     /g; print;' | sendEmail -f "from address" -u "subject" -t "your email address"
/usr/bin/perl /manager/update/asn_update.pl

