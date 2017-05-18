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
    source "${1}"
  fi
}

SOFT_HOME=`get_soft_home`

load_args_file "${SOFT_HOME}/conf/config.conf"
load_args_file "${SOFT_HOME}/bin/functions.sh"

init_log

START_TIME=$(date +%s)
echo "`generate_timestamp` Begin..." >> "${LOGS_DIR}/${LOG_INFO_NAME}"

END_TIME=$(date +%s)
TOOK_TIME=$((START_TIME - END_TIME))

echo "`generate_timestamp` Total took:[$TOOK_TIME] seconds." >> "${LOGS_DIR}/${LOG_INFO_NAME}"
echo "`generate_timestamp` End" >> "${LOGS_DIR}/${LOG_INFO_NAME}"
