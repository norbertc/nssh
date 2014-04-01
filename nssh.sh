#!/bin/bash
#
# nssh
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
	echo -e "\nwhere SERVERLIST is path to a text file with a list of servers separated by space or new line.\n"
	echo "custom user usage: (default is the user)"
	echo "e.g. SSHUSER=root $0 run \"remote-command\""
	echo -e "     SSHUSER=root $0 cp \"file-to-transfer\" [target-folder|file]\n"
	exit
}

[ -z "$SERVERLIST" ] && SERVERLIST="/etc/nssh-hostnames.txt"
[ ! -s $SERVERLIST ] && echo "$SERVERLIST is empty" && exit
[ ! -f $SERVERLIST ] && echo "$SERVERLIST not found" && exit
[ -z "$2" ] && usage

case "$1" in
run)
	for i in $(cat $SERVERLIST); do
		echo "==> Running \"$2\" on $i"
		[ -z "$SSHUSER" ] && ssh $i "$2" || ssh ${SSHUSER}@${i} "$2"
	done
	;;
cp)
	[ ! -f "$2" ] && echo "error: file \"$2\" not found" && exit
	[ -z "$3" ] && TARGETLOCATION='~' || TARGETLOCATION=$3
	for i in $(cat $SERVERLIST); do
		echo "==> Transferring \"$2\" to ${i}:${TARGETLOCATION}"
		[ -z "$SSHUSER" ] && scp -p "$2" ${i}:$TARGETLOCATION || scp -p "$2" ${SSHUSER}@${i}:$TARGETLOCATION
	done
	;;
*) usage;;
esac
