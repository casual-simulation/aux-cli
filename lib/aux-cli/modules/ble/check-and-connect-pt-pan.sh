#!/bin/sh

BT_MAC_ADDR="$1"

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)

/sbin/ifconfig bnep0 > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
	echo "Connecting to $BT_MAC_ADDR"
	sudo python $SCRIPTPATH/bt-pan client -r  $BT_MAC_ADDR
fi