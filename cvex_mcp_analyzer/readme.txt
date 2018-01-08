# version 1.0

1. install

	./configure.sh [port]
	
	Configure script will install run scripts. Analyzer will listen in udp port [port].

2. check running status

	./configure.sh status


3. uninstall scripts

	./configure.sh uninstall


These scripts will listen in udp port. 
When CVEx captured a udp package, it will send a udp message to notify analyzer the package file name. 
Then analyzer scripts will acquire the package files by scp.
Analyzer parse these udp packages and print it into "/usr/local/cvex_mcp_analyzer/log" if find bod mcp broken.

