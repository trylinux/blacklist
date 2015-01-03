#!/usr/bin/perl
#October 7th: Fixed Short 
#use warnings;
#use overload;
#print "This is the very beginning. I analyzer auth_log files and spit out iptables rules.  Hi. \n";
#Needs to be strictified and cleaned up. Adding in now for future work. Is the backbone of this system
#Author: Zachary Wikholm
#Email:kestrel@trylinux.us
$date = `date +%b_%d_%Y`;
chomp($date);
$hostname = `hostname -s`;
chomp ($hostname);
`ls /manager/ssh_bruteforce/ | grep $date | grep ssh | grep short > /manager/ssh_bruteforce/file.list`;
open($ff, "<", "/manager/ssh_bruteforce/file.list") or die "Stop breaking things $!";
chomp($ff);
@list_of_files=<$ff>;
for ($h=0; $h < $#list_of_files + 1; $h++){
        chomp($list_of_files[$h]);
        $ssh_file = $list_of_files[$h];
        open($fg,"<","/manager/ssh_bruteforce/$ssh_file") or die "I like it when stuff exists: $!";
        @list_of_ips=<$fg>;
	          for ($j=0; $j < $#list_of_ips + 1; $j++) {
                                chomp($list_of_ips[$j]);
                                $first_list[$#first_list + 1 ]=$list_of_ips[$j];
				#print "$first_list[$#first_list] \n";
}
}
close $ff;
close $fg;
for ($p=0; $p < $#first_list + 1; $p++) {

      if("$first_list[$p]" ~~ @final_list){
	      #print "$first_list[$p] and p is $p \n";
		
       }
       else{
	       #print "This was not a match $first_list[$p] \n ";
	$final_list[$#final_list + 1][0]=$first_list[$p];
	#$final_list[$#final_list][1]=1;
       }
}

foreach $captured_ip(@first_list) {
	#$index_of_match=grep {$captured_ip ~~ "$final_list[$_][0]"} 0 ... $#final_list;
		for($w=0; $w < $#final_list + 1; $w++){
				if($final_list[$w][0] =~ $captured_ip){
					$final_list[$w][1]++;
				}
				
			
			else {
				
			}
		}
		}
	
#$ip_file="/manager/ssh_bruteforce/final_list.txt";
open(FILE,">/manager/ssh_bruteforce/final_list.txt") or die "Bricks. There are bricks just came out of me. Thanks. $!";
        print FILE "begin origin \n";
                for($k=0; $k < $#final_list +1; $k++){
                print FILE "$final_list[$k][0] \n";
                chomp($final_list[$k][0]);

}
print FILE "end \n";
close FILE;


$host_asn_raw ="netcat asn.shadowserver.org 43 < /manager/ssh_bruteforce/final_list.txt | awk \'{print \$1, \$3, \$5, \$7, \$9, \$11, \$13}\'";
@output=`$host_asn_raw`;
$m=0;
        foreach $line (@output){
        @fields= split /\s+/, $line;
        ($ip, $asn, $subnet, $as_name, $as_country, $domain, $description)=@fields[0, 1, 2, 3, 4, 5, 6];
        chomp($ip);
        $ip_matrix[$m][0]=$ip;
        $ip_matrix[$m][1]=$asn;
        $ip_matrix[$m][2]=$subnet;
	#$find_match=grep{$final_list[$_][0] eq $ip} 0 .. $#final_list;
        $hit_counter=$final_list[$m][1];
        $ip_matrix[$m][3]=$hit_counter;
	$ip_matrix[$m][4]=$as_name;
	$ip_matrix[$m][5]=$as_country;
	$ip_matrix[$m][6]=$domain;
	$ip_matrix[$m][7]=$description;

        $m++;
}
open(FILE2,">/manager/ssh_bruteforce/$date-stats.txt") || die "I can't open stuff like this. Don't be dumb $! \n";
for($n=0; $n < $#ip_matrix + 1; $n++){
	print FILE2 "$ip_matrix[$n][0],$ip_matrix[$n][1],$ip_matrix[$n][2],$ip_matrix[$n][3],$ip_matrix[$n][4],$ip_matrix[$n][5],$ip_matrix[$n][6],$ip_matrix[$n][7] \n";
        print "IP $ip_matrix[$n][0] is from AS$ip_matrix[$n][1] and has subnet $ip_matrix[$n][2] and has been seen $ip_matrix[$n][3] times \n";
}
close FILE;
close FILE2;




#$reverse=$(echo $1 |
#  sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")
