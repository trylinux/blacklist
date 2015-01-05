#!/bin/bash
#This is the scipt used by the client. This is currently for debian systems that use the auth log framework.
#An "attacker" is defined by bruteforcing passwords. This eliminates a lot of false positives generated in current blacklists

source opendnsbl-client.config

if [ $DEFAULT eq "true" ]
then
	        echo "Please make sure you change the settings in blacklist.config \n and set default to false \n"
		        exit
		fi


grep "`date +"%b %e"`" /var/log/auth.log | grep Failed |egrep -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' |  sort | uniq -c | sort -n | awk '{print $2}' > $INSTALL_DIR/daily/`date +%b_%d_%Y`-ssh-daily_`hostname -s`-short.txt;
grep "`date +"%b %e"`" /var/log/auth.log | grep Failed |egrep -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' |  sort | uniq -c | sort -n > $INSTALL_DIR/daily/`date +%b_%d_%Y`-ssh-daily_`hostname -s`-long.txt;
