#!/bin/bash
# version 1.0

if [ $# -lt 2 ]; then
	echo "Error parameters"
	echo "usage: $0 [PATH] [FILE_NAME]"
	exit
fi

declare -x INPUT_PATH=$1
declare -x INPUT_FILENAME=$2
declare -x INPUT_FILE="$INPUT_PATH/$INPUT_FILENAME"

PATH="/usr/local/cvex_mcp_analyzer"
PARSER="$PATH/bin/bmcp"
LOG_FILE="$PATH/log/error.log"


ports=`/usr/sbin/tcpdump -r $INPUT_FILE | /bin/awk '{print $5}' | /bin/awk -F . '{print $5}' | /bin/awk -F : '{print $1}'`

#echo $ports

declare -x PORT_LIST=()

index=0
for port in $ports
do
	index=$[$index+1]
	#echo "Checking No. $index port $port"
	if [ $index -gt 5000 ]; then break; fi
        case $port in
                [0-9]*)
                        exists=0; idx=0
                        for pt in ${PORT_LIST[@]}
                        do
			#echo "Checking ($port) and ($pt) ..."
				if [ $idx -eq 0 ]; then
					idx=1; continue
				fi
                                if [ "$pt"x = "$port"x ]; then
                                        exists=1
					#echo "$pt and $port exists!!! $exists"
					break
                                fi  
                        done
                            
                        if [ $exists -eq 0 ]; then
				#echo "Append $port"
                               	PORT_LIST[${#PORT_LIST[@]}]=$port
                               	#echo ${PORT_LIST[@]}
                        fi  
                ;;  
                *)  
                ;;  
        esac
done

current_time=`/bin/date "+%Y-%m-%d %H:%M:%S"`
#echo "$current_time port: ${PORT_LIST[@]}" >> $LOG_FILE

for port in ${PORT_LIST[@]}
do
	cap_file="$INPUT_PATH/$port.cap"
	#echo "$current_time /usr/sbin/tcpdump -r $INPUT_FILE udp dst port $port -w $cap_file " >> $LOG_FILE
	/usr/sbin/tcpdump -r $INPUT_FILE udp dst port $port -w $cap_file
done

for port in ${PORT_LIST[@]}
do
	cap_file="$INPUT_PATH/$port.cap"
	$PARSER $cap_file 1
	if [ $? -eq 100 ]; then
		current_time=`/bin/date "+%Y-%m-%d %H:%M:%S"`
		echo "$current_time broken mcp package: $cap_file" >> $LOG_FILE
	fi
done



