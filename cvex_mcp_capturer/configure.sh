#!/bin/bash

CONFIG_FILENAME="config.ini"
CRONTAB_PATH="/etc/cron.d"
CRONJOB_FILENAME="capture-mcp-cronjob"
SCRIPT_PATH="/usr/local/cvex_mcp_capturer"
SCRIPT_FILENAME="bin/capture_mcp.sh"

function get_config()
{
        CONF_FILE=$1; ITEM=$2
        RESULT=`awk -F = '$1 ~ /'$ITEM'/ {print $2;exit}' $CONF_FILE`
        echo $RESULT
}

function build_cronjob_file()
{
	CVEX_ETH1_IP=$(get_config $CONFIG_FILENAME "CVEX_ETH1_IP")
	ANALYZER_IP=$(get_config $CONFIG_FILENAME "ANALYZER_IP")
	ANALYZER_PORT=$(get_config $CONFIG_FILENAME "ANALYZER_PORT")
	echo "CVEX_ETH1_IP($CVEX_ETH1_IP) ANALYZER_IP($ANALYZER_IP) ANALYZER_PORT($ANALYZER_PORT)"
	echo "Script will execute every 5 minutes."

	echo -e "SHELL=/bin/bash\nPATH=/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin:/root/bin\nUSER=root\nLOGNAME=root\nHOME=/root\n\n*/5 * * * *   root $SCRIPT_PATH/$SCRIPT_FILENAME $CVEX_ETH1_IP $ANALYZER_IP $ANALYZER_PORT\n" > $CRONJOB_FILENAME
}

function deploy_files()
{
	mkdir -p $SCRIPT_PATH
	mkdir -p $SCRIPT_PATH/packages
	mkdir -p $SCRIPT_PATH/tmp
	cp -rf bin $SCRIPT_PATH
	chmod 0755 $SCRIPT_PATH/bin/*
	mv $CRONJOB_FILENAME $CRONTAB_PATH -f
	chmod 0644 $CRONTAB_PATH/$CRONJOB_FILENAME
	$SCRIPT_PATH/$SCRIPT_FILENAME $CVEX_ETH1_IP $ANALYZER_IP $ANALYZER_PORT
}

function reload_crond()
{
        service crond status
        if [ $? -eq 0 ]; then
                service crond reload
        else
                service crond start
        fi
}

# Script starts here
if [ "$1"x = "uninstall"x ]; then
	rm -f $CRONTAB_PATH/$CRONJOB_FILENAME
	if [ $? -eq 0 ]; then echo "remove '$CRONTAB_PATH/$CRONJOB_FILENAME' successfully"; fi
	$SCRIPT_PATH/$SCRIPT_FILENAME stop
	if [ $? -eq 0 ]; then echo "stop capture mcp successfully"; fi
	rm -rf $SCRIPT_PATH
	if [ $? -eq 0 ]; then echo "remove '$SCRIPT_PATH' successfully"; fi
	exit
fi

if [ $# -gt 0 ]; then
	echo -e "[USAGE]\n\t(1) $0\n\t(2) $0 uninstall\n"; exit
fi

build_cronjob_file
deploy_files
reload_crond


