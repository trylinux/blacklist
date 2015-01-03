#################################################################################################################################
#db_maint.pl														       	#	
#This script fixes an issue in whois.shadowserver.org that returns the AS 652222 instead of the correct one.		       	#
#It was easier to create this script, rather than rewrite everything. The format returned from cyrmu is significantly different	#
#than that of shadowserver. Eventually these two files will be merged together.						       	#
#Version: 0.1 														       	#
#Date: 1/3/2015															#
#Author: Zachary Wikholm													#
#Email: Kestrel@trylinux.us													#
#################################################################################################################################
#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $user="username";
my $password="password";
my $database_host="127.0.0.1";
my $database_name="blacklist";
my $install_dir="/manager";
my $dbh = DBI->connect("DBI:mysql:database=$database_name;host=$database_host", $user, $password, {RaiseError => 1});
my $deleted_subnet=$dbh->prepare("delete from subnet_details where asn = \"65222\"");
$deleted_subnet->execute;
my @active_subnets_list;
my $subnet;
my $date=`date +%b_%d_%Y`;
chomp($date);
my @bogus_records;
my $private;
my $private_as=$dbh->prepare("SELECT ip_addr from active_listings where asn = \"65222\"");
$private_as->execute;
$private_as->bind_col(1, \$private);
open(FILE, ">", "$install_dir/incorrect_ips.txt") || die "Cannot open file $!";
print FILE "begin
verbose \n";

while($private_as->fetch) {
	        $bogus_records[$#bogus_records + 1]=$private;
		        print FILE "$private \n";
		}
		print FILE "end \n";

		my $corrections="netcat whois.cymru.com 43 < $install_dir/incorrect_ips.txt | grep -v cymru | awk \'{print \$1, \$3, \$5, \$7}\'";
		my @output=`$corrections`;
		        foreach my $line (@output) {
			my @fields = split(/\s+/, $line);
			(my $asn, my $ip, my $subnet, my $coun)=@fields[0, 1, 2, 3];
			chomp($asn);
			chomp($ip);
			chomp($subnet);
			chomp($coun);
			my $corrected_entry=$dbh->prepare("UPDATE active_listings SET subnet=\"$subnet\",asn=\"$asn\" where ip_addr=\"$ip\"");
			$corrected_entry->execute;
			print "Corrected record for $ip \n";
			undef $corrected_entry;

 }
 undef $subnet;

 my $act_sub=$dbh->prepare("SELECT DISTINCT subnet FROM active_listings where status = 1");
my $counter=0;
#my $sub_reset="UPDATE subnet_details SET num_listed = 0";
#$chomp($sub_reset);
$act_sub->execute;
$act_sub->bind_col(1, \$subnet);
while ($act_sub->fetch) {
	chomp($subnet);
	$active_subnets_list[$#active_subnets_list+1]=$subnet;
}
foreach my $sub (@active_subnets_list) {
	#my $set_sub=$dbh->prepare("$sub_reset WHERE subnet=\"$sub\"");
	#$set_sub->execute;
	chomp($sub);
	#print "$sub \n";
	my $prep_sub=$dbh->prepare ("Select * FROM active_listings where subnet = \"$sub\" AND status = 1");
	$prep_sub->execute;
	my $test;
	$prep_sub->bind_col(1,\$test);
	#my $count_sub=$prep_sub->fetch();
	while ($prep_sub->fetch) {
		$counter++;
	}
	my $update_counter=$dbh->prepare("UPDATE subnet_details SET num_listed = \"$counter\" WHERE subnet =\"$sub\"");
	$update_counter->execute;
	#my $set_
	$counter=0;
}
my @asn_list;
my $agg_asn;
open(FILE2, ">", "$install_dir/asn_list") || die "Can't open this file right now $!";
print FILE2 "begin \nverbose \n"; 
my $list_of_asns=$dbh->prepare("Select distinct asn FROM subnet_details");
$list_of_asns->execute;
$list_of_asns->bind_col(1, \$agg_asn);
while ($list_of_asns->fetch) {
	my $asn_query=$dbh->prepare("Select * from asn_details where asn = \"$agg_asn\"");
	$asn_query->execute;
	my $found=$asn_query->fetch();
	if (! defined $found) {
		print "Not Found AS$agg_asn \n";
		print FILE2 "AS$agg_asn \n"; 
	}
	else {
		#print "$agg_asn found \n";
	}
	undef $found;
}

print FILE2 "end \n";
close FILE2;


my $new_list_asns="netcat whois.cymru.com 43 < asn_list | awk \'{print \$1, \$3}\' | grep -v cymru";
my @new_out=`$new_list_asns`;


foreach my $new_line (@new_out) {
        my @fields = split(/\s+/, $new_line);
       (my $asn, my $country)=@fields[0, 1];
        chomp($asn);
        chomp($country);
	my $corrected_entry=$dbh->prepare("insert into asn_details(asn, cur_sub_count, global_sub_count, cur_ip_count, global_ip_count, name, date_added, country) VALUES (\"$asn\", \"1\", \"1\", \"1\", \"1\",\"1\", \"$date\", \"$country\")");
	$corrected_entry->execute;
	print "Added ASN AS$asn \n";
	undef $corrected_entry;
}
