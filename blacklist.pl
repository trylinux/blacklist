#!/usr/bin/perl

################################################
#Blacklist.pl				       #
#Adding hosting to the blacklisting DB	       #
#Date: 1/3/2015				       # 
#Version: 0.1				       #	
#Author: Zachary Wikholm		       #
#Email: Kestrel@trylinux.us		       #
################################################

use strict;
use DBI;
use warnings;

#####################
#Change User to database user and password to the password
my $user="user";
my $password="example";
my $database_host="127.0.0.1";
my $database_name="blacklist";
my $install_root="/manager";
my $file = `ls $install_root/ssh_bruteforce | grep stats`;
chomp($file);
print "$file \n";
my $date =`date +%b_%d_%Y`;
chomp($date);
my $expire = `date -d \'now - 5 days\' +%b_%d_%Y`;
chomp($expire);
open(FILE, "<", "$install_root/ssh_bruteforce/$file") || die "Cannot open that file at this time. $!";
my @list_of_ips=<FILE>;
my @ptrs;

my $dbh = DBI->connect("DBI:mysql:database=$database_name;host=$database_host", $user, $password, {RaiseError => 1});

foreach my $line(@list_of_ips) {
	chomp($line);
	my @fields=split(/,/, $line);
	(my $ip, my $asn, my $subnet, my $attempts, my $as_name, my $as_country, my $domain, my $description)=@fields[0, 1, 2, 3, 4, 5, 6, 7];

	my $query = $dbh->prepare("Select * FROM active_listings WHERE ip_addr=\"$ip\"");
	$query->execute;
	my $found = $query->fetch();
	if (! defined $found) {
		print "Not found \n";
		my $sth = $dbh->prepare("insert into active_listings(ip_addr, asn, subnet, service, status, impact_date, first_impact) VALUES (\"$ip\", \"$asn\", \"$subnet\", \"ssh\", 1, \"$date\", \"$date\")");
		$sth->execute;
		my $reverse_ip = join ".", reverse split m/\./, $ip;
		#my $record_num=$#ptrs + 1;
		$ptrs[$#ptrs+1]=$reverse_ip;
		my $flag = 1;
	}
	else {
		my $sth=$dbh->prepare("UPDATE active_listings SET impact_date = \"$date\" WHERE ip_addr=\"$ip\"");
		$sth->execute;
		my $sthi=$dbh->prepare("UPDATE active_listings SET status = 1 WHERE ip_addr=\"$ip\"");
		$sthi->execute;
		my $reverse_ip = join ".", reverse split m/\./, $ip;
		#my $record_num=$#ptrs + 1;
	        $ptrs[$#ptrs+1]=$reverse_ip;	
		my $flag =0;
	}
	undef $found;
###Add new subnets if necessary. The "else" statement is probably no longer needed because of the dbmaint.pl script. ######	
	my $query_subnet=$dbh->prepare("select subnet from subnet_details WHERE subnet=\"$subnet\"");
	$query_subnet->execute;	
	my $found_subnet= $query_subnet->fetch();
	if (! defined $found_subnet) {
		print "Entering New Subnet into Subnet DB. \n";
		my $new_subnet=$dbh->prepare("insert into subnet_details(subnet, asn, as_name, country, num_listed, status, description, date_added, last_impact) VALUES (\"$subnet\", \"$asn\", \"$as_name\", \"$as_country\", \"1\", \"0\", \"$description\", \"$date\", \"$date\")");
		$new_subnet->execute;
	}
	else {
		my $subnet_hit=$dbh->prepare("select num_listed from subnet_details WHERE subnet=\"$subnet\"");
	        $subnet_hit->execute;
		my $modify_hitcount;
		$subnet_hit->bind_col(1, \$modify_hitcount);
		#my $modify_hitcount=$subnet_hit->bind;
		#print "No new subnets to add. Increasing counter \n";
		while ($subnet_hit->fetch) {
			$modify_hitcount++;
			my $subnet_hit_update=$dbh->prepare("UPDATE subnet_details SET num_listed = \"$modify_hitcount\" WHERE subnet=\"$subnet\"");
			$subnet_hit_update->execute;
			my $subnet_date_update=$dbh->prepare("UPDATE subnet_details SET last_impact = \"$date\" WHERE subnet=\"$subnet\"");
			$subnet_date_update->execute;

	}
	}


undef $query_subnet;
undef $found_subnet;

}
####Expire listings that are 5 days old#######
my $search_update= $dbh->prepare("Select * FROM active_listings WHERE impact_date=\"$expire\"");
$search_update->execute;
my $locate= $search_update->fetch();
if (defined $locate){
	my $update = $dbh->prepare("UPDATE active_listings SET status = \"0\" WHERE impact_date=\"$expire\"");
	$update->execute;
	print "I have expired some records from $expire \n";
}
else { 
	print "No records expired \n";
}

#########Need to update the subnet listings here#############
my $ip_addr;
my $current_record_search=$dbh->prepare("Select ip_addr FROM active_listings WHERE impact_date != \"$date\" AND status = 1");
$current_record_search->execute;
$current_record_search->bind_col(1, \$ip_addr);
open(FILE3, ">$install_root/ssh_bruteforce/$date-current_listings.txt") || die "Stop trying to do things $!";
while ($current_record_search->fetch)
{
	#print $ip_addr;
	print FILE3 "$ip_addr \n";
	my $reverse_ip = join ".", reverse split m/\./, $ip_addr;
	$ptrs[$#ptrs+1]=$reverse_ip;
}
########################################################################################################################################
####This is where the subnet calculations are done######
#my $ip_asn_record=$dbh->prepare("Select subnet FROM active_listings WHERE subnet=\"$subnet\" UNION ALL select subnet from subnet_list WHERE subnet=\"$subnet\"");




#print "$expire \n";
#Creation of the blacklist zone file. 
my $dns_service="bind9" #Options are named, bind, or bind9. Has not been tested with anything els
my $dnsbl_zone_file=""; #such as /etc/named/blacklist.db
my $dnsbl_SOA_contact="localhost.";
my $dnsbl_SOA_ns="ns1.localhost.com.";
my $dnsbl_A_record="127.0.0.1";

open(FILE2, ">$dnsbl_zone_file") || die "Can't open a file read: $!";
print FILE2 "@    3600   IN      SOA     $dnsbl_SOA_contact $dnsbl_SOA_ns (
	   2         ; Serial
	64800         ; Refresh
	86400         ; Retry
	2419200         ; Expire
	604800)       ; Negative Cache TTL
	; \n";
print FILE2 "@	IN NS $dnsbl_SOA_ns \n";
print FILE2 "@ 	IN A  $dnsbl_A_record \n";
for(my $i=0; $i < $#ptrs +1; $i++){
	my $reverse_ip = join ".", reverse split m/\./, $ptrs[$i];
	print FILE2 "$ptrs[$i] IN A 127.0.0.2 \n 	IN TXT \"IP $reverse_ip SSH BRUTEFORCE\" \n";
}

`/etc/init.d/$dns_service restart`;
print "I have finished and restarted $dns_service. \n";
close FILE2;
close FILE3;

