#!/bin/bash

SCRIPT_PATH="/usr/local/cvex_mcp_analyzer"
SCRIPT_FILENAME="cvex_mcp_capture_listener"

function deploy_files()
{
	mkdir -p $SCRIPT_PATH
	mkdir -p $SCRIPT_PATH/packages
	mkdir -p $SCRIPT_PATH/log
	cp -rf bin $SCRIPT_PATH
	chmod 0755 $SCRIPT_PATH/bin/*
}

function kill_listener_program
{
	listener_pid=`ps -ef | grep "cvex_mcp_capture_listener" | grep -v "grep" | awk '{print $2}'`
	if [ "$listener_pid"x != ""x ]; then
		kill -9 $listener_pid
	fi
}

# Script starts here
if [ $# -lt 1 ]; then
	echo -e "[USAGE]\n\t(1) $0 [port]\n\t(2) $0 status\n\t(3) $0 uninstall"; exit
elif [ "$1"x = "uninstall"x ]; then
	kill_listener_program
	echo "stop analyze mcp successfully"
	rm -rf $SCRIPT_PATH
	if [ $? -eq 0 ]; then echo "remove '$SCRIPT_PATH' successfully"; fi
	exit
elif [ "$1"x = "status"x ]; then
	ps -ef | grep "cvex_mcp_capture_listener" | grep -v "grep"
	exit
else
	declare -x LISTENING_PORT=$1
fi


deploy_files
kill_listener_program
$SCRIPT_PATH/bin/$SCRIPT_FILENAME $LISTENING_PORT


