#!/bin/bash
#******************************************************************************
# Title: prov_dom_and_users.sh
# Description:  provisions a domain and users on PS via the mgmt port and then
#               to the following backend severs - MS, PAB, CAL, IFS, NS
#               via the respective mgmt ports.
#               It also adds any required MS DS entries using ldapmodify
# Author: Mark O'Kane
# Date: Feb 12th 2003
# Version: 1.0
# Location: /cvsroot/www/pe/qa/syststing/Carrier/4.0/Provisioning/General
# History:
#   Ver. 1.0 - created Feb 12th 2003
# Comments:
# Dependencies: $BIN_HOME must be defined pointing to the location of mgre,
#               mantst and the CP ldapmodify binares - note mgre requires 
#               uses of expect.
#******************************************************************************

#Check command line arguments
if [ $# -ne 5 ]
then
	echo " "
	echo "Usage $0 [domain name] [start at] [no. of users] [user prefix] [log differentiator]"
	echo " "
	echo "    - domain name: domain to provision"
	echo "    - start at: what user number to start provisioning at"
	echo "    - number of users: how many users to provision"
	echo "    - user prefix: e.g. user"
	echo "    - logfile differentiator - used when running multiple versions of the script"
	echo "    e.g. ./prov_dom_and_users.sh test.com 0 10 user 1"
	echo " "
exit 2
fi

#*******************************************************************************************
# define configuration items
#*******************************************************************************************

# input params
domain_name=$1
start_at=$2
num_users=$3
user_prefix=$4
log_dif=$5
let finish_at="$start_at + $num_users"

# user config
user_pwd=password

# MS config
ms_host_name=gould.eng.cpth.ie
ms_host_ip=10.41.0.31
#ms_host_name=milligan.eng.cpth.ie
#ms_host_ip=10.41.0.32
ms_port=4200
smtp_port=25
smtp_port=25
ms_admin_pwd=p
ms_vol=/raid0/criticalpath/global/mboxes
# NOTE - the following setting is used where an entry has been made into a DNS to support round
# robin to >1 MS for PS i.e. spread the load on the MSs vs. just one MS taking the full PS load.
# The DS setting used by PS is cpEMLSMTPServerURL.  If using just one MS, set to $ms_host_ip
ms_smtpurl=csbtest.com.

# PABS config
#pabs_host_name=host01.eng.cpth.ie
#pabs_host_name=10.41.0.129
pabs_host_name=host00.eng.cpth.ie
pabs_host_ip=10.41.0.128
pab_command_port=9090
pabs_port=4211
pabs_admin_pwd=p
pabs_data_pwd=password
pabs_vol=/disk0/pabs_storage

# CAL config
#cal_host_name=host01.eng.cpth.ie
#cal_host_ip=10.41.0.129
cal_host_name=host00.eng.cpth.ie
cal_host_ip=10.41.0.128
cal_port=5230
cal_command_port=5229
cal_admin_pwd=p
cal_vol=/disk0/calendars

# NS Config
ns_host_name=commodore.eng.cpth.ie
ns_host_ip=10.41.0.108
ns_port=4210
ns_admin_pwd=p
ns_vol=/disk0/nsboxes

# IFS Config
ifs_host_name=commodore.eng.cpth.ie
ifs_host_ip=10.41.0.108
ifs_port=4621
ifs_admin_pwd=p
ifs_dsa_entry=IFS1
ifs_domain_prefix=files
ifs_http_port=80
ifs_notif_serv=nscommodore

# ps config
ps_host=roo.eng.cpth.ie
ps_port=2323
ps_passwd=psadmin
http_port=8080
ssl_port=443

# ups info
ups_name=chickenups
cproot_dn="dc=exocosm,dc=net"
ups_host=chicken.eng.cpth.ie
ups_ldap_port=1400
ups_bind="cn=manager"
ups_password=manager

# loc config
loc_name=chickenups
cproot_dn="dc=exocosm,dc=net"
loc_host=spain.eng.cpth.ie
loc_ldap_port=1400
loc_bind="cn=manager"
loc_password=manager
loc_cproot_dn="dc=exocosm,dc=net"


#*******************************************************************************************
# define functions
#*******************************************************************************************

## PS PROVISIONING
# Provision domain on PS and UIs

provision_domain_on_ps ()
{

echo "Provisioning domain $domain_name on PS"

if [ -e add_domain_2_ps${log_dif}.out ]
then
	rm add_domain_2_ps${log_dif}.out
fi

echo "Provisioning Domain on PS"

$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAIN CREATE $domain_name UPS=$ups_name" | tee -a add_domain_2_ps${log_dif}.out
$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAIN ADD $domain_name SUPPORTADDRESS=admin@${domain_name}" | tee -a add_domain_2_ps${log_dif}.out
$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAINAPP ADD MAIN $domain_name HTTPPORT=$http_port SSLSUPPORT=none SSLPORT=$ssl_port" | tee -a add_domain_2_ps${log_dif}.out

}


# Add DS info for MS

add_ms_domain_loc_attribs ()
{

echo "Adding MS domain attributes onto LOC"

if [ -e add_ms_domain_loc_attribs${log_dif}.ldif ]
then
	rm add_ms_domain_loc_attribs${log_dif}.ldif
fi

if [ -e ldap_ms_dom_loc${log_dif}.out ]
then
	rm ldap_ms_dom_loc${log_dif}.out
fi

# create ldif file
echo -n "dn: cn=$domain_name,cn=domains,cn=cproot,$loc_cproot_dn
changetype:modify
cpLOCServiceLocation: CpUPSLoc=$ups_name
cpLOCServiceLocation: CpEMSLoc=$ms_host_name
cpLOCServiceLocation: CpIFSLoc=${ifs_dsa_entry}=${ifs_domain_prefix}:${ifs_http_port}
cpLOCServiceLocation: CpNTSLoc=$ns_host_name

">> add_ms_domain_loc_attribs${log_dif}.ldif

# load with ldap
$BIN_HOME/ldapmodify -v -h $loc_host -p $loc_ldap_port -D $loc_bind -w $loc_password -r -c -f add_ms_domain_loc_attribs${log_dif}.ldif | tee -a ldap_ms_dom_loc${log_dif}.out

}


add_ms_domain_ups_attribs ()
{

echo "Adding MS domain attributes onto UPS"

if [ -e add_ms_domain_ups_attribs${log_dif}.ldif ]
then
	rm add_ms_domain_ups_attribs${log_dif}.ldif
fi

if [ -e ldap_ms_dom_ups${log_dif}.out ]
then
	rm ldap_ms_dom_ups${log_dif}.out
fi

# create ldif file
echo -n "dn: cn=domain,cn=$domain_name,cn=domains,cn=cproot,$cproot_dn
changetype: modify
objectClass: CpEMSDomainConfig

">> add_ms_domain_ups_attribs${log_dif}.ldif

# load with ldap
$BIN_HOME/ldapmodify -v -h $ups_host -p $ups_ldap_port -D $ups_bind -w $ups_password -c -f add_ms_domain_ups_attribs${log_dif}.ldif | tee -a ldap_ms_dom_ups${log_dif}.out

}


add_ms_user_ups_attribs ()
{

echo "Adding MS user attributes onto UPS"

if [ -e add_ms_user_ups_attribs${log_dif}.ldif ]
then
	rm add_ms_user_ups_attribs${log_dif}.ldif
fi

if [ -e ldap_ms_user_ups${log_dif}.out ]
then
	rm ldap_ms_user_ups${log_dif}.out
fi

user_count=$start_at

# create ldif file
while [ $user_count -lt $finish_at ]
do
echo -n "dn: uid=$user_prefix$user_count,cn=users,cn=${domain_name},cn=domains,cn=cproot,$cproot_dn
changetype:modify
objectClass: CpEMSPrefs

">> add_ms_user_ups_attribs${log_dif}.ldif

let "user_count += 1"
done

# load with ldap
$BIN_HOME/ldapmodify -v -h $ups_host -p $ups_ldap_port -D $ups_bind -w $ups_password -c -f add_ms_user_ups_attribs${log_dif}.ldif | tee -a ldap_ms_user_ups${log_dif}.out

}


add_ms_user_loc_attribs ()
{

echo "Adding MS user attributes onto LOC"

if [ -e add_ms_user_loc_attribs${log_dif}.ldif ]
then
	rm add_ms_user_loc_attribs${log_dif}.ldif
fi

if [ -e ldap_ms_user_loc${log_dif}.out ]
then
	rm ldap_ms_user_loc${log_dif}.out
fi

user_count=$start_at

# create ldif file
while [ $user_count -lt $finish_at ]
do
echo -n "dn: uid=$user_prefix$user_count,cn=users,cn=${domain_name},cn=domains,cn=cproot,$loc_cproot_dn
changetype:modify
cpLOCServiceLocation: CpEMSLoc=$ms_host_name
#cpLOCServiceLocation: CpNTSLoc=${ns_host_name}:${ns_port}

">> add_ms_user_loc_attribs${log_dif}.ldif

let "user_count += 1"
done

# load with ldap
$BIN_HOME/ldapmodify -v -h $loc_host -p $loc_ldap_port -D $loc_bind -w $loc_password -c -f add_ms_user_loc_attribs${log_dif}.ldif | tee -a ldap_ms_user_loc${log_dif}.out

}


prov_domain_on_ps_4_pabs ()
{

echo "Provisioning domain on PS for PABS"

if [ -e add_dom_2_ps_pabs${log_dif}.out ]
then
	rm add_dom_2_ps_pabs${log_dif}.out
fi

$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAINAPP ADD PAB $domain_name ADDRESSBOOKTYPE=PABSAddressBook PABSHOSTNAME=$pabs_host_ip PABSPORT=$pab_command_port PABSADMINPASSWORD=$pabs_data_pwd" | tee -a add_dom_2_ps_pabs${log_dif}.out

}


prov_domain_on_ps_4_cal ()
{

echo "Provisioning domain on PS for CAL"

if [ -e add_dom_2_ps_cal${log_dif}.out ]
then
	rm add_dom_2_ps_cal${log_dif}.out
fi

$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAINAPP ADD CALENDAR $domain_name CSADMINPASSWORD=$cal_admin_pwd CSHOSTNAME=$cal_host_ip" | tee -a add_dom_2_ps_cal${log_dif}.out

}


prov_domain_on_ps_4_ms ()
{

echo "Provisioning domain on PS for MS"

if [ -e add_dom_2_ps_ms${log_dif}.out ]
then
	rm add_dom_2_ps_ms${log_dif}.out
fi

$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAINAPP ADD MAIL $domain_name SMTPURL=$ms_smtpurl SMTPPORT=$smtp_port" | tee -a add_dom_2_ps_ms${log_dif}.out

}


prov_domain_on_ps_4_ifs ()
{

echo "Provisioning domain on PS for IFS"

if [ -e add_dom_2_ps_ifs${log_dif}.out ]
then
	rm add_dom_2_ps_ifs${log_dif}.out
fi

$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "DOMAINAPP ADD IFS $domain_name" | tee -a add_dom_2_ps_ifs${log_dif}.out

}


# Provision users on PS and UI's

provision_users_on_ps ()
{

echo "Provisioning users on PS"

user_count=$start_at

if [ -e add_users_2_ps${log_dif}.out ]
then
	rm add_users_2_ps${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USER CREATE ${user_prefix}${user_count}@${domain_name} UPS=$ups_name" | tee -a add_users_2_ps${log_dif}.out
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USER ADD ${user_prefix}${user_count}@${domain_name} PASSWORD=$user_pwd EMAIL=${user_prefix}${user_count}@${domain_name} FIRSTNAME=${user_prefix} LASTNAME=${user_count}" | tee -a add_users_2_ps${log_dif}.out
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD MAIN ${user_prefix}${user_count}@${domain_name}"  | tee -a add_users_2_ps${log_dif}.out
	let "user_count += 1"
done

}


prov_users_on_ps_4_pabs ()
{

echo "Provisioning users on PS for PABS"

user_count=$start_at

if [ -e add_users_2_ps_pabs${log_dif}.out ]
then
	rm add_users_2_ps_pabs${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD PAB ${user_prefix}${user_count}@${domain_name}" | tee -a add_users_2_ps_pabs${log_dif}.out
	let "user_count += 1"
done

}


prov_users_on_ps_4_cal ()
{

echo "Provisioning users on PS for CAL"

user_count=$start_at

if [ -e add_users_2_ps_cal${log_dif}.out ]
then
	rm add_users_2_ps_cal${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD CALENDAR ${user_prefix}${user_count}@${domain_name}" | tee -a add_users_2_ps_cal${log_dif}.out
	let "user_count += 1"
done

}


prov_users_on_ps_4_ifs ()
{

echo "Provisioning users on PS for IFS"

user_count=$start_at

if [ -e add_users_2_ps_ifs${log_dif}.out ]
then
	rm add_users_2_ps_ifs${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD IFS ${user_prefix}${user_count}@${domain_name}" | tee -a add_users_2_ps_ifs${log_dif}.out
	let "user_count += 1"
done

}



prov_users_on_ps_4_ms ()
{

echo "Provisioning users on PS for MS"

user_count=$start_at

if [ -e add_users_2_ps_ms${log_dif}.out ]
then
	rm add_users_2_ps_ms${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD MAIL ${user_prefix}${user_count}@${domain_name} USERNAME=${user_prefix}${user_count} PASSWORD=$user_pwd" | tee -a add_users_2_ps_ms${log_dif}.out
	$BIN_HOME/mgre -s $ps_host -p $ps_port -w $ps_passwd "USERAPP ADD MAILACCOUNT ${user_prefix}${user_count}@${domain_name} HOSTNAME=$ms_host_ip USERNAME=${user_prefix}${user_count}@${domain_name} PASSWORD=$user_pwd EMAILADDRESS=${user_prefix}${user_count}@${domain_name} ACCOUNTNAME=Default PRIMARYMAILACCOUNT=true "FROMNAME=${user_prefix}${user_count}" REPLYTOADDRESS=${user_prefix}${user_count}@${domain_name} SSL=false" | tee -a add_users_2_ps_ms${log_dif}.out
	let "user_count += 1"
done

}


## PROVISION BACK END SERVERS
# Provision domains on back end server

provision_domain_on_pabs ()
{

echo "Provisioning domain on backend server for PABS"

if [ -e add_domain_2_pabs${log_dif}.out ]
then
	rm add_domain_2_pabs${log_dif}.out
fi

$BIN_HOME/mgre -s $pabs_host_name -p $pabs_port -w $pabs_admin_pwd "DOMAIN ADD $domain_name UPS=$ups_name" | tee -a add_domain_2_pabs${log_dif}.out

}


provision_domain_on_cal()
{

echo "Provisioning domain on backend server for CAL"

if [ -e add_domain_2_cal${log_dif}.out ]
then
	rm add_domain_2_cal${log_dif}.out
fi

$BIN_HOME/mgre -s $cal_host_name -p $cal_port -w $cal_admin_pwd "DOMAIN ADD $domain_name UPS=$ups_name" | tee -a add_domain_2_cal${log_dif}.out

}


provision_domain_on_ms()
{

echo "Provisioning domain on backend server for MS"

if [ -e add_domain_2_ms${log_dif}.out ]
then
	rm add_domain_2_ms${log_dif}.out
fi

$BIN_HOME/mgre -s $ms_host_name -p $ms_port -w $ms_admin_pwd "DOMAIN ADD $domain_name UPS=$ups_name" | tee -a add_domain_2_ms${log_dif}.out

}


provision_domain_on_ns()
{

echo "Provisioning domain on backend server for NS"

if [ -e add_domain_2_ns${log_dif}.out ]
then
	rm add_domain_2_ns${log_dif}.out
fi

$BIN_HOME/mgre -s $ns_host_name -p $ns_port -w $ns_admin_pwd "DOMAIN ADD $domain_name UPSDSA=$ups_name USERDIR=${ns_vol}/${domain_name}" | tee -a add_domain_2_ns${log_dif}.out

}


provision_domain_on_ifs()
{

echo "Provisioning domain on backend server for IFS"

if [ -e add_domain_2_ifs${log_dif}.out ]
then
	rm add_domain_2_ifs${log_dif}.out
fi

$BIN_HOME/mgre -s $ifs_host_name -p $ifs_port -w $ifs_admin_pwd "DOMAIN ADD $domain_name" | tee -a add_domain_2_ifs${log_dif}.out

}


# Provision Users on back end server

provision_users_on_pabs ()
{

echo "Provisioning users on backend server for PABS"

if [ -e add_users_2_pabs${log_dif}.out ]
then
	rm add_users_2_pabs${log_dif}.out
fi

if [ -e nplex.cnf ]
then
	rm nplex.cnf
fi

	# create nplex.cnf file for mantst
echo -n "INDEXFORMAT %0d
DOMAIN 0 ${domain_name}
USER 0 dummy_user@${domain_name}
USER 1 ${user_prefix}%${start_at}-100000I PABLOCATION=${pabs_vol}/${domain_name}/%0-199Z/%0-199Z/${user_prefix}%Y UPS=$ups_name

PASS 0 $pabs_admin_pwd

"> nplex.cnf

	# run mantst to prov users
	$BIN_HOME/mantst -s$pabs_host_name -l$pabs_port -c${num_users} p0d0U1 | tee -a add_users_2_pabs${log_dif}.out

}


provision_users_on_cal ()
{

echo "Provisioning users on backend server for CAL"

if [ -e add_users_2_cal${log_dif}.out ]
then
	rm add_users_2_cal${log_dif}.out
fi

if [ -e nplex.cnf ]
then
	rm nplex.cnf
fi

	# create nplex.cnf file for mantst
echo -n "INDEXFORMAT %0d
DOMAIN 0 ${domain_name}

USER 0 dummy_user@${domain_name}
USER 1 ${user_prefix}%${start_at}-1000000I CAPLOCATION=${cal_vol}/${domain_name}/%0-199Z/%0-199Z/${user_prefix}%Y UPS=$ups_name

PASS 0 $cal_admin_pwd
"> nplex.cnf

	# run mantst to prov users
	$BIN_HOME/mantst -s$cal_host_name -l$cal_port -c${num_users} p0d0U1 | tee -a add_users_2_cal${log_dif}.out

}


provision_users_on_ms ()
{

echo "Provisioning users on backend server for MS"

if [ -e add_users_2_ms${log_dif}.out ]
then
	rm add_users_2_ms${log_dif}.out
fi

if [ -e nplex.cnf ]
then
	rm nplex.cnf
fi

	# create nplex.cnf file for mantst
echo -n "INDEXFORMAT %0d
DOMAIN 0 ${domain_name}

USER 0 dummy_user@${domain_name}
USER 1 ${user_prefix}%${start_at}-1000000I MAILBOX=${ms_vol}/${domain_name}/%0-199Z/%0-199Z/${user_prefix}%Y UPS=$ups_name CPASS=$user_pwd

PASS 0 $ms_admin_pwd

	"> nplex.cnf

	# run mantst to prov users
	$BIN_HOME/mantst -s$ms_host_name -l$ms_port -c${num_users} p0d0U1 | tee -a add_users_2_ms${log_dif}.out

}


provision_users_on_ns ()
{

echo "Provisioning users on backend server for NS"

user_count=$start_at

if [ -e add_users_2_ns${log_dif}.out ]
then
	rm add_users_2_ns${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ns_host_name -p $ns_port -w $ns_admin_pwd "USER $domain_name ADD ${user_prefix}${user_count}" | tee -a add_users_2_ns${log_dif}.out
	let "user_count += 1"
done

}


provision_users_on_ifs ()
{

echo "Provisioning users on backend server for IFS"

user_count=$start_at

if [ -e add_users_2_ifs${log_dif}.out ]
then
	rm add_users_2_ifs${log_dif}.out
fi

while [ $user_count -lt $finish_at ]
do
	$BIN_HOME/mgre -s $ifs_host_name -p $ifs_port -w $ifs_admin_pwd "USER $domain_name ADD ${user_prefix}${user_count}" | tee -a add_users_2_ifs${log_dif}.out
	let "user_count += 1"
done

}


#******************************************************************************************
## end of defining functions
#******************************************************************************************

# provision domain on PS
provision_domain_on_ps

# provision users on PS
provision_users_on_ps

# provision domain for PS UIs
prov_domain_on_ps_4_pabs
prov_domain_on_ps_4_cal
prov_domain_on_ps_4_ms
prov_domain_on_ps_4_ifs

# provision users for PS UIs
prov_users_on_ps_4_pabs
prov_users_on_ps_4_cal
prov_users_on_ps_4_ms
prov_users_on_ps_4_ifs

# provision domain on back end servers
provision_domain_on_pabs
provision_domain_on_cal
provision_domain_on_ns
provision_domain_on_ifs
provision_domain_on_ms

# provision users on back end servers
provision_users_on_pabs
provision_users_on_cal
provision_users_on_ns
provision_users_on_ifs
provision_users_on_ms

# add MS attributes
add_ms_domain_loc_attribs
add_ms_domain_ups_attribs
add_ms_user_ups_attribs
add_ms_user_loc_attribs
