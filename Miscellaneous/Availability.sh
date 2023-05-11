#!/usr/bin/env bash
## FILE: Availability.sh
# (c) 2012 THE NOW FACTORY
# http://www.thenowfactory.com
#
author="Daniel Payno <daniel.payno@thenowfactory.com>"
# Creation date: Tue Jul 10 10:41:34 IST 2012
# Modification date: Wed Aug 15 11:07:33 IST 2012
version=0.5.1
#
# Description: This script generates a monthly CSV file for different Availability percentages of the probe. These are
#   Probe - Percentage of availability of the Probe/Box
#   Feed  - Percentage of availability of the Feed /non null values during operation/. Relative to Probe's availability
#   Data Completeness (Quality) - Comparison between total feed and total GTP-U processed bandwidth
#   SourceWorks/Dacas - percentage of availability of each of the Dacas Processes, and Overall of Dacas
#   Dacas/Card Drop - Percentage of feed dropped by dacas at card level
#   Total GTP-U Drop - Percentage of GTP-U packets dropped
#   Total TDRs logged 
#   Dacas Availability per process
#   TDRs logged per process
#   GTP-U dropped percentage per process
#
#  CRONTAB:
#  # Availability script that leaves a monthly CSV output in /apps/midas/scripts/output/Availability
#  7 3 * * * /usr/bin/nice /apps/midas/scripts/Availability.sh > /dev/null 2>&1
#
#  OUTPUT FORMAT
#  :::::::::::::
#  The Header of the output file is as follows, being i the list of configured processes present in dlauncher.cfg file
#  Date,Probe_Availability,Feed Availability,Quality,Dacas Total Availability,Dacas/Card_Drop_Percentage,GTP-U_Total_DROP,Total_TDRs_Logged,Dacas_${i}_Availability,TDRs_Dacas_${i},GTP-U-Drop_${i}
#
#  SAMPLE OUTPUT
#  ::::::::::::::
#  Date,Probe_Availability,Feed Availability,Quality,Dacas Total Availability,Dacas/Card_Drop_Percentage,GTP-U_Total_DROP,Total_TDRs_Logged,Dacas_0_Availability,Dacas_5_Availability,Dacas_6_Availability,Dacas_7_Availability,Dacas_8_Availability,Dacas_9_Availability,Dacas_10_Availability,Dacas_11_Availability,Dacas_12_Availability,TDRs_Dacas_0,TDRs_Dacas_5,TDRs_Dacas_6,TDRs_Dacas_7,TDRs_Dacas_8,TDRs_Dacas_9,TDRs_Dacas_10,TDRs_Dacas_11,TDRs_Dacas_12,GTP-U_DROP_0,GTP-U_DROP_5,GTP-U_DROP_6,GTP-U_DROP_7,GTP-U_DROP_8,GTP-U_DROP_9,GTP-U_DROP_10,GTP-U_DROP_11,GTP-U_DROP_12
#  15/08/2012,100.00,100.00,79.76,99.91,23.24,.05,2040449131,0,99.86,99.93,100.00,99.93,99.86,99.93,99.93,99.86,0,248082784,273355492,243537253,257228402,267312724,244567692,250997575,255367209,0,.04,.07,.03,.09,.05,.02,.05,.10
#
# ==(C H A N G E L O G)==
#  Date      Rev       Author                 Description
# ==========================================================
#  10/Jul/2012 0.1    Daniel Payno      Integration of 3 into 1
#  10/Jul/2012 0.2    Daniel Payno      Correction in the DispOrClas decision
#  11/Jul/2012 0.3    Daniel Payno      Added total TDRs breakdown per-process
#  17/Jul/2012 0.3.1  Daniel Payno      Dacas availability takes into account 0 TDRs being logged 
#  18/Jul/2012 0.4	  Daniel Payno		  Major rewrite. Now uses dlauncher.cfg as standard repository for configuration
#                                       generalising the stat collection to every deployment run with 1 dlauncher
#                                       floating point precision for all percentage KPIs
#                                       The output file format is then dinamically generated according to the deployment
#  22/7/2012  0.4.1   Daniel Payno      Correct a minor decision bug, and also process 32 taken out of the logic as irrelevant
#  15/8/2012  0.5     Daniel Payno	added GTP-U dropped per dacas process and overall. 
#  			                Introduced a new QualityOfGTPvsFeed. Major restructuring
#  21/8/2012  0.5.1   Daniel Payno	Fixed a major bug when calculating the Card Drop % KPI.
#
##full path commands not built-in bash
WHICH="/usr/bin/which"
RGREP=$( $WHICH rgrep)
EGREP=$( $WHICH egrep)
GREP=$( $WHICH grep)
AWK=$( $WHICH awk)
UNIQ=$( $WHICH uniq)
CUT=$($WHICH cut)
CAT=$( $WHICH cat)
SORT=$($WHICH sort)
WC=$($WHICH wc)
SCRIPT_NAME=$(/usr/bin/basename $0 .sh)
SERVER_NAME=$(/bin/uname -n)
YEARMONTH=$(/bin/date -dyesterday -u +'%Y-%m')
BC=$($WHICH bc)
MINs=2500
### User settings
DLAUNCHERHOME="/apps/midas/admin/"
YESTERDAY=$(/bin/date -dyesterday +'%d/%m/%Y')
OUTPUT_DIR="/apps/midas/scripts/output/Availability/"
OUTPUT_FILE="${OUTPUT_DIR}${SCRIPT_NAME}-${SERVER_NAME}-${YEARMONTH}.csv"
STATs_DIR="/apps/midas/bin/MANAGE/process/dacas/stats/"
NICstatsDIR="/apps/midas/scripts/output/DCV/NIC-stats/"
DLAUNCHERCFG="/apps/midas/admin/dlauncher.cfg"
### filters
STATs_FILEs="stat*log"
STRING="Total TDRs logged ="
STRINGG="Total TDRs logged = 0"
STRINGGTPUDROP="Gtp-U dropped bytes count ="
STRINGGTPUPROC="Gtp-U processed bytes count ="

