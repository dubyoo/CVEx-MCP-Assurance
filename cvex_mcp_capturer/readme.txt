# version 1.0

1. install

	./configure.sh

2. uninstall 

	./configure.sh uninstall


Description:

This script is used for capture bod mcp packages.

After install this script, a crondjob file will be created in "/etc/cron.d/capture-mcp-cronjob".

script will capture mcp packages by tcpdump and notify analyzer server every 5 minutes.

