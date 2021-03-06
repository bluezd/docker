#!/bin/sh
#
# Shell script to build and run simpapp.  It assume TUXDIR has been set, or that 
# Tuxedo has been installed to: ~/tuxHome/tuxedo12.1.3.0.0   If not, invoke 
# this script with a single argument indicating the location of TUXDIR.
#
# Author: Todd Little
#
# Usage: source simpapp_runme.sh [TuxedoDirectory]
#
if [ ! -z "$1" ]
    then
	export TUXDIR=$1
elif [ -z "$TUXDIR" ]
    then
	export TUXDIR=~/tuxHome/tuxedo12.1.3.0.0
fi

# clean up from any previous run
tmshutdown -y &>/dev/null 
rm -Rf simpcl simpserv tuxconfig ubbsimple ULOG.*

# Create environment setup script setenv.sh
export HOSTNAME=`hostname`
export APPDIR=`pwd`

cat >setenv.sh << EndOfFile
source  ${TUXDIR}/tux.env
export HOSTNAME=${HOSTNAME}
export APPDIR=${APPDIR}
export TUXCONFIG=${APPDIR}/tuxconfig
export IPCKEY=112233
EndOfFile
source ./setenv.sh

# Create the Tuxedo configuration file
cat >ubbsimple << EndOfFile
*RESOURCES
IPCKEY		$IPCKEY
DOMAINID	simpapp
MASTER		site1
MAXACCESSERS	50
MAXSERVERS	20
MAXSERVICES	10
MODEL		SHM
LDBAL		Y

*MACHINES
"$HOSTNAME"	LMID=site1
		APPDIR="$APPDIR"
		TUXCONFIG="$APPDIR/tuxconfig"
		TUXDIR="$TUXDIR"

*GROUPS
APPGRP		LMID=site1 GRPNO=1 OPENINFO=NONE

*SERVERS
simpserv	SRVGRP=APPGRP SRVID=1 CLOPT="-A"

*SERVICES
TOUPPER
EndOfFile

# Get the sources if not already in this directory
if [ ! -r simpcl.c ]
    then
	cp $TUXDIR/samples/atmi/simpapp/simpcl.c .
fi
if [ ! -r simpserv.c ]
    then
	cp $TUXDIR/samples/atmi/simpapp/simpserv.c .
fi

# Fix the warning in simpcl.c
if ! grep -q "string.h" simpcl.c;then
	lineNum=`grep -n "stdio.h" simpcl.c | cut -d ":" -f1`
        sed "$lineNum a #include <string.h>" simpcl.c > /tmp/TEMP_SIMPCL
        cat /tmp/TEMP_SIMPCL > simpcl.c
        rm -rf /tmp/TEMP_SIMPCL
fi

# Compile the configuration file and build the client and server
tmloadcf -y ubbsimple
buildclient -o simpcl -f simpcl.c
buildserver -o simpserv -f simpserv.c -s TOUPPER
# Boot up the domain
echo "### Boot up the domain ###"
tmboot -y >& TMBOOT.log
cat TMBOOT.log
# Run the client
echo -e "\n### Run simpcl client ###"
./simpcl "If you see this message, simpapp ran OK"
# Shutdown the domain
echo -e "\n### shutdown the domain ###"
tmshutdown -y >& TMSHUTDOWN.log
cat TMSHUTDOWN.log

echo -e "\n### Sleeping for 1 hour ###"
count=1
while [[ $count -le 7200 ]]; do
        echo -n "."
        ((count++))
        sleep 0.5
done
