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

CURRENT_DIR=`pwd`

function load_args_config() {
  if [ -f "${1}" ]; then
    source "${1}"
  fi
}

load_args_config "${CURRENT_DIR}/../conf/config.conf"

function generate_timestamp() {
  CURRENT_TIME=`date +"%Y-%m-%d %H:%M:%S"`
  echo "${CURRENT_TIME}"
}

function generate_default_log_name() {
  if [ -z "${SOFT_NAME}" ]; then
    SOFT_NAME="${0}"
  fi
  CURRENT_YMD_TIME=`date +"%Y-%m-%d"`
  LOG_NAME="${SOFT_NAME}-${CURRENT_YMD_TIME}"
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
    LOGS_DIR="${CURRENT_DIR}/../logs"
  fi
  if [ -z "${LOG_NAME}" ]; then
    LOG_NAME=`generate_default_log_name`
  fi
  if [ -z "$LOG_INFO_NAME" ]; then
    LOG_INFO_NAME="${LOG_NAME}.INFO"
  fi
  if [ -z "$LOG_WARING_NAME" ]; then
    LOG_WARING_NAME="${LOG_NAME}.WARING"
  fi
  if [ -z "$LOG_ERROR_NAME" ]; then
    LOG_ERROR_NAME="${LOG_NAME}.ERROR"
  fi
  create_dir "${LOGS_DIR}"
  create_file "${LOGS_DIR}/${LOG_INFO_NAME}"
  create_file "${LOGS_DIR}/${LOG_WARING_NAME}"
  create_file "${LOGS_DIR}/${LOG_ERROR_NAME}"
  create_args_ln_file "${LOGS_DIR}/${LOG_INFO_NAME}" "${LOGS_DIR}/${SOFT_NAME}.INFO"
  create_args_ln_file "${LOGS_DIR}/${LOG_WARING_NAME}" "${LOGS_DIR}/${SOFT_NAME}.WARING"
  create_args_ln_file "${LOGS_DIR}/${LOG_ERROR_NAME}" "${LOGS_DIR}/${SOFT_NAME}.ERROR"
}