function validations {
	#DispatcherOrClassifier DOC=(0,1)
	if [ -f ${DLAUNCHERCFG} ]; then 
		local TYPE=$($GREP "^REQUIRES" ${DLAUNCHERCFG} |$EGREP  "classifier|dispatcher"|$GREP -v "^#"|$UNIQ |$CUT -d= -f2 2>/dev/null)
		if [ ${TYPE} == "dispatcher" ]; then DOC=0; elif [ ${TYPE} == "classifier" ]; then DOC=1; fi
	else
		DLAUNCHERCFG=$(find ${DLAUNCHERHOME} -name dlauncher.cfg 2>/dev/null|$UNIQ)	
		local TYPE=$($GREP "^REQUIRES" ${DLAUNCHERCFG} |$EGREP  "classifier|dispatcher"|$GREP -v "^#"|$UNIQ |$CUT -d= -f2 2>/dev/null)
		if [ ${TYPE} == "dispatcher" ]; then DOC=0; elif [ ${TYPE} == "classifier" ]; then DOC=1; fi
	fi	
	list=$( $RGREP 'configuration.xml[0-9][0-9]*' ${DLAUNCHERCFG}|$GREP -v "^#"|$AWK -F\/ '{print $6}'|$GREP -v "xml32"|$AWK '{gsub(/configuration.xml/,"");print}'|$SORT -n)
	nProcs=$( echo "${list}" |$WC -l)
	##if classifier subtract the 0 process from the total to calculate %s from, as it represents a special drop process
	if [ $DOC -eq 1 ]; then nProcs=$(( $nProcs -1 )); fi
}

function print_Output {
	local PRINTF=$($WHICH printf)
	if [ ! -d ${OUTPUT_DIR} ]; then
		mkdir -p ${OUTPUT_DIR}
	fi
	if [ ! -e ${OUTPUT_FILE} ]; then
		## Rotate the file every month
		$CAT /dev/null > "${OUTPUT_FILE}"	
		$PRINTF "Date,Probe_Availability,Feed Availability,Data_Completeness,SourceWorks Total Availability,Dacas/Card_Drop_Percentage,GTP-U_Total_DROP,Total_TDRs_Logged" >> ${OUTPUT_FILE}
  		for i in ${list}; do $PRINTF ",Dacas_${i}_Availability">> ${OUTPUT_FILE} ; done
  		for i in ${list};	do $PRINTF ",TDRs_Dacas_${i}" >> ${OUTPUT_FILE} ; done
 	   for i in ${list};	do $PRINTF ",GTP-U_DROP_${i}" >> ${OUTPUT_FILE} ; done
		$PRINTF "\n" >> ${OUTPUT_FILE}
	fi
	### Add yesterday's stats to the file
	$PRINTF "${YESTERDAY},${AVA},${FeedAVA},${Quality},${DacasTotalAva},${Drop},${TotalGTPuDrop},${TotalsTDRs}" >> ${OUTPUT_FILE}
 	for i in ${list}; do $PRINTF ",${DacasAvailability[${i}]}" >> ${OUTPUT_FILE} ; done
 	for i in ${list};	do $PRINTF ",${TDRCount[${i}]}" >> ${OUTPUT_FILE} ; done
 	for i in ${list};	do $PRINTF ",${GTPUDROP[${i}]}" >> ${OUTPUT_FILE} ; done
	$PRINTF "\n" >> ${OUTPUT_FILE}
}


