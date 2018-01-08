#!/bin/bash
# version 1.0

MCP_PORT="3500"
EXPIRED_TIME="20"

PATH="/usr/local/cvex_mcp_capturer"
TMP_PID_FILE="$PATH/tmp/pid"
TMP_PACKAGE_FILENAME="$PATH/tmp/filename"

function kill_last_tcpdump
{
	if [ ! -f $TMP_PID_FILE ]; then
		return
	fi
	running_pid=`/bin/cat $TMP_PID_FILE`
	if [ "$running_pid"x != ""x ]; then
		/bin/kill -9 $running_pid
	fi
}

function notify_analyzer
{
	if [ ! -f $TMP_PACKAGE_FILENAME ]; then
		return
	fi
	filename=`/bin/cat $TMP_PACKAGE_FILENAME`
	if [ "$filename"x != ""x ]; then
		notify="$PATH/bin/notify_analyzer"
		$notify $ANALYZER_IP $ANALYZER_PORT $filename
	fi
}

function start_next_tcpdump
{
	cur_time=`/bin/date "+%Y%m%d_%H%M%S"`
	file_name="$PATH/packages/mcp_$cur_time.cap"
	/usr/sbin/tcpdump -i eth1 ip src $CVEX_ETH1_IP and udp port $MCP_PORT -w $file_name &
	pid=$!

	# record pid and filename
	if [ $? -eq 0 ]; then
		echo $pid > $TMP_PID_FILE
		echo $file_name > $TMP_PACKAGE_FILENAME
	else
		/bin/rm -f $TMP_PID_FILE
		/bin/rm -f $TMP_PACKAGE_FILENAME
	fi
}

function delete_expired_packages
{
	packages_dir="$PATH/packages/"
	/usr/bin/find $packages_dir -name "*.cap" -mmin +$EXPIRED_TIME | /usr/bin/xargs /bin/rm -f
}


# script starts here

if [ $# -lt 1 ]; then
 	echo -e "USAGE:\n    (1) $0 [CVEX_ETH1_IP] [ANALYZER_IP] [ANALYZER_PORT]\n    (2) $0 stop"
	exit
elif [ "$1"x == "stop"x ]; then
	kill_last_tcpdump
	/bin/rm -f $TMP_PID_FILE
	/bin/rm -f $TMP_PACKAGE_FILENAME
	exit
elif [ $# -gt 2 ]; then
	declare -x CVEX_ETH1_IP=$1
	declare -x ANALYZER_IP=$2
	declare -x ANALYZER_PORT=$3
else
	exit
fi

kill_last_tcpdump

delete_expired_packages

notify_analyzer

start_next_tcpdump


