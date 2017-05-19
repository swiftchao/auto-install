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

function get_current_time() {
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
  echo "${LOG_NAME}" | sed 's/^.//g' | sed 's|/||g'
}

function generate_default_record_name() {
  if [ -z "${SOFT_NAME}" ]; then
    SOFT_NAME="${0}"
  fi
  if [ -z "${RECORD_NAME}" ]; then
    RECORD_NAME="${SOFT_NAME}"
  fi
  echo "${RECORD_NAME}" | sed 's/^.//g' | sed 's|/||g'
}

function generate_default_user_name() {
  if [ -z "${SOFT_NAME}" ]; then
    SOFT_NAME="${0}"
  fi
  if [ -z "${USER_NAME}" ]; then
    USER_NAME="${SOFT_NAME}"
  fi
  echo "${USER_NAME}" | sed 's/^.//g' | sed 's|/||g'
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
  if [ -z "${LOG_INFO_NAME}" ]; then
    LOG_INFO_NAME="${LOG_NAME}"
  fi
  LOG_INFO_NAME="${LOG_INFO_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.INFO"
  if [ -z "${LOG_WARING_NAME}" ]; then
    LOG_WARING_NAME="${LOG_NAME}"
  fi
  LOG_WARING_NAME="${LOG_WARING_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.WARING"
  if [ -z "${LOG_ERROR_NAME}" ]; then
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
  LOG_INFO_FILE="${LOGS_DIR}/${LOG_INFO_NAME}"
  LOG_ERROR_FILE="${LOGS_DIR}/${LOG_ERROR_NAME}"
  LOG_WARING_FILE="${LOGS_DIR}/${LOG_WARING_NAME}"
}

function init_record() {
  if [ -z "${RECORDS_DIR}" ]; then
    RECORDS_DIR="${SOFT_HOME}/records"
  fi
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_NAME=`generate_default_record_name`
  fi
  CURRENT_YMD_TIME=`date +"%Y-%m-%d"`
  CURRENT_USER=`get_current_user`
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_LOG_NAME="${RECORD_NAME}"
  fi
  RECORD_LOG_NAME="${RECORD_LOG_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.log"
  if [ -z "${RECORD_SESSION_NAME}" ]; then
    RECORD_SESSION_NAME="${RECORD_NAME}"
  fi
  RECORD_SESSION_NAME="${RECORD_SESSION_NAME}.${CURRENT_USER}.${CURRENT_YMD_TIME}.session"
  create_dir "${RECORDS_DIR}"
  create_file "${RECORDS_DIR}/${RECORD_LOG_NAME}"
  create_file "${RECORDS_DIR}/${RECORD_SESSION_NAME}"
  create_args_ln_file "${RECORDS_DIR}/${RECORD_LOG_NAME}" "${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.log"
  create_args_ln_file "${RECORDS_DIR}/${RECORD_SESSION_NAME}" "${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.session"
  RECORD_LOG_FILE="${RECORDS_DIR}/${RECORD_LOG_NAME}"
  RECORD_SESSION_FILE="${RECORDS_DIR}/${RECORD_SESSION_NAME}"
}

function prepare_playback() {
  if [ -z "${RECORDS_DIR}" ]; then
    RECORDS_DIR="${SOFT_HOME}/records"
  fi
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_NAME=`generate_default_record_name`
  fi
  CURRENT_USER=`get_current_user`
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_LOG_NAME="${RECORD_NAME}"
  fi
  RECORD_LOG_NAME="${RECORD_LOG_NAME}.${CURRENT_USER}.log"
  if [ -z "${RECORD_SESSION_NAME}" ]; then
    RECORD_SESSION_NAME="${RECORD_NAME}"
  fi
  RECORD_SESSION_NAME="${RECORD_SESSION_NAME}.${CURRENT_USER}.session"
  RECORD_LOG_FILE="${RECORDS_DIR}/${RECORD_LOG_NAME}"
  RECORD_SESSION_FILE="${RECORDS_DIR}/${RECORD_SESSION_NAME}"
}

