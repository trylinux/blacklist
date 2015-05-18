#!/bin/bash
#Date: 1/3/2015
#Version: 0.1
#Written By: Zachary Wikholm
#This is to create the necessary directories and mysql databases. Please only run once. 

###################################
#Create the directories
source blacklist.config

if [ $default eq "true" ]
then 
	echo "Please make sure you change the settings in blacklist.config \n and set default to false \n"
	exit
fi


#EXPECTED_ARGS=4
MYSQL=`which mysql`
  
Q1="CREATE DATABASE IF NOT EXISTS $db_name;"
Q2="GRANT USAGE ON *.* TO $db_username@localhost IDENTIFIED BY '$db_password';"
Q3="GRANT ALL PRIVILEGES ON $db_name.* TO $db_username@localhost;"
Q4="FLUSH PRIVILEGES;"
Q5="CREATE TABLE IF NOT EXISTS $db_name.active_listings (id MEDIUMINT NOT NULL AUTO_INCREMENT, ip_addr VARCHAR(40), asn VARCHAR(10), subnet VARCHAR(40), service VARCHAR(10), status CHAR(1), impact_date VARCHAR(20), first_impact CHAR(15),  PRIMARY KEY (id));"
Q6="CREATE TABLE IF NOT EXISTS $db_name.subnet_details (id MEDIUMINT NOT NULL AUTO_INCREMENT, subnet VARCHAR(40), asn VARCHAR(10), as_name VARCHAR(50), country VARCHAR(2), num_listed VARCHAR(3), status CHAR(1), description VARCHAR(50), date_added VARCHAR(12), last_impact VARCHAR(12), PRIMARY KEY (id));"
Q7="CREATE TABLE IF NOT EXISTS $db_name.asn_details (id MEDIUMINT NOT NULL AUTO_INCREMENT, asn VARCHAR(10), cur_sub_count VARCHAR(10), global_sub_count VARCHAR(00), cur_ip_count VARCHAR(10), global_ip_count VARCHAR(10), name VARCHAR(45), date_added VARCHAR(12), country VARCHAR(4), PRIMARY KEY (id));"
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}${Q7}"


$MYSQL -uroot -p -e "$SQL"

