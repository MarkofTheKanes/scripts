#!/bin/sh
# psinstall.sh

UNAME=""
PRODUCTVERSION=2.5
NSVERSION=2.0
OS=""
SCRIPTNAME=./psinstall.sh

save_file()
{
    FNAME=$DSTDIR/$NAME
    if test -f $FNAME; then
        i=0;
        while test -f $FNAME.$i; do
            i=`expr $i + 1`
        done;

        echo "Save $NAME in $NAME.$i"
        Wlog "Save $NAME in $NAME.$i"
        cp $FNAME $FNAME.$i
        CheckExitStatus
    fi

}

copy_file()
{
    save_file
    echo "Replace $NAME"
    Wlog "Replace $NAME"
    cp $SRCDIR/$NAME $DSTDIR/$NAME
    CheckExitStatus
}

patch_file()
{
    FNAME=$DSTDIR/$NAME
    if test -f $FNAME; then
        echo "Patch file $NAME"
        Wlog "Patch file $NAME"

        $PS_INSTALL/cp/WEB-INF/nspatches/nsuipatch $PS_INSTALL/cp $FID
        Res=`echo $?`
        if [ $Res -eq 1 ]; then
            echo "$FNAME seems already patched for CP Notification Server"
            Wlog "$FNAME seems already patched for CP Notification Server"
        else
            if [ $Res -eq 0 ]; then
                Wlog "$FNAME successfully patch"
            else
                Wlog "$FNAME patch failed"
                exit 2
            fi
        fi
    else
        echo "$FNAME doesn't exit. You should have installed CP Presentation Server first"
        Wlog "$FNAME doesn't exit. You should have installed CP Presentation Server first"
    fi
} 

CheckUserId()
{
    IDSTRING=`id | awk '{ print $1 }'`
    if [ "$IDSTRING" != "uid=0(root)" ]; then
        echo
        echo
        echo
        echo "***********************************************************************"
        echo "    ERROR: You must be root to install.                                "
        echo "***********************************************************************"
        echo
        echo
        echo
        exit 2
    fi
}

GetCDLOC()
{
    # Finding the location of the script
    # and changing to that location

    if [ ! -d /tmp ]; then
        mkdir /tmp
    fi

    rm -f /tmp/loc.cfg

    touch /tmp/loc.cfg

    if [ "$0" = "$SCRIPTNAME" ]; then
        #echo "Installing for default location"
        echo
    else
        echo $0 > /tmp/loc.cfg
        awk < /tmp/loc.cfg '{
            n=split($0,arr,"/")
            for (i=2; i<= n -1 ; i++) s=s"/"arr[i]
            print s > "/tmp/loc.cfg"
        }'
        CDLOC="`cat /tmp/loc.cfg`"
        if [ ! -d "$CDLOC" ]; then
            if [ ! -d ".$CDLOC" ]; then
                echo "Please change directory to the location of the script $SCRIPTNAME"
            else
                cd .$CDLOC
            fi
        else
            cd $CDLOC
        fi
    fi
}

GetInstallDir()
{
    if test "$OS" = "SPARC"; then
        INSTALLDIR=`ckstr -Q -W 80 -p "Tomcat install directory :"` || exit 1
        PATH=$INSTALLDIR:$PATH; export PATH
    else
        echo "Tomcat install directory :"
        read INSTALLDIR
        PATH=$INSTALLDIR:$PATH; export PATH
    fi
}

Wlog()
{
    if [ ! -d /tmp ]; then
        mkdir /tmp
    fi

    if [ ! -f /tmp/psinstall.log ]; then
        touch /tmp/psinstall.log
    fi

    echo "" >> /tmp/psinstall.log
    echo "$1" >> /tmp/psinstall.log
}

CheckExitStatus()
{
    EStatus=`echo $?`

    if [ $EStatus -eq 0 ]; then
        Wlog "$1 was successful"
    else
        Wlog "$1 was unsuccessful"
        exit 2
    fi
}

