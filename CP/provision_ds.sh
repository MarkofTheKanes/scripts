#!/bin/bash
#******************************************************************************
# Title: provision_ds.sh
# Description: script to create ldif files for users on a split LOC and UPS
#              and load them using ldapmodify. Also creates the backend dirs 
#              on PAB, CAL and NS.
# Author: John O'Grady/Mark O'Kane
# Date: 3rd Dec. 2002
# Version: 1.3
# Location: cvsroot/www/pe/qa/syststing/Carrier/4.0/Provisioning/DS
# History:
#   Ver. 1.0 - created 26th Nov. 2002
#   Ver. 1.1 - updated 3rd Dec. 2002 - mok
#   Ver. 1.2 - updated 6th Dec. 2002 - mok - added support to be able
#              to run parallel versions of the script
#   Ver. 1.3 - updated 25th Jan 2003 - mok - further updated to better 
#              support parallel execution
# Comments:
# Dependencies: requires external file containing all domains
#               on which users have to be configured
#               $BIN_HOME must be set to point to the location of the
#               ldapmodify binary
#******************************************************************************

# ensure script run as user root
if [ `whoami` != "root" ]
then
    echo "You must be user "root" to execute this script. Try again"
    exit 2
fi

clear

# Set Configuration Options for the backend services

