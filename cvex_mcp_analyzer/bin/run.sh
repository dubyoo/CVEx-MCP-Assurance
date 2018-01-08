#!/bin/bash
# version 1.0

#/usr/local/cvex_mcp_analyzer/bin/run [CVEx_IP] [CVEx_FILE_PATH]

CVEx_IP=$1
CVEx_FILE_PATH=$2
PATH="/usr/local/cvex_mcp_analyzer"

mycopy="$PATH/bin/expect_scp"
analyze="$PATH/bin/analyze.sh"

package_path="$PATH/packages/$CVEx_IP"

/bin/mkdir -p $package_path

$mycopy $CVEx_IP root bigband $CVEx_FILE_PATH $package_path/mcp.cap

if [ $? -eq 0 ]; then
	$analyze $package_path mcp.cap 
fi


