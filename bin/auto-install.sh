#########################################################################
# File Name: auto-install.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2016-11-16 13:27:30
#########################################################################
#!/bin/bash
set -e
  
function get_soft_home() {
  if [ -z "${SOFT_HOME}" ]; then
    CURRENT_DIR=`pwd`
		SOFT_HOME="${CURRENT_DIR}/.."
  fi
	echo "${SOFT_HOME}"
}

function load_args_file() {
  if [ -f "${1}" ]; then
		rpm -qa | grep dos2unix > /dev/null
		DOS2UNIX_IS_INSTALL=$?
		if [ "${DOS2UNIX_IS_INSTALL}" ]; then
		  dos2unix "${1}" > /dev/null 2>&1
	  fi
    source "${1}"
  fi
}

SOFT_HOME=`get_soft_home`

load_args_file "${SOFT_HOME}/conf/config.conf"
load_args_file "${SOFT_HOME}/bin/functions.sh"

check_args $*
init_log
action

START_TIME=$(date +%s)
echo "`get_current_time` Begin..." >> "${LOG_INFO_FILE}"

END_TIME=$(date +%s)
TOOK_TIME=$((END_TIME-START_TIME))

echo "`get_current_time` Total taken:[$TOOK_TIME] seconds." >> "${LOG_INFO_FILE}"
echo "`get_current_time` End" >> "${LOG_INFO_FILE}"