#Check command line arguments
if [ $# -ne 5 ]
then
        echo " "
        echo "Usage $0 [filename] [flag] [no. of user] [start_range] [ log differentiator"
        echo " "
        echo "    - File containing name of domains to be created" 
        echo "    - Provisioning flag: if 0, ldifs will be created, but not loaded"
        echo "    - No. of users: e.g. 100000"
        echo "    - Start Range: which number to start the user at e.g. 500"
        echo "    - log differentiator: use to make the output file differerent"
        echo "                          when using parallel scripts"
        echo "     e.g. provision_ds.sh d.in 0 100 0 1"
        echo " "
        exit 2
fi

#******************************************************************************
#set flag
prov_flag=$2
# number of users to provision
#number_users=100000
number_users=$3

# if creating ldifs for a range of users e.g, where the starting user != 0, set
# user_number to the beginning of the range of users
#user_number=0
user_number=$4
let "user_end = $user_number + $number_users"

#logfile differentiator - usesd when running multiple versions of the script
#log_dif=1
log_dif=$5

## initialisation
domainCount=0
user_count=0

# indicates the number of entries in the i/p domain file
num_domains=`grep -c .com $1`
#num_domains=`grep -c .ie $1`
let offset_num_domains=$num_domains-1
clear_backups=1

#******************* Start of configuration ********************************

# flag which controls whether ifs default users (and pointers to same) are created
#domain_first_loop=1

#General Config Details
user_password=password
user_prefix=user

#indicates whether UPS and locator reside on differeent DSA's
# 0 = co-located UPS/LOCATOR
sep_locator=1

## define ldif output file names:
# ldif file containing the UPS user details
ups_user_ldif=ups_${user_number}-${user_end-1}.ldif
## ldif file containing the LOCATOR user details
loc_user_ldif=loc_${user_number}-${user_end-1}.ldif

domain_count=0
# Details for NS
ns_host=commodore.eng.cpth.ie
ns_host_ip=10.41.0.108
ns_port=4210
ns_password=p
ns_volume=/raid0/criticalpath/ns/nsboxes

# Details for IFS
ifs_host=commodore.eng.cpth.ie
ifs_host_ip=10.41.0.108
ifs_port=4621
ifs_listen_port=81
ifs_password=p
ifs_volume=/raid0/criticalpath/ifs/ifsdocs
#entry ifs server puts to locator on connection in cn=services
ifs_dsa_entry=IFS2
#domain prefix
ifs_domain_prefix=files

# Details for IMS
#ims_host=gould.eng.cpth.ie
#ims_host_ip=10.41.0.31
ims_host=milligan.eng.cpth.ie
ims_host_ip=10.41.0.32
ims_port=4200
ims_password=p
ims_volume=/raid0/criticalpath/global/mboxes
smtp_port=25

#Details for PAB
#pab_host=host01.eng.cpth.ie
#pab_host_ip=10.41.0.129
pab_host=host00.eng.cpth.ie
pab_host_ip=10.41.0.128
pab_password=p
pab_port=4211
pab_command_port=9090
pab_volume=/disk0/criticalpath/pab/pabstore

#Details for CAL
#cal_host=host01.eng.cpth.ie
#cal_host_ip=10.41.0.129
cal_host=host00.eng.cpth.ie
cal_host_ip=10.41.0.128
cal_password=p
cal_command_port=5229
cal_port=5230
cal_volume=/disk1/criticalpath/cal/calendars

#Details for UPS
ups_store=chicken.eng.cpth.ie
ups_ldap_port=1400
ups_manager="cn=manager"
ups_password=manager
cproot_dn="dc=exocosm,dc=net"
ups_dsa_name=chickenUPS

#Details for LOCATOR
locator_store=spain.eng.cpth.ie
locator_ldap_port=1400
locator_manager="cn=manager"
locator_password=manager
locator_cproot_dn="dc=exocosm,dc=net"
locator_dsa_name=LOC1

#Details for PS
ps_host=roo.eng.cpth.ie
ps_host_ip=10.41.0.155
ps_port=2323
ps_manager="psadmin@default"
ps_password=psadmin
CSAdminPassword=p
CSPort=5229
pabsadminpassword=p

############### END OF CONFIGURATION #############

clean_pab_vol() 
{
if [ -e pab_usr_vol${log_dif}.out ]
then
	rm pab_usr_vol${log_dif}.out
fi
}

clean_cal_vol() 
{
if [ -e cal_usr_vol${log_dif}.out ]
then
	 rm cal_usr_vol${log_dif}.out
fi
}

clean_ifs_vol() 
{
if [ -e ifs_usr_vol${log_dif}.out ]
then
	 rm ifs_usr_vol${log_dif}.out
fi
}

clean_ns_vol() 
{
if [ -e ns_usr_vol${log_dif}.out ]
then
	 rm ns_usr_vol${log_dif}.out
fi
}

# required in order to allow overwritting of previous files.
	chmod 777 *usr_vol*.out

provision_pab_vol()
{
echo "mkdir -p $pab_volume/$domain_name/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number" >> pab_usr_vol${log_dif}.out
}

provision_cal_vol()
{
echo "mkdir -p $cal_volume/$domain_name/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number" >> cal_usr_vol${log_dif}.out
}

provision_ifs_vol()
{
echo "mkdir -p $ifs_volume/${ifs_domain_prefix}.${domain_name}/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number" >> ifs_usr_vol${log_dif}.out
}

provision_ns_vol()
{
echo "mkdir -p $ns_volume/$domain_name/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number@${domain_name}" >> ns_usr_vol${log_dif}.out
}

write_user_ldif ()
{

echo -n "dn: uid=$user_prefix$user_number,cn=users,cn=$domain_name,cn=domains,cn=cproot,$cproot_dn
changetype:add
objectClass: CpEMLPrefs
objectClass: CpDirWhitePages
objectClass: CpPABPrefs
objectClass: CpCALPrefs
objectClass: CpPSMPrefs
objectClass: CpPBSPrefs
objectClass: CpEMSPrefs
#objectClass: CpIFSPrefs
objectClass: CpNTSPrefs
objectClass: CpSecurityPrincipal
objectClass: CpUSRUserRecordAbs
objectClass: CpUSRUserRecord
sn: ${user_prefix}${user_number}
givenName: ${user_prefix}${user_number}
uid: $user_prefix$user_number
cpEMLUserName: $user_prefix$user_number
" >> $ups_user_ldif
#if not split UPS/Locator the following must be defined on the UPS, otherwise on the Locator
if [ $sep_locator -eq 0 ]
then
echo -n "CpLOCServiceLocation: CpUPSLoc=$ups_dsa_name
CpLOCServiceLocation: CpPBSLoc=$pab_host 
CpLOCServiceLocation: CpCALLoc=http://$cal_host:$cal_command_port
" >> $ups_user_ldif
fi
echo -n "cpPABCardDisplayField: firstName,lastName,homePhone,email
cpPABDisplayField: firstName,lastName,homePhone,email1
cpPABGroupDisplayField: groupName,groupMembers,groupCategories
cpPABNumberToView: 10
cpCALCoS: __DEFAULT_COS__
#cpCALPrimaryURI: http://${cal_host}:${cal_command_port}${cal_volume}/$domain_name/$user_prefix$user_number
cpCALPrimaryURI: http://${cal_host}:${cal_command_port}${cal_volume}/$domain_name/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number
cpCALWorkWeekStartsOn: 1 
cpCALDoubleBooking: true 
cpCALEventReminderTime: 15 
cpCALWorkWeekEndsOn: 5 
cpCALTaskShowCompleted: true 
cpCALTaskView: all 
cpCALCalendarView: month 
cpCALEventReminderUnits: minutes 
cpCALTaskReminderUnits: minutes 
cpCALTaskSortBy: priority 
cpCALTaskHasReminder: true 
cpCALEventDurationTime: 60
cpCALEventDurationUnits: minutes
cpCALTaskReminderTime: 15 
cpEMLAutoSaveDraftFlag: TRUE
cpEMLDeleteSemantics: trash
cpEMLForwardAsAttachmentFlag: FALSE
cpEMLIndexName: Default
cpEMLMaxAttachments: 4
cpEMLNumFoldersToShow: 9
cpEMLNumberToView: 10
#cpEMLPassword: {CPE}61orEO2iB8UVQI1v4VgFow==
cpEMLPassword: {DES}4E6E94B374372486
#cpEMLPassword: {PLAIN}$user_password
cpEMLReplyInlineFlag: FALSE
cpEMLSaveToDraftsInterval: 5
cpEMLSendFormat: 1
cpPBSCoS: __DEFAULT_COS__
cpSID: ${domain_count}${user_number}-111e-0001-8895-aa45be4e8c9f
cpPBSLocation: $pab_volume/$domain_name/${log_dif}/${seed1}/${seed2}/$user_prefix$user_number
cpNTSUserOptions: 63
cpNTSPath: $ns_volume/${domain_name}/${log_dif}/${seed1}/${seed2}/${user_prefix}${user_number}@${domain_name}
cpPSMAllowedApp: Mail_text/html
cpPSMAllowedApp: Mail_text/vnd.wap.wml
cpPSMAllowedApp: Mail_text/vxml
cpPSMAllowedApp: Main_text/html
cpPSMAllowedApp: Main_text/vnd.wap.wml
cpPSMAllowedApp: Main_text/vxml
cpPSMAllowedApp: PSPab_text/html
cpPSMAllowedApp: PSPab_text/vnd.wap.wml
cpPSMAllowedApp: PSPab_text/vxml
cpPSMAllowedApp: Calendar_text/html
cpPSMAllowedApp: Calendar_text/vnd.wap.wml
cpPSMAllowedApp: Calendar_text/vxml
cpPSMAllowedApp: IFS_text/html
cpPSMAllowedApp: IFS_text/vnd.wap.wml
cpPSMAllowedApp: IFS_text/vxml
cpPSMAllowedApp: Notify_text/html
cpPSMAllowedApp: Notify_text/vnd.wap.wml
cpUSRAlternateEmail: $user_prefix$user_number@$domain_name
cpPBSAddressBook: Main:main
cpUSRCategory: Business
cpUSRCategory: Personal
cpUSRCategory: QuickList
cpPBSChangeLog: FALSE
cpUSREnabledFlag: TRUE
cpPBSAddNumContacts: 0
cpPBSAddNumGroups: 0
cpPBSAddNumAddrBooks: 0
cpUSRInvalidLogonCount: 0
cpUSRLastFailedLogonTime: 0
cpUSRLastSuccessfulLogon: 1033569874805
cpUSRLogonCount: 3
#cpUSRPassword: {PLAIN}$user_password 
cpUSRPassword: {DES}4E6E94B374372486
cpUSRPromptForPINFlag: TRUE
cpUSRPhIDCaptureStatus: no.attempt.made.to.capture.unique.phone.id
cpUSRGroupMembership: 09000000-0000-0010-85A7-F052E43B7F37
#cpIFSFileServiceType: public
#cpIFSHomeURL: http://$ifs_domain_prefix.$domain_name:$ifs_listen_port/admin/
#cpIFSUsedQuota: 0
#cpIFSAllowedQuota: 10485760
##########################################################
#### EMAIL account below here - User level only ##########
##########################################################

# mail_account_1033563991668_1085510111, $user_prefix$user_number, users, $domain_name, domains, cproot, net, ie
dn: cpEMLAccountDetails=mail_account_1033563991668_1085510111,uid=$user_prefix$user_number,cn=users,cn=$domain_name,cn=domains,cn=cproot,$cproot_dn 
changetype:add
objectClass: CpEMLAcctDetails
cpEMLAccountDetails: mail_account_1033563991668_1085510111
cpEMLAcctEmailName: $user_prefix$user_number@$domain_name
cpEMLAcctFolderDrafts: Drafts
cpEMLAcctFolderSent: Sent Items
cpEMLAcctFolderTrash: Trash
cpEMLAcctFromEmail: $user_prefix$user_number@$domain_name
cpEMLAcctHostName: $ims_host
cpEMLAcctMailServerType: imap
cpEMLAcctName: Default
cpEMLAcctPamPortNumber: 4201
#cpEMLAcctPassword: {PLAIN}$user_password
cpEMLAcctPassword: {DES}4E6E94B374372486
cpEMLAcctPortNumber: 143
cpEMLAcctReplyTo: $user_prefix$user_number@$domain_name
cpEMLAcctSSLFlag: FALSE
cpEMLAcctTimeOut: 60
cpEMLAcctUserName: $user_prefix$user_number@$domain_name
cpEMLAcctAttachVCardFlag: FALSE

" >> $ups_user_ldif

#call pointer function here
create_locator_pointer

}

add_ldif ()
{

if [ -e ldap_ups${log_dif}.log ]
then
	rm ldap_ups${log_dif}.log
fi

echo "adding UPS entries" >> ldap_ups${log_dif}.log
$BIN_HOME/ldapmodify -v -h $ups_store -p $ups_ldap_port -D $ups_manager -w $ups_password -a -c -f $ups_user_ldif | tee -a ldap_ups${log_dif}.log

}

add_locator_ldif ()
{

if [ -e ldap_locator${log_dif}.log ]
then
	rm ldap_locator${log_dif}.log
fi

echo "adding LOCATOR entries" >> ldap_locator${log_dif}.log
$BIN_HOME/ldapmodify -v -h $locator_store -p $locator_ldap_port -D $locator_manager -w $locator_password -a -c -f $loc_user_ldif | tee -a ldap_locator${log_dif}.log

}

#read from 2nd argument, which should be a file, into an array
#containing all the domain names to be created
readDomains() {
        while read dom ; do
                domNames[$domainCount]=$dom;
                domainCount=`expr $domainCount + 1`
        done
}

clean_user_ldif ()
{
if [ -e $ups_user_ldif ];then
        mv $ups_user_ldif backup/ups_user_ldif.$backup_ext
        echo "File found - Moving to backup directory as ups_user_ldif.$backup_ext"
fi

if [ -e $loc_user_ldif ];then
        rm $loc_user_ldif 
fi

}

create_locator_pointer ()
{
echo -n "dn: uid=$user_prefix$user_number,cn=users,cn=$domain_name,cn=domains,cn=cproot,$locator_cproot_dn
changetype:add
objectClass: CpSecurityPrincipal
objectClass: CpUSRUserRecordAbs
objectClass: CpUSRUserRecord
uid: $user_prefix$user_number
CpLOCServiceLocation: CpUPSLoc=$ups_dsa_name
CpLOCServiceLocation: CpEMSLoc=$ims_host
CpLOCServiceLocation: CpCALLoc=$cal_host:$cal_command_port
CpLOCServiceLocation: CpNTSLoc=$ns_host:$ns_port
CpLOCServiceLocation: CpPBSLoc=$pab_host
cpSID: ${domain_count}${user_number}-111e-0001-8895-aa45be4e8c9f

" >>$loc_user_ldif
}

create_backends ()
{

date 
rcp -p ./remote_pab_user${log_dif}.sh $pab_host:/tmp/remote_pab_user${log_dif}.sh ; tee -a remote_pab_user${log_dif}.out
rsh $pab_host /tmp/remote_pab_user${log_dif}.sh | tee -a remote_pab_user${log_dif}.out
rcp -p ./remote_cal_user${log_dif}.sh $cal_host:/tmp/remote_cal_user${log_dif}.sh | tee -a remote_cal_user${log_dif}.out
rsh $cal_host /tmp/remote_cal_user${log_dif}.sh | tee -a remote_cal_user${log_dif}.out
rcp -p ./remote_ns_user${log_dif}.sh $ns_host:/tmp/remote_ns_user${log_dif}.sh | tee -a remote_ns_user${log_dif}.out
rsh $ns_host /tmp/remote_ns_user${log_dif}.sh | tee -a remote_ns_user${log_dif}.out
date

}

###############################################################################################
##
##  End of functions
##
##############################################################################################

# Start of real stuff here

# check a backup directory exists in case we need to backup existing
# files

if [ ! -e backup ];then

	mkdir -p backup
	echo "Backup Directory didnt exist - created now"	
fi

#Remove old files 
backup_ext=$RANDOM
if [ -e script_duration${log_dif}.out ]
then
	rm script_duration${log_dif}.out
fi

clean_pab_vol
clean_cal_vol
clean_ns_vol
clean_user_ldif

readDomains < $1

#Create script to make remote directories
echo "#!/bin/sh" > remote_pab_user${log_dif}.sh
`chmod +x remote_pab_user${log_dif}.sh`
echo "#!/bin/sh" > remote_cal_user${log_dif}.sh
`chmod +x remote_cal_user${log_dif}.sh`
echo "#!/bin/sh" > remote_ns_user${log_dif}.sh
`chmod +x remote_ns_user${log_dif}.sh`

start_time=`date`
echo "Started: $start_time" >> script_duration${log_dif}.out

# seeds used to generate directories
seed1=1
seed2=1

while [ $domain_count -lt $num_domains ]

do

	domain_name=${domNames[$domain_count]}

	while [ $user_number -lt $user_end ]

	do
		provision_cal_vol
		provision_pab_vol
		#provision_ifs_vol
		provision_ns_vol
		write_user_ldif

		let "user_number += 1"
		let "user_count += 1"

		# used to add 200 users to each seed directory
		if [ $user_count -eq 200 ]
		then
			let "seed2 += 1"
			user_count=0
			if [ $seed2 -eq 201 ]
			then
				let "seed1 += 1"
				seed2=1
			fi
		fi


	done

	user_number=0
	user_count=0

	let "domain_count += 1"
done

#add to remote directory creation script
`cat cal_usr_vol${log_dif}.out >> remote_cal_user${log_dif}.sh`
`cat pab_usr_vol${log_dif}.out >> remote_pab_user${log_dif}.sh`
`cat ns_usr_vol${log_dif}.out >> remote_ns_user${log_dif}.sh`

#Load the created files(s)
#if flag == 0, not loaded, otherwise loaded using ldapmodify
if [ $prov_flag -ne 0 ]
then
	add_ldif
	echo "LDIF file loaded \"$ups_user_ldif\" using ldapmodify"

#load information in LOCATOR DSA, if required
	if [ $sep_locator -eq 1 ]
	then
        	add_locator_ldif
	fi

else
	echo "LDIF not loaded \"$ups_user_ldif\" load manually to DSA using ldapmodify or odsbulkload"
fi

#remove backup files, if required
#if [ $clear_backups -eq 1 ]
#then
        #echo "Removing backup files"
        #`rm backup/*`
#fi

# create backend server directories
create_backends

end_time=`date`
echo "Finished LDIF Creation: $end_time" >> script_duration${log_dif}.out