function usage() {
 echo "Usage: ${0} [-r|--record] [-p|playback] [-u| --user] [-d|-disk] [-a|-all]
 " 
}

function check_args() {
  if [ $# -eq 0 ]; then
    usage
    exit 1
  fi
  while [ $# -gt 0 ]; do 
    case "${1}" in
      -r|-R|--record|--Record|--RECORD)
      SOFT_RECORD="true"
      shift
      ;;
      -p|-P|--playback|--Playback|--PLAYBACK)
      SOFT_PLAYBACK="true"
      shift
      ;;
      -u|-U|--user|--User|--USER)
      SOFT_USER="true"
      shift
      ;;
      -d|-D|--disk|--Disk|--DISK)
      SOFT_DISK="true"
      shift
      ;;
      -a|-A|--all|--All|--ALL)
      SOFT_ALL="true"
      SOFT_USER="true"
      SOFT_DISK="true"
      shift
      ;;
      *)
      echo "${0} invalid option [${1}]"
      usage
      exit 1
    esac
  done
}

function record() {
  if [ "${SOFT_RECORD}" == "true" ]; then
    init_record
    echo "If you want to stop record you can input [exit]"
    script -t 2>"${RECORD_LOG_FILE}" "${RECORD_SESSION_FILE}"
  fi
}

function playback() {
  if [ "${SOFT_PLAYBACK}" == "true" ]; then
    prepare_playback
    if [ -f "${RECORD_LOG_FILE}" ] && [ -f "${RECORD_SESSION_FILE}" ]; then
      echo "If you want to stop playback record before you can press [ctrl+c]"
      scriptreplay "${RECORD_LOG_FILE}" "${RECORD_SESSION_FILE}"
    fi
  fi
}

function get_soft_home() {
  if [ -z "${SOFT_HOME}" ]; then
    CURRENT_DIR=`pwd`
    SOFT_HOME="${CURRENT_DIR}/.."
  fi
  echo "${SOFT_HOME}"
}

function init_user() {
  if [ -z "${USER_NAME}" ]; then
    USER_NAME=`generate_default_user_name`
  fi
  if [ -z "${USER_PWD}" ]; then
    USER_PWD="${USER_NAME}"
  fi
  if [ -z "${USER_HOME_DIR}" ]; then
    USER_HOME_DIR=`get_soft_home`
  fi
  USER_HOME_DIR="${USER_HOME_DIR}/${USER_NAME}"
  create_dir "${USER_HOME_DIR}"
}

function add_user() {
  if [ "${SOFT_USER}" == "true" ]; then
    init_user
    cat /etc/passwd | grep "^${USER_NAME}:" >/dev/null 2>&1
    IS_USER_ADDED=$?
    if [ "${IS_USER_ADDED}" -eq 0 ]; then
      echo "`get_current_time` User ${USER_NAME} has already added"
    else
      useradd -d "${USER_HOME_DIR}" -m "${USER_NAME}" >/dev/null 2>&1
      USERADD_RESULT=$?
      if [ "${USERADD_RESULT}" -eq 0 ]; then
        echo -e "`get_current_time` Add user ${USER_NAME} -- \033[32m OK \033[0m"
      else
        echo -e "`get_current_time` Add user ${USER_NAME} -- \033[31m ERROR \033[0m"
      fi
      echo -e "`get_current_time` User ${USER_NAME} has already added"
    fi
    chown -R "${USER_NAME}" "${USER_HOME_DIR}"
    echo "${USER_PWD}" | passwd "${USER_NAME}" --stdin >/dev/null 2>&1
    USER_PWD_RESULT=$?
    if [ "${USER_PWD_RESULT}" -eq 0 ]; then
      echo -e "`get_current_time` Change user ${USER_NAME} password -- \033[32m OK \033[0m"
    else
      echo -e "`get_current_time` Change user ${USER_NAME} password -- \033[31m ERROR \033[0m"
    fi
  fi
}

function action() {
  record
  playback
  add_user
}
