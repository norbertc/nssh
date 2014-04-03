#!/bin/bash
#
# nssh - parallel version (via xargs)
#
# Simple script to execute remote command via ssh on servers listed in $SERVERLIST variable
# Can also transfer files vi scp on servers listed in $SERVERLIST variable
#
# Author: Norbert Copones

usage() {
	echo -e "\nnormal usage:"
	echo "$0 run \"remote-command\" (e.g. $0 run \"uname -a\")"
	echo "$0 cp \"file-to-transfer\" [target-folder|file] (e.g. $0 cp /etc/hosts /etc)"
	echo -e "\ncustom server list usage: (default is /etc/nssh-hostnames.txt)"
	echo "e.g. SERVERLIST=/home/norbert/hostlist.txt $0 run \"remote-command\""
	echo "     SERVERLIST=/home/norbert/hostlist.txt $0 cp \"file-to-transfer\" [target-folder|file]"
	echo -e "\nwhere SERVERLIST is path to a text file with a list of servers separated by new line.\n"
	echo "custom user usage: (default is the user)"
	echo "e.g. SSHUSER=root $0 run \"remote-command\""
	echo -e "     SSHUSER=root $0 cp \"file-to-transfer\" [target-folder|file]\n"
	exit
}

[ -z "$SERVERLIST" ] && SERVERLIST="/etc/nssh-hostnames.txt"
[ ! -s $SERVERLIST ] && echo "$SERVERLIST is empty" && exit
[ ! -f $SERVERLIST ] && echo "$SERVERLIST not found" && exit
[ -z "$2" ] && usage

NPROC=$( nproc --all )

case "$1" in
run)
	if [ -z "$SSHUSER" ]; then
		CMD="printf \"==> Running \'$2\' on TARGETHOST\t\$(ssh TARGETHOST \"$2\" 2>&1)\n\";"
	else
		CMD="printf \"==> Running \'$2\' on TARGETHOST\t\$(ssh $SSHUSER@TARGETHOST \"$2\" 2>&1)\n\";"
	fi
	xargs -a $SERVERLIST -P${NPROC} -ITARGETHOST -n1 /bin/sh -c "${CMD}"
	;;
cp)
	[ ! -f "$2" ] && echo "error: file \"$2\" not found" && exit
	[ -z "$3" ] && TARGETLOCATION='~' || TARGETLOCATION=$3
	if [ -z "$SSHUSER" ]; then
		CMD="printf \"==> Transferring \'$2\' to TARGETHOST:$TARGETLOCATION\t\$(scp -p \"$2\" TARGETHOST:$TARGETLOCATION 2>&1)\n\";"
	else
		CMD="printf \"==> Transferring \'$2\' to TARGETHOST:$TARGETLOCATION\t\$(scp -p \"$2\" $SSHUSER@TARGETHOST:$TARGETLOCATION 2>&1)\n\";"
	fi
	xargs -a $SERVERLIST -P${NPROC} -ITARGETHOST -n1 /bin/sh -c "${CMD}"
	;;
*) usage;;
esac
