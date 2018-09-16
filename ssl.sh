#!/bin/bash
# ==================== sslocal-tool ==================== 

# Absolute path this script is in
readonly BASE_PATH=$(dirname $(readlink -f "$0"))
# available server names
readonly SERVER_NAMES=( $(ls -l $BASE_PATH | awk '{print $9}'| grep .json | cut -d "." -f1) )

# param - $1: element; $2: array
# return - 0: contains; 1: not contains
containsElement() {
    local e match=$1
    shift
    for e in "$@"
    do
        if [[ "$e" == "$match" ]]
        then
            return 0
        fi
    done
    return 1;
}

# return - 0: running; 1: not running
isSslocalRunning() {
    result=`ps -ef | grep sslocal | grep start | grep -v grep`
    return $?
}

# return - 0: is integer; 1: is not integer
isInteger() {
    if [[ -z ${1//[0-9]/} ]];
    then
        return 0
    fi
    return 1
}

getRunningServerName() {
	echo `ps -ef | grep sslocal | grep start | grep -v grep | awk '{print $11}' | cut -d '/' -f 5 | cut -d "." -f 1`
}

run() {
	local serverName=$1
	containsElement "$serverName" "${SERVER_NAMES[@]}"
	if [[ "$?" == "1" ]]
	then 
		echo "!!!!! no such server, start fail"
		exit 1 	
	fi
	isSslocalRunning
	if [[ "$?" == "0" ]]
	then
		echo "-- sslocal already run --"
		sudo sslocal -c $BASE_PATH/$(getRunningServerName).json -d stop
	fi
	sudo sslocal -c $BASE_PATH/$serverName.json -d start
}

stop() {
	isSslocalRunning
    if [[ "$?" == "0" ]]
    then
		sudo sslocal -c $BASE_PATH/$(getRunningServerName).json -d stop
		echo "-- sslocal stop --"
	else 
		echo "-- no sslocal run --"
    fi		
}

status() {
	isSslocalRunning
	if [ "$?" == "0" ]
    then
		echo "-- $(getRunningServerName)server running --"
	else 
        echo "-- no sslocal run --"
    fi
}

test() {
	local pingCount=4
	[[ -n "$1" ]] && pingCount="$1"
	isInteger $pingCount
	if [[ "$?" == "1" ]]
	then
		echo "!!!!! ssl: error argument, please input integer ping count"
        exit 1
	fi
	echo -e "total ECHO_REQUEST packets count=$pingCount"
	echo
	local tmpFilePathTemplate='/tmp/${serverName}-sstest.txt'
	local serverName
	for serverName in ${SERVER_NAMES[@]}
	do
		ping -c $pingCount "${serverName}server" > $(eval "echo $tmpFilePathTemplate") &
	done
	wait

	for serverName in ${SERVER_NAMES[@]}
	do
		local tmpFilePath=$(eval "echo $tmpFilePathTemplate")
		echo "--- ${serverName}server ping statistics ---"
		printf "%-20s %-s\n" "packet loss: `cat $tmpFilePath | grep packet | awk '{print $6}'`" "rtt avg: `cat $tmpFilePath | grep rtt | awk '{print $4}' | cut -d "/" -f 2` ms"
		echo
	done
}

list() {
	echo "available servers:"
	local runningServerName=$(getRunningServerName)
	local serverName
	for serverName in ${SERVER_NAMES[@]}
	do
		local suffix=""
		[[ "$runningServerName" == "$serverName" ]] && suffix="(running)"
		echo -e "\t$serverName $suffix"
	done
}

help() {
	local formatString="  %-20s %-s\n"
	echo "Usage: ssl [list] [status] [run {serverName}] [test [count]] [stop] [help]" 
	echo 
	echo "sslocal-tool: sslocal management tool"
	echo
	echo "optional arguments:"
	printf "$formatString" "list" "list all available servers"
	printf "$formatString" "status" "show sslocal status"
	printf "$formatString" "run {serverName}" "use specified config to run sslocal"
	printf "$formatString" "test [count]" "show servers' packet loss percentage and rtt avg"
	printf "$formatString" "" "count: the count of ECHO_REQUEST packets; default value is 4"
	printf "$formatString" "stop" "stop sslocal"
	printf "$formatString" "help" "print this help message"
	echo 
	echo "See https://github.com/codethereforam/sslocal-tool for more details"
}

command=$1
case $command in 
	run)
		run $2
		;;
	stop) 
		stop
		;;
	status)
		status
		;;
	"")
		help
		;;
	test)
		test $2
		;;
	list)
		list
		;;
	help)
		help
		;;
	*)
		echo "!!!!! ssl: option '$command' not recognised."
		exit 1
		;;
esac
