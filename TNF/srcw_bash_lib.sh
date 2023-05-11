######################################### LIBRARY #########################################################
# 
#   This library have the following functions
#
#   SHOW_LIB_VERSION()--- return library version to be cheked in the script if needed 
#   SHOW_VERSION()    --- Take $VERSION and print it on STDOUT
#   SHOW_HELP()       --- Take $HELP variable and print it
#   
#   debugging($TXT)   --- Print the $TXT in debug file if DEBUG=1
#   info($TXT)        --- Print the $TXT as INFO in LOG_FILE    
#   warn($TXT)     --- Print the $TXT as WARNING in LOG_FILE    
#   error($TXT)       --- Print the $TXT as ERROR in LOG_FILE    
#
#   slock             --- Lock the script for single execution (permit 1 script running at the same time)
#   sunlock           --- UnLock the script for double execution (permit 2 script running at the same time)
#                         For both slock/sunlock there is no timeout for the lock
#   dlock             --- Lock the script for double execution (permit 2 script running at the same time)
#   dunlock           --- UnLock the script for double execution (permit 2 script running at the same time)
#                         For both dlock/dunlock the script run anyway after 6 hour 
#
#   lock              --- lock use the default slock
#   unlock            --- unlock use the default sunlock
#
#   check_instance    --- check for script instance and exit if it found antoher running
#
#   valid_ip          --- take an IP as input (with no space before o after) and 
#                         return 0 if is valid !=0 otherwise
#
#   initialize_lib()  --- Inititalise Libs Variables, is called by the script itself and it doens't need to
#                         be called manually form the script
###########################################################################################################

SRCW_LIB_VERSION="0.1"

SHOW_LIB_VERSION() {
    return $SRCW_LIB_VERSION
}


SHOW_VERSION() {
    echo -e "$VERSION \n"
    exit 0
}

SHOW_HELP() { 
    echo -e "
 DESCRIPTION: ${PROGRAM_NAME} does: 
 $HELP
 ";  
    exit 0;
}

debugging() {
    [ "$DEBUG" -eq 1] && [ -n "${DEBUG_FILE}" ] && [ -f "${DEBUG_FILE}" ] && echo -e "`$LibNOW`-DEBUG- $1 \n" >> ${DEBUG_FILE}
}

info() {
    [ -n "${LOG_FILE}" ] && [ -f "${LOG_FILE}" ] && echo -e "`$LibNOW`-INFO- $1 \n" >> ${LOG_FILE}
}

error() {
    [ -n "${LOG_FILE}" ] && [ -f "${LOG_FILE}" ] && echo -e "`$LibNOW`-ERROR- $1 \n" >> ${LOG_FILE}
}

warn() {
    [ -n "${LOG_FILE}" ] && [ -f "${LOG_FILE}" ] && echo -e "`$LibNOW`-WARNING- $1 \n" >> ${LOG_FILE}
}

dlock() {
    if [ -f "$LOCKFILE" ]; then
        /usr/bin/find -wholename $LOCKFILE2 -mmin +360 -exec /bin/rm {} \;
        if [ -f "$LOCKFILE2" ]; then
            warn "$PROGRAM_NAME Locked, jump this iteration"
            exit 1
        else 
            /bin/touch $LOCKFILE2
            warn "$PROGRAM_NAME double lock, try to run"
        fi
    else
        /bin/touch $LOCKFILE
    fi
}

dunlock() {
    /bin/rm -f $LOCKFILE $LOCKFILE2
}

slock() {
    if [ -f "$LOCKFILE" ]; then
       warn "$PROGRAM_NAME Locked, jump this iteration"
       exit 1
    else
        /bin/touch $LOCKFILE
    fi
}

sunlock() {
    /bin/rm -f $LOCKFILE 
}

lock() {
    # default lock is slock
    slock
}

unlock() {
    # default unlock is sunlock
    sunlock
}

check_instance() {

    local CHECK="`/usr/bin/lsof | /bin/grep -e "${PROGRAM_NAME}$" | /bin/grep -v $$`"
    if [ -n "${CHECK}" ]; then
        warn "Another instance of $PROGRAM_NAME is still running, aborting current script!"
        exit 1
    fi
}



# Take an IP as input return 0 if ok !=0 otherwise
valid_ip() {
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


initialize_lib() {

    PROGRAM_NAME="`/usr/bin/basename $0`"

    SEPARATOR="===================================================================="

    # These are the default directories
    BASE_DIR="/apps/midas/scripts/"
    OUTPUT_DIR="${BASE_DIR}/output/${PROGRAM_NAME}"
    LOG_DIR="${BASE_DIR}/log/${PROGRAM_NAME}"
    TMP_DIR="${BASE_DIR}/tmp/${PROGRAM_NAME}"
    CONFIG_DIR="${BASE_DIR}/etc"
    CONF_FILE="${CONFIG_DIR}/${PROGRAM_NAME}.cfg"
    LOG_FILE="${LOG_DIR}/${PROGRAM_NAME}.log"
    DEBUG_FILE="${LOG_DIR}/${PROGRAM_NAME}.debug"

    #keep lock files in /tmp (so at reboot, this directory is automatically cleared)
    LOCKFILE="/tmp/${PROGRAM_NAME}.lock"
    LOCKFILE2="/tmp/${PROGRAM_NAME}.lock"

    # This variable is used to define the TIMESTAMP output, call it with `$LibNOW` do print the right date
    # used by logging functions
    LibNOW="date '+%Y/%m/%d-%H:%M'"

    # Set DEBUG=0 by default
    DEBUG=0
    # load Conf file so user can change default files and dirs

    [ -f "${CONF_FILE}" ] && source ${CONF_FILE}


    # Create the LOG_DIR and check if exist
    /bin/mkdir -p $LOG_DIR
    if [ ! -d "$LOG_DIR" ]; then
        echo "ERROR -- Log dir $LOG_DIR can't be created : $! "
        exit 1
    fi

    # Create the OUTPUT_DIR and check if exist
    /bin/mkdir -p $OUTPUT_DIR
    if [ ! -d "$OUTPUT_DIR" ]; then
        error "Output dir $OUTPUT_DIR can't be created : $! "
        exit 1
    fi

    # Create the TMP_DIR and check if exist
    /bin/mkdir -p $TMP_DIR
    if [ ! -d "$TMP_DIR" ]; then
        error "Tmp dir $TMP_DIR can't be created : $! "
        exit 1
    fi

    if [ -n "$DEBUG" ] && [ "$DEBUG" -eq '1' ]; then
        > $DEBUG_FILE
    fi

}


initialize_lib

