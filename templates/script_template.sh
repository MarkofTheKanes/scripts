#!/bin/bash 
# ====================================================================
# THE NOW FACTORY -  http://thenowfactory.com
# All right reserved - This software is licensed by TheNowFactory Ltd.
# ====================================================================

#=== M A I N  P R O G R A M ===============================


source /apps/midas/scripts/lib/srcw_bash_lib.sh

##check command line options, if any
while getopts "vhd" OPTION ; do
    case $OPTION in
        v) SHOW_VERSION
        ;;
        h) SHOW_HELP
        ;;
        d) DEBUG=1
        ;;
    esac
done

do_things() {

{

check_instance  # or lock and unlock at the end

initialize

do_things

clean_tmp