#== M A I N  P R O G R A M ===============================
	validations
   #### PORTION OF CODE WHERE WE CALCULATE FEED KPIS
	YDayStats=$(/usr/bin/find ${NICstatsDIR} -name "*csv" -daystart -mtime 1)
	if [ ! -s "${YDayStats}" ]; then 
		AVA=0
		FeedAVA=0
		FeedSUM=0
	else
		YDaysCount=$($CAT ${YDayStats} | $WC -l  )
		Zero=$($CAT ${YDayStats}| $AWK -F, '$3==0 {print $3}'|$WC -l)
		## Drop % at card level
		Drop=$($CAT ${YDayStats}| $AWK -F, '{SUMF+=$3; SUMD+=(($8/100)*$3)} END { if (SUMF<=0) print 0; else printf ("%.2f\n",(SUMD*100)/SUMF); } ') 
		FeedSUM=$($CAT ${YDayStats}| $AWK -F, '{SUMF+=$3} END {printf ("%.2f\n",SUMF)} ') 
		Diff=$(( 1441 - $YDaysCount ))
		AVA=$(echo "scale=2; 100*(1441-$Diff)/1441"|$BC -q 2>/dev/null)
		FeedAVA=$(echo "scale=2; 100*((1441-$Diff)-($Zero))/(1441-$Diff)"|$BC -q 2>/dev/null )
	fi
   #### PORTION OF CODE RELATIVE TO THE DACAS KPIS
	TotalsDacas=0
	TotalsTDRs=0
	TotalGTPuDrop=0
	SubTotalGTPuDrop=0
	TotalGTPuProc=0
	for i in ${list}
	do
	if [ -d ${STATs_DIR}$i ]; then 
		## MAIN SEARCH FOR YESTERDAY STATS (ALL)
		searchYesterday=$(/usr/bin/find ${STATs_DIR}$i -name ${STATs_FILEs} -mmin -${MINs} -exec $GREP "^${YESTERDAY}" {} \;|$EGREP "${STRING}|${STRINGGTPUDROP}|${STRINGGTPUPROC}" 2>/dev/null) 
		## DACAS count
		CountDacas=$(echo "${searchYesterday}"|$GREP "${STRING}"|$WC -l)
		### TDRS logged=0 count
		CountDacasZeros=$(echo "${searchYesterday}"|$GREP "${STRINGG}"|$WC -l)
		## total effective dacas processing minutes
		SubTotalDac=$(( ${CountDacas}-${CountDacasZeros} ))
		## Percentage calculation of Dacas availability
		DacasAvailability[${i}]=$(echo "scale=2; 100*(1440-(1440-${SubTotalDac}))/1440" | $BC -q 2>/dev/null) 
		## TDR count 
		TDRCount[${i}]=$( echo "${searchYesterday}"| $GREP  "${STRING}"|$SORT |$AWK '{SUM+=$7} END {print SUM}') 
		## GTP-U processed bytes count
		GTPUProcCount[${i}]=$( echo "${searchYesterday}"|$GREP  "${STRINGGTPUPROC}"|$SORT |$AWK '{SUM+=$9} END {print SUM}') 
		### GTP-U dropped bytes count
		GTPUDropCount[${i}]=$( echo "${searchYesterday}"|$GREP  "${STRINGGTPUDROP}"|$SORT |$AWK '{SUM+=$9} END {print SUM}') 
		## Percentage of GTP-U Drop relative to the total GTP-U (proc and dropped)
		if [[ ${GTPUDropCount[${i}]} != "0" || ${GTPUProcCount[${i}]} != "0" ]]; then
    	GTPUDROP[${i}]=$( echo "scale=2;100*${GTPUDropCount[${i}]}/(${GTPUDropCount[${i}]}+${GTPUProcCount[${i}]})" | $BC -q 2>/dev/null )
		fi
		### CONDITION SO THAT THE SUBTOTALS DON'T GET ADDED TO THE OVERALL TOTALS FOR DOC=1 and i=0
		if [[ $DOC -eq 1 && $i -eq 0 ]]; then
			SubTotalDac=0
			GTPUDROP[${i}]=0
		else 
			TotalsTDRs=$(( $TotalsTDRs+${TDRCount[${i}]} ))
		fi
		TotalsDacas=$(( $TotalsDacas+$SubTotalDac ))
		SubTotalGTPuDrop=$( echo "scale=2;$SubTotalGTPuDrop+${GTPUDROP[${i}]}"|$BC -q 2>/dev/null )
		TotalGTPuProc=$( echo "scale=2; $TotalGTPuProc+${GTPUProcCount[${i}]}"|$BC -q 2>/dev/null )
	fi
	done
	## GTP is in Bytes/Min -> * 8/60 to convert to bps
	## FeedSum is in Mbps -> *1024*1024 to convert to bps
	## We bias it according to the Feed Availability, so if we have 64% of Feed we don't see 90% of Quality, misleading the value
	if [ ${FeedSUM} != "0" ]; then
		Quality=$( echo "scale=2;(100*($TotalGTPuProc*8/60)/($FeedSUM*1024*1024))*($FeedAVA/100)"| $BC -q 2>/dev/null ) 
	else
		Quality=0
	fi
	DacasTotalAva=$( echo "scale=2;100*$TotalsDacas/($nProcs*1440)"|$BC -q 2>/dev/null )
	TotalGTPuDrop=$( echo "scale=2;$SubTotalGTPuDrop/($nProcs)"|$BC -q 2>/dev/null )
	########################
	print_Output
