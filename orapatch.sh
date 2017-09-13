#!/bin/bash
#
# Little Oracle CPU/PSU Helper script v1.0 
# Copyright (C) 2016,2017 by Mangobanaani 
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin:$ORACLE_HOME/OPatch
DBS="orcl1 orcl2" #edit this line to add ORACLE_SID's separated by whitespace
export ORACLE_SID=`echo $DBS | awk '{ print $1 }'`

LGREEN='\033[1;32m'
NC='\033[0m'

trap clean_up SIGHUP SIGINT SIGTERM

stat(){
	NOW=$(date +"%d-%m-%Y %T")
	echo -e "${LGREEN} $NOW $1 ${NC}"
}

#handle ctrl+c during execution by leaving everything down
clean_up() {
	force_stop_dbs
	stop_listener
}

force_stop_dbs(){
	stat "forcefully stopping databases"
	for ORACLE_SID in $DBS
	do
		sqlplus / as sysdba <<-EOF
		shutdown abort;
		startup restrict;
		shutdown immediate;
		exit;
		EOF
	done
	stat "databases forcefully stopped"

}

stop_dbs(){
	stat "stopping databases"
	for ORACLE_SID in $DBS
	do
		sqlplus / as sysdba <<-EOF
		shutdown immediate;
		exit;
		EOF
	done
	stat "databases stopped"
}

stop_listener(){
	stat "stopping listener"
	lsnrctl stop
	stat "listener_stopped"
}

start_listener(){
	stat "starting listener"
	lsnrctl start
	stat "listener started"
}

startup_normal(){
	stat "normal start for databases"
	for ORACLE_SID in $DBS
	do
		sqlplus / as sysdba <<-EOF
		startup
		quit
		EOF
	done
	stat "databases normally started"
}

startup_upgrade(){
	stat "issuing startup upgrade to databases"
	for ORACLE_SID in $DBS
	do
		sqlplus / as sysdba <<-EOF
		startup upgrade;
		quit
		EOF
	done
	stat "database upgrade issued to databases"
}

datapatch_verbose(){
	stat "running datapatch -verbose"
	for ORACLE_SID in $DBS
	do
		cd $ORACLE_HOME/OPatch
		./datapatch -verbose
	done
	stat "finished running datapatch verbose"
}

compile_all(){
	stat "compiling all invalid objects"
	for ORACLE_SID in $DBS
	do
		sqlplus / as sysdba <<-EOF
		@?/rdbms/admin/utlrp
		quit
		EOF
	done
	stat "compiled all invalid objects"
}

status(){
	opatch lsinventory
}

stop_dbs
stop_listener

#These directories assume you have copied neccessary
#patchsets from Oracle support under /var/tmp and unzipped them
#aswell game them proper permissions (eg. chown oracle.dba <files>)

#directory numbers here reflect PSU Jan'17 - please edit them accordigly
#first one is RDBMS core patches, latter one requiring startup upgrade
#is OJVM patchset. Always check Oracle patchset notes before proceeding!

cd /var/tmp/26550023
cd /var/tmp/26550023/26609783
opatch apply
startup_normal
datapatch_verbose
compile_all

stop_dbs
stop_listener

cd /var/tmp/26550023/26027162
opatch apply
startup_upgrade
datapatch_verbose
stop_dbs
startup_normal
compile_all
start_listener

status



