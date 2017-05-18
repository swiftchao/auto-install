#########################################################################
# File Name: functions.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2016-11-16 13:25:51
#########################################################################
#!/bin/bash
set -e

if [ "${DEBUG}" == "true" ]; then
  set -x
fi

function load_args_config() {
  if [ -f "${1}" ]; then
    source "${1}"
  fi
}

function generate_timestamp() {
  CURRENT_TIME=`date +"%Y-%m-%d %H:%M:%S"`
  echo "${CURRENT_TIME}"
}

function get_current_user() {
  CURRENT_USER=`whoami`
	echo "${CURRENT_USER}"
}

function generate_default_log_name() {
  if [ -z "${SOFT_NAME}" ]; then
    SOFT_NAME="${0}"
  fi
	if [ -z "${LOG_NAME}" ]; then
		LOG_NAME="${SOFT_NAME}"
	fi
  echo "${LOG_NAME}"
}

function create_dir() {
  if [ ! -d "${1}" ]; then
    mkdir -p "${1}"
  fi
}

function create_file() {
  if [ ! -f "${1}" ]; then
    touch "${1}"
  fi
}

function create_args_ln_file() {
  if [ -d "${1}" ] || [ "${1}" ] && [ -n "${2}" ]; then
    if [ -f "${2}" ]; then
      rm -f "${2}"
    fi
    ln -s "${1}" "${2}"
  fi
}

function init_log() {
  if [ -z "${LOGS_DIR}" ]; then
    LOGS_DIR="${SOFT_HOME}/logs"
  fi
	if [ -z "${LOG_NAME}" ]; then
    LOG_NAME=`generate_default_log_name`
  fi
  CURRENT_YMD_TIME=`date +"%Y-%m-%d"`
	CURRENT_USER=`get_current_user`
  if [ -z "$LOG_INFO_NAME" ]; then
    LOG_INFO_NAME="${LOG_NAME}"
  fi
	LOG_INFO_NAME="${LOG_INFO_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.INFO"
  if [ -z "$LOG_WARING_NAME" ]; then
    LOG_WARING_NAME="${LOG_NAME}"
  fi
	LOG_WARING_NAME="${LOG_WARING_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.WARING"
  if [ -z "$LOG_ERROR_NAME" ]; then
    LOG_ERROR_NAME="${LOG_NAME}"
  fi
	LOG_ERROR_NAME="${LOG_ERROR_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.ERROR"
  create_dir "${LOGS_DIR}"
  create_file "${LOGS_DIR}/${LOG_INFO_NAME}"
  create_file "${LOGS_DIR}/${LOG_WARING_NAME}"
  create_file "${LOGS_DIR}/${LOG_ERROR_NAME}"
  create_args_ln_file "${LOGS_DIR}/${LOG_INFO_NAME}" "${LOGS_DIR}/${LOG_NAME}.${CURRENT_USER}.INFO"
  create_args_ln_file "${LOGS_DIR}/${LOG_WARING_NAME}" "${LOGS_DIR}/${LOG_NAME}.${CURRENT_USER}.WARING"
  create_args_ln_file "${LOGS_DIR}/${LOG_ERROR_NAME}" "${LOGS_DIR}/${LOG_NAME}.${CURRENT_USER}.ERROR"
}