check_diskspace()
{
    if [ ! -d $1 ]; then

        Wlog "Invalid Tomcat install directory"
        Wlog "Now exiting."

        echo
        echo
        echo "Invalid Tomcat install directory"
        echo "Now exiting."

        exit  2
    fi

    if [ ! -f $1/bin/catalina.sh ]; then

        Wlog "Invalid Tomcat install directory"
        Wlog "Now exiting."

        echo
        echo
        echo "Invalid Tomcat install directory"
        echo "Now exiting."

        exit  2
    fi
    
    if [ "$1" != "" ] ; then
       
        if test "$OS" = "HP-UX" ; then
	    DISKSPACE="`df  -b $1 | awk '{ print $5 }'`"
            CheckExitStatus "df  -b $1 | awk '{ print $5 }'"
        elif test "$OS" = "SPARC" || test "$OS" = "LINUX" ; then
            DISKSPACE="`df -k $1 | tail -1 | awk '{ print $4 }'`"
            CheckExitStatus "df -k $1 | tail -1 | awk '{ print $4 }'"
        fi

        DFREE=`expr $DISKSPACE / 1024`
        CheckExitStatus "expr $DISKSPACE / 1024"

        if [ $DFREE -ge 10 ] ; then
            Wlog "Ample disk space found on $1, Installation continues..."
        else
            Wlog "Not enough disk space $1 for installtion to continue"
            Wlog "Now exiting."

        echo
        echo
        echo "Not enough disk space $1 for installtion to continue"
        echo "Now exiting."

        exit  2

        fi
    else
        echo "Directory was empty, could not check disk space"
        Wlog "Directory was empty, could not check disk space"
    fi
}

requirement_check_standalone()
{
    echo "                                                                        "
    echo " The following applications are required for the CP Presentation Server:"
    echo "   - Java 2 Platform, Standard Edition (J2SE) version 1.3.1"
    echo "   - Tomcat Java Servlet engine version 4.0.1"
    echo "                                                                        "
    echo " A copy of these applications is provided on the CD, in the apps        "
    echo " subdirectory. If you don't have these applications installed on your   "
    echo " system, please cancel this script, install them, and then re-run the   "
    echo " CP Presentation Server setup script.                                   "
    echo "                                                                        "
    echo "                                                                        "

  RESP=
  if test "$OS" = "SPARC"; then
    while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
       RESP=`ckstr -W 80 -p "Do you want to continue with this setup? [y/n] "` || exit 1
    done
  else
    while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
        echo "Do you want to continue with this setup? [y/n] "
        read RESP || exit 1 
    done
  fi

    if [ "x$RESP" = "xn" ]; then
       exit 2
    fi
}

requirement_check_integrated()
{
    echo "                                                                        "
    echo " This version of CP PS Notification Server requires an already installed"
    echo " and running version of CP Presentation Server.                         "
    echo ""
    echo " If you don't have this, then you probably wanted to install the        "
    echo " standalone version of CP PS Notification Server. If so, exit this      "
    echo " setup and run ./psinstall.sh standalone.                        "
    echo " If you want to continue to install CP PS Notification Server integrated"
    echo " with other CP PS application, continue this setup.                     " 
    echo "                                                                        "
  if test "$OS" = "SPARC"; then
    while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
       RESP=`ckstr -W 80 -p "Do you want to continue with this setup? [y/n] "` || exit 1
    done
  else
    while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
        echo "Do you want to continue with this setup? [y/n] "
        read RESP || exit 1
    done
  fi

    if [ "x$RESP" = "xn" ]; then
       exit 2
    fi
}

sys_check()
{
    if [ "`uname`" = "HP-UX" ]; then
        OS="HP-UX"
        UNAME="uname"
    elif [ "`uname -p`" = "sparc" ]; then
        OS="SPARC"
        UNAME="uname -p"
    elif [ "`uname`" = "Linux" ]; then
        OS="LINUX"
        UNAME="uname"
    else
        echo ""
        echo "***********************************************************************"
        echo "    Platform unknown. Install supports SPARC,LINUX only                      "
        echo "***********************************************************************"

        Wlog "Platform unknown. Install supports SPARC,LINUX"

        exit 2
    fi
}

