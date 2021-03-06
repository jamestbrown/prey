#!/bin/bash
####################################################################
# Prey - by Tomas Pollak (bootlog.org)
# URL: http://preyproject.com
# License: GPLv3
####################################################################

PATH=/bin:$PATH
version='0.3.3'
base_path=`dirname $0`
start_time=`date +"%F %T"`
os=`uname | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"`

if [ $os == "windowsnt" ]; then
	os=windows
else
	PATH=/usr/bin:/bin:/usr/sbin:/sbin
fi

####################################################################
# base files inclusion
####################################################################

. $base_path/config
if [ ! -e "lang/$lang" ]; then # fallback to english in case the lang is missing
	lang='en'
fi
. $base_path/lang/$lang
. $base_path/platform/base
. $base_path/platform/$os

echo -e "\E[36m$STRING_START ### `date`\E[0m\n"

if [ "$1" == "-t" ]; then
	echo -e "\033[1m -- TEST MODE ENABLED. WON'T CHECK URL OR SEND DATA!\033[0m\n"
	. $base_path/config.test 2> /dev/null
	test_mode=1
	check_url=''
fi

####################################################################
# lets check if we're actually connected
# if we're not, lets try to connect to a wifi access point
####################################################################

check_net_status
if [ $connected == 0 ]; then

	if [ "$auto_connect" == "y" ]; then
		echo "$STRING_TRY_TO_CONNECT"
		try_to_connect
	fi

	# ok, lets check again
	check_net_status
	if [ $connected == 0 ]; then
		echo "$STRING_NO_CONNECT_TO_WIFI"
		exit
	fi
fi

####################################################################
# if there's a URL in the config, lets see if it actually exists
# if it doesn't, the program will shut down gracefully
####################################################################

if [ -n "$check_url" ]; then
	echo "$STRING_CHECK_URL"
	check_status

	if [ "$status" == "$missing_status_code" ]; then
		echo -e "$STRING_PROBLEM"
		parse_headers
		process_response
	else
		echo -e "$STRING_NO_PROBLEM"
		exit
	fi
fi

####################################################################
# ok what shall we do then?
# for now lets run every module with an executable run.sh script
####################################################################

echo -e " -- Running active modules..."
run_active_modules

####################################################################
# lets send whatever our modules have gathered
####################################################################

echo -e " -- Sending data..."
post_data
echo -e "$STRING_DONE"

exit 0
