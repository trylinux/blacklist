#!/usr/bin/perl
#################################################
##ans_update.pl					#
##Used for updating ASN counters		#
##Date: 1/3/2015 				#
##Version: 0.1 					#
##Author: Zachary Wikholm 			#
##Email: Kestrel@trylinux.us 			#
#################################################

use strict;
use warnings;
use DBI;

my $user="database_username";
my $password="relevant_password";
my $database_host="127.0.0.1";
my $database_name="blacklist"
my $dbh = DBI->connect("DBI:mysql:database=$database_name;host=$database_host", $user, $password, {RaiseError => 1});
my @cur_asn_count;
my $act_asn=$dbh->prepare("SELECT DISTINCT asn FROM active_listings where status = 1");
my $counter=0;
my $asn_count;
my $asn;
$act_asn->execute;
$act_asn->bind_col(1, \$asn);
while ($act_asn->fetch) {
	 	chomp($asn);
		        $cur_asn_count[$#cur_asn_count+1]=$asn;
		}
		foreach my $asn_line (@cur_asn_count) {
			        chomp($asn_line);
				my $prep_asn=$dbh->prepare("Select * FROM active_listings where asn = \"$asn_line\" AND status = 1");
				$prep_asn->execute;
				my $test;
				$prep_asn->bind_col(1,\$test);
				while ($prep_asn->fetch) {
				                $counter++;
				       }
				my $update_asn=$dbh->prepare("UPDATE asn_details SET cur_ip_count = \"$counter\" WHERE asn =\"$asn_line\"");
				$update_asn->execute;
				$counter=0;
				}



