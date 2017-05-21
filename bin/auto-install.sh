#########################################################################
# File Name: auto-install.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2016-11-16 13:27:30
#########################################################################
#!/bin/bash
set -e

function convert_relative_path_to_absolute_path() {
  this="${0}"
  bin=`dirname "${this}"`
  script=`basename "${this}"`
  bin=`cd "${bin}"; pwd`
  this="${bin}/${script}"
}
  
function get_soft_home() {
  if [ -z "${SOFT_HOME}" ]; then
    export SOFT_HOME=`dirname "${bin}"`
  fi
}

function load_args_file() {
  if [ -f "${1}" ]; then
    rpm -qa | grep dos2unix > /dev/null
    DOS2UNIX_IS_INSTALL=$?
    if [ "${DOS2UNIX_IS_INSTALL}" -eq 0 ]; then
      dos2unix "${1}" > /dev/null 2>&1
    fi
    source "${1}"
  fi
}

convert_relative_path_to_absolute_path
get_soft_home

load_args_file "${SOFT_HOME}/conf/config.conf"
load_args_file "${SOFT_HOME}/bin/functions.sh"

check_args $*
init_log

START_TIME=$(date +%s)
echo "`get_current_time` Begin auto install..." >> "${LOG_INFO_FILE}"

action

END_TIME=$(date +%s)
TAKEN_TIME=$((END_TIME-START_TIME))

echo "`get_current_time` Total taken:[$TAKEN_TIME] seconds."
echo "`get_current_time` Total taken:[$TAKEN_TIME] seconds." >> "${LOG_INFO_FILE}"
echo "`get_current_time` End" >> "${LOG_INFO_FILE}"