ps_install()
{
    echo ""
    echo "***********************************************************************"
    echo "    Installing CP Presentation Server                                  "
    echo "***********************************************************************"
    echo ""

    Wlog "Installing Presentation Server"

    check_diskspace "$INSTALLDIR"
    
    PS_JSE_DIR="$INSTALLDIR/lib"
    PS_INSTALL="$INSTALLDIR/webapps"
    PS_PAB_SO="/usr/lib"
    
    echo "Copying install image..."
    Wlog "Copying install image..."

    cp ./ps/cp.war $PS_INSTALL
    CheckExitStatus "cp ./PS_SPARC $PS_INSTALL"

    cp ./lib/*jar $PS_JSE_DIR
    cp lib/*jar $PS_JSE_DIR
    CheckExitStatus "cp ./PS_JSE $PS_JSE_DIR"

    cd $PS_INSTALL

    echo "Setting configuration parameters..."
    Wlog "Setting configuration parameters..."
 
    cd $INSTALLDIR/bin

    search="CATALINA_OPTS=\\\"-server -Xms256m -Xmx256m -XX:NewSize=128m -XX:MaxNewSize=128m -XX:SurvivorRatio=2"
    count=`grep -c "$search" catalina.sh`

    if [ $count = "0" ]; then
        cp catalina.sh catalina.bak
        cat catalina.sh | sed "s/CATALINA_OPTS=\\\"/CATALINA_OPTS=\\\"-server -Xms256m -Xmx256m -XX:NewSize=128m -XX:MaxNewSize=128m -XX:SurvivorRatio=2 /g" > catalina.tmp
        mv catalina.tmp catalina.sh
    fi

    chmod a+x catalina.sh
}

ps_extract()
{
    echo ""
    echo "Extracting Presentation Server..."
    Wlog "Extracting Presentation Server..."
    cd $PS_INSTALL
    mkdir cp
    CheckExitStatus "mkdir cp"
    cd cp
    CheckExitStatus "cd $PS_INSTALL/cp"
    jar -xf ../cp.war
    echo "Extraction done"
    Wlog "Extraction done"
    rm ../cp.war
}

ns_install()
{
    echo "***********************************************************************"
    echo "    Installing CP PS Notification Server                               "
    echo "***********************************************************************"
    echo ""

    Wlog "Installing CP PS Notification Server"
    
    cp ./ns/ns.jar $PS_INSTALL
    CheckExitStatus "cp ./ns/ns.jar $PS_INSTALL"
}

ns_extract()
{
    echo "Extracting CP PS Notification Server..."
    Wlog "Extracting CP PS Notification Server..."
    
    cd $PS_INSTALL
    cd cp
    CheckExitStatus "cd $PS_INSTALL/cp"
    jar xf ../ns.jar
    echo "Extraction done"
    rm ../ns.jar
}

ns_install_asset_standalone()
{
    echo "Updating assets files..."
    Wlog "Updating assets files..."
    
    ASSETDIR=$PS_INSTALL/cp/WEB-INF/assets/default
    cd $ASSETDIR

    LIST=`ls`

# Remove languages not supported
    for i in $LIST; do
        if test -d $ASSETDIR/$i; then
            if test ! -f $ASSETDIR/$i/Notify.xml; then
#               Not localized, simply remove the language folder
                rm -fr $ASSETDIR/$i
            fi
        fi
    done
    echo "Update assets files done..."
}

ns_install_asset_integrated()
{
    echo "Updating assets files..."
    Wlog "Updating assets files..."
    
    ASSETDIR=$PS_INSTALL/cp/WEB-INF/assets/default
    cd $ASSETDIR

    LIST=`ls`

    for i in $LIST; do
        if test -d $ASSETDIR/$i; then
            if test ! -f $ASSETDIR/$i/Notify.xml; then
#               Not localized. Use the en language
                cp $ASSETDIR/en/Notify.xml $ASSETDIR/$i
            fi
        fi
    done
    echo "Update assets files done..."
}

ns_install_help_standalone()
{
    echo "Updating help files..."
    Wlog "Updating help files..."
   
    HELPDIR=$PS_INSTALL/cp/help/default
    cd $HELPDIR
    LIST=`ls`

    for i in $LIST; do
        if test -d $HELPDIR/$i/html/Main_Prefs.html; then
#           Override the General Prefs help page
            cp $HELPDIR/$i/html/Main_Prefs.html $HELPDIR/$i/html/Main3.html
        fi
    done
    echo "Update help files done..."
}

ns_install_help_integrated()
{
    echo "Updating help files..."
    Wlog "Updating help files..."
   
    HELPDIR=$PS_INSTALL/cp/help/default

    cd $HELPDIR/en/html
    NSFILES=`ls Notify*.html NS*.html`

    cd $HELPDIR
    LIST=`ls`

    for i in $LIST; do
        if [ $i != "en" ] ; then
            if test -d $ASSETDIR/$i; then
                for j in $NSFILES; do
                    if test ! -f $HELPDIR/$i/html/$j; then
#                       The file doesn't exist, copy the en version
                        cp $HELPDIR/en/html/$j $HELPDIR/$i/html
                    fi
                done
            fi
        fi
    done
    echo "Update help files done..."
}

ns_patch_standalone()
{
    cd $PS_INSTALL/cp/WEB-INF/nspatches
    SRCDIR=.
    
    # Copy web.xml
    NAME=web.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF
    copy_file

    # Copy settings-conf-upsv2.xml
    NAME=settings-conf-upsv2.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF/etc
    copy_file

    # Copy ps-conf.xml
    NAME=ps-conf.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF/etc
    copy_file
}

ns_patch_integrated()
{
    cd $PS_INSTALL/cp/WEB-INF/nspatches
    SRCDIR=.
    
    chmod u+x $PS_INSTALL/cp/WEB-INF/nspatches/nsuipatch
    
#   Change LD_LIBRARY_PATH to be able to use libnplexmalloc.so
    LIB_ORIG=$LD_LIBRARY_PATH
    if [ "$LD_LIBRARY_PATH" != "" ]; then
        LD_LIBRARY_PATH=$LIB_ORIG:$PS_INSTALL/cp/WEB-INF/nspatches
    else
        LD_LIBRARY_PATH=$PS_INSTALL/cp/WEB-INF/nspatches
    fi
    export LD_LIBRARY_PATH

    # Patch web.xml file
    NAME=web.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF
    FID=web
    patch_file   

    # Patch settings-conf-upsv2.xml
    NAME=settings-conf-upsv2.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF/etc
    FID=settings
    patch_file

    # Patch ps-conf.xml
    NAME=ps-conf.xml
    DSTDIR=$PS_INSTALL/cp/WEB-INF/etc
    FID=conf
    patch_file

#   Restore original value
    LD_LIBRARY_PATH=$LIB_ORIG
    export LD_LIBRARY_PATH
}   

install_ps_license()
{
    echo "**************************************************************"
    echo "Installation of Presentation Server license - product code 954"

    RESP=
    if test "$OS" = "SPARC"; then
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            RESP=`ckstr -W 80 -p "Do you want to install Presentation Server license now? [y/n] "` || exit 1
        done
    else
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            echo "Do you want to install Presentation Server license now? [y/n] "
            read RESP || exit 1 
        done
    fi

    if [ "x$RESP" = "xn" ]; then
       echo "*** You will have to install Presentation Server license later using the"
       echo "rlinstall utility in $PWD/util"
       Wlog "You will have to install Presentation Server license later using the rlinstall utility in $PWD/util"
    else
#       chmod a+x ./util/rlinstall
        echo ./util/rlinstall -i -p 954 -d $PS_INSTALL/cp/WEB-INF/etc
        ./util/rlinstall -i -p 954 -d $PS_INSTALL/cp/WEB-INF/etc
    
        EStatus=`echo $?`

        if [ $EStatus -eq 1 ]; then
            Wlog "PS license installation was successful"
        else
            echo "*** Presentation Server license installation failed. You can try later to install license using rlinstall tool"
            Wlog "Presentation Server license installation failed"
        fi
    fi
    echo ""
}


install_ns_license()
{
    echo "*********************************************************************"
    echo "Installation of CP PS Notification Server license - product code 1006"

    RESP=
    if test "$OS" = "SPARC"; then
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            RESP=`ckstr -W 80 -p "Do you want to install CP PS Notification Server license now? [y/n] "` || exit 1
        done
    else
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            echo "Do you want to install CP PS Notification Server license now? [y/n] "
            read RESP || exit 1 
        done
    fi

    if [ "x$RESP" = "xn" ]; then
       echo "*** You will have to install CP PS Notification Server license later using the"
       echo "rlinstall utility in $PWD/util"
       Wlog "You will have to install CP PS Notification Server license later using the rlinstall utility in $PWD/util"
    else
#       chmod a+x ./util/rlinstall
        echo ./util/rlinstall -i -p 1006 -d $PS_INSTALL/cp/WEB-INF/etc
        ./util/rlinstall -i -p 1006 -d $PS_INSTALL/cp/WEB-INF/etc
    
        EStatus=`echo $?`

        if [ $EStatus -eq 1 ]; then
            Wlog "CP PS Notification Server license installation was successful"
        else
            echo "*** CP PS Notification Server license installation failed. You can try later to install license using rlinstall tool"
            Wlog "CP PS Notification Server license installation failed"
        fi
    fi
    echo ""
}

post_install()
{
    echo ""
    echo "************************************************************************"
    echo "    Post installation"
    echo "************************************************************************"
    echo ""
    echo "Tomcat must be restarted to take NS in account"
    RESP=
    if test "$OS" = "SPARC"; then
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            RESP=`ckstr -W 80 -p "Do you want to restart Tomcat? [y/n] "` || exit 1
        done
    else
        while [ "x$RESP" != "xy" -a "x$RESP" != "xn" ]; do
            echo "Do you want to restart Tomcat? [y/n] "
            read RESP || exit 1 
        done
    fi

    if [ "x$RESP" = "xn" ]; then
       echo "You will have to restart Tomcat later to gain access to CP PS Notification Server"
    else
        echo "Stopping Tomcat..."
        $INSTALLDIR/bin/shutdown.sh

        echo "Starting Tomcat..."
        $INSTALLDIR/bin/startup.sh
    fi
}

trap "exit 1" INT

case $1 in
'standalone'|'-standalone')

    CheckUserId
          
    GetCDLOC

    rm -f /tmp/psinstall.log
    echo "************************************************************************"
    echo "    CP Presentation Server $PRODUCTVERSION                              "
    echo "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    echo "************************************************************************"
    echo "                                                                        "

    Wlog "************************************************************************"
    Wlog "    CP Presentation Server $PRODUCTVERSION                              "
    Wlog "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    Wlog "*********************************************************************** "

    requirement_check_standalone
    sys_check

    GetInstallDir

    CURDIR=`pwd`

    ps_install
    
    ps_extract
   
    echo ""
    echo "************************************************************************"
    echo "    CP PS Notification Server $NSVERSION                                "
    echo "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    echo "************************************************************************"
    echo "                                                                        "

    Wlog "************************************************************************"
    Wlog "    CP PS Notification Server $NSVERSION                                "
    Wlog "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    Wlog "*********************************************************************** "
    
    cd $CURDIR
    
    ns_install
    
    ns_extract
    
    ns_install_asset_standalone

    ns_install_help_standalone

    ns_patch_standalone

    echo ""
    echo "************************************************************************"
    echo "    Licenses installation    "
    echo "************************************************************************"
    echo "                                                                        "

    Wlog "************************************************************************"
    Wlog "    Licenses installation    "
    Wlog "************************************************************************"
    Wlog "                                                                        "

    cd $CURDIR

    install_ps_license

    install_ns_license

    post_install

    Wlog "**********************************************************************"
    Wlog "    Installation Completed                                            "
    Wlog "**********************************************************************"

    echo ""
    echo "**********************************************************************"
    echo "    Installation Completed                                            "
    echo "**********************************************************************"
    echo ""

    ;;

'integrated'|'-integrated')

    CheckUserId
          
    GetCDLOC

    rm -f /tmp/psinstall.log
    echo "************************************************************************"
    echo "    CP PS Notification Server $NSVERSION                                "
    echo "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    echo "************************************************************************"
    echo "                                                                        "

    Wlog "************************************************************************"
    Wlog "    CP PS Notification Server $NSVERSION                                "
    Wlog "    Copyright (C) 2001 - 2002 Critical Path Inc.                        "
    Wlog "*********************************************************************** "

    requirement_check_integrated
    sys_check

    GetInstallDir
    
    CURDIR=`pwd`
    PS_INSTALL="$INSTALLDIR/webapps"

    ns_install
    
    ns_extract
    
    ns_install_asset_integrated

    ns_install_help_integrated

    ns_patch_integrated

    echo "************************************************************************"
    echo "    License installation    "
    echo "************************************************************************"
    echo "                                                                        "

    Wlog "************************************************************************"
    Wlog "    License installation    "
    Wlog "************************************************************************"
    Wlog "                                                                        "

    cd $CURDIR

    install_ns_license

    post_install

    Wlog "**********************************************************************"
    Wlog "    Installation Completed                                            "
    Wlog "**********************************************************************"

    echo ""
    echo "**********************************************************************"
    echo "    Installation Completed                                            "
    echo "**********************************************************************"
    echo ""

    ;;

*)
    echo ""
    echo "To install CP PS Notification Server (User Interface) as a standalone application:"
    echo "    ./psinstall.sh standalone"
    echo ""
    echo "To integrate CP PS Notification Server (User Interface) in an existing CP Presentation Server:"
    echo "    ./psinstall.sh integrated"
    echo ""
;;
esac
