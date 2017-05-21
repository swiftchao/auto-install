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

function convert_relative_path_to_absolute_path() {
  this="${0}"
  bin=`dirname "${this}"`
  script=`basename "${this}"`
  bin=`cd "${bin}"; pwd`
  this="${bin}/${script}"
}

function usage() {
 echo "Usage: ${this} [-r|--record] [-p|playback] [-u|--user] [-d|-disk] [-a|-all]
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
        if [ -n "${1}" ]; then
          ARGS_RECORD_LOG_FILE="${1}"
          shift
        fi
        if [ -n "${1}" ]; then
          ARGS_RECORD_SESSION_FILE="${1}"
          shift
        fi
        ;;
      -p|-P|--playback|--Playback|--PLAYBACK)
        SOFT_PLAYBACK="true"
        shift
        if [ -f "${1}" ]; then
          ARGS_RECORD_LOG_FILE="${1}"
          shift
        fi
        if [ -f "${1}" ]; then
          ARGS_RECORD_SESSION_FILE="${1}"
          shift
        fi
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
        echo "${this} invalid option [${1}]"
        usage
        exit 1
    esac
  done
}

#############################################TOOLS FUNCTION##################################
function get_current_time() {
  CURRENT_TIME=`date +"%Y-%m-%d %H:%M:%S"`
  echo "${CURRENT_TIME}"
}

function get_current_user() {
  CURRENT_USER=`whoami`
  echo "${CURRENT_USER}"
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

#############################################LOG FUNCTIONS##################################
function generate_default_log_name() {
  if [ -z "${SOFT_NAME}" ]; then
    convert_relative_path_to_absolute_path
    SOFT_NAME="${script}"
  fi
  if [ -z "${LOG_NAME}" ]; then
    LOG_NAME="${SOFT_NAME}"
  fi
  echo "${LOG_NAME}"
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


#############################################RECORD FUNCTIONS##################################
function generate_default_record_name() {
  if [ -z "${SOFT_NAME}" ]; then
    convert_relative_path_to_absolute_path
    SOFT_NAME="${script}"
  fi
  if [ -z "${RECORD_NAME}" ]; then
    RECORD_NAME="${SOFT_NAME}"
  fi
  echo "${RECORD_NAME}"
}

function init_record() {
  if [ -z "${RECORDS_DIR}" ]; then
    RECORDS_DIR="${SOFT_HOME}/records"
  fi
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_NAME=`generate_default_record_name`
  fi
  CURRENT_YMDHMS_TIME=`date +"%Y-%m-%d-%H%M%S"`
  CURRENT_USER=`get_current_user`
  if [ -z "${RECORD_LOG_NAME}" ]; then
    RECORD_LOG_NAME="${RECORD_NAME}"
  fi
  RECORD_LOG_NAME="${RECORD_LOG_NAME}.${CURRENT_USER}.${CURRENT_YMDHMS_TIME}.log"
  if [ -z "${RECORD_SESSION_NAME}" ]; then
    RECORD_SESSION_NAME="${RECORD_NAME}"
  fi
  RECORD_SESSION_NAME="${RECORD_SESSION_NAME}.${CURRENT_USER}.${CURRENT_YMDHMS_TIME}.session"
  create_dir "${RECORDS_DIR}"
  create_file "${RECORDS_DIR}/${RECORD_LOG_NAME}"
  create_file "${RECORDS_DIR}/${RECORD_SESSION_NAME}"
  create_args_ln_file "${RECORDS_DIR}/${RECORD_LOG_NAME}" "${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.log"
  create_args_ln_file "${RECORDS_DIR}/${RECORD_SESSION_NAME}" "${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.session"
  RECORD_LN_LOG_FILE="${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.log"
  RECORD_LN_SESSION_FILE="${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.session"
}

function record_args() {
  if [ -n "${1}" ] && [ -n "${2}" ]; then
    echo "To escape to record, press 'exit'."
    script -t 2>"${1}" "${2}"
  fi
}

function record() {
  if [ "${SOFT_RECORD}" == "true" ]; then
    init_record
    if [ -n "${ARGS_RECORD_LOG_FILE}" ] && [ -n "${ARGS_RECORD_SESSION_FILE}" ]; then
      record_args "${ARGS_RECORD_LOG_FILE}" "${ARGS_RECORD_SESSION_FILE}"
    else
      record_args "${RECORD_LN_LOG_FILE}" "${RECORD_LN_SESSION_FILE}"
    fi
  fi
}

#############################################PLAYBACK FUNCTIONS##################################
function init_playback() {
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
  RECORD_LN_LOG_FILE="${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.log"
  RECORD_LN_SESSION_FILE="${RECORDS_DIR}/${RECORD_NAME}.${CURRENT_USER}.session"
}

function playback_args() {
  if [ -f "${1}" ] && [ -f "${2}" ]; then
    echo "To escape to palyback, press 'ctrl+c'."
    scriptreplay "${1}" "${2}"
  fi
}

function playback() {
  if [ "${SOFT_PLAYBACK}" == "true" ]; then
    init_playback
    if [ -n "${ARGS_RECORD_LOG_FILE}" ] && [ -n "${ARGS_RECORD_SESSION_FILE}" ]; then
      playback_args "${ARGS_RECORD_LOG_FILE}" "${ARGS_RECORD_SESSION_FILE}"
    else
      playback_args "${RECORD_LN_LOG_FILE}" "${RECORD_LN_SESSION_FILE}"
    fi
  fi
}

#############################################USER FUNCTIONS##################################
function generate_default_user_name() {
  if [ -z "${SOFT_NAME}" ]; then
    convert_relative_path_to_absolute_path
    SOFT_NAME="${script}"
  fi
  if [ -z "${USER_NAME}" ]; then
    USER_NAME="${SOFT_NAME}"
  fi
  echo "${USER_NAME}"
}

function init_user() {
  if [ -z "${USER_NAME}" ]; then
    USER_NAME=`generate_default_user_name`
  fi
  if [ -z "${USER_PWD}" ]; then
    USER_PWD="${USER_NAME}"
  fi
  if [ -z "${USER_HOME_DIR}" ]; then
    USER_HOME_DIR="${SOFT_HOME}"
  fi
  USER_HOME_DIR="${USER_HOME_DIR}/${USER_NAME}"
  create_dir "${USER_HOME_DIR}"
}

function is_user_added() {
  if [ -n "${1}" ]; then
    ADDED_USERS=`gawk -F: '{print$1}' /etc/passwd | xargs | sed 's/ /,/g'`
    OLD_IFS="${IFS}"
    IFS=",${now},"
    if [ -n "${ADDED_USERS}" ]; then
      for USER in ${ADDED_USERS}; do
        if [ -n "${USER}" ]; then
          if [ "${USER}" == "${1}" ]; then
            IS_USER_ADDED=0
            break
          fi  
        fi  
      done
    fi  
		IFS="${OLD_IFS}"
  fi
}

function add_user() {
  if [ "${SOFT_USER}" == "true" ]; then
    init_user
    is_user_added "${USER_NAME}"
    if [ -n "${IS_USER_ADDED}" ] && [ "${IS_USER_ADDED}" -eq 0 ]; then
      echo "`get_current_time` User '${USER_NAME}' has already added"
    else
      useradd -d "${USER_HOME_DIR}" -m "${USER_NAME}" >/dev/null 2>&1
      USERADD_RESULT=$?
      if [ "${USERADD_RESULT}" -eq 0 ]; then
        echo -e "`get_current_time` Add user '${USER_NAME}' -- \033[32mOK\033[0m"
      else
        echo -e "`get_current_time` Add user '${USER_NAME}' -- \033[31mERROR\033[0m"
      fi
    fi
    chown -R "${USER_NAME}" "${USER_HOME_DIR}"
    echo "${USER_PWD}" | passwd "${USER_NAME}" --stdin >/dev/null 2>&1
    USER_PWD_RESULT=$?
    if [ "${USER_PWD_RESULT}" -eq 0 ]; then
      echo -e "`get_current_time` Change user '${USER_NAME}' password -- \033[32mOK\033[0m"
    else
      echo -e "`get_current_time` Change user '${USER_NAME}' password -- \033[31mERROR\033[0m"
    fi
  fi
}

#############################################DISK FUNCTIONS##################################
function get_source_disks() {
  SOURCE_DISKS=`fdisk -l | grep "Disk /" | grep "bytes" | awk '{print$2}' \
	  | sed 's|:$||g' | xargs | sed 's| |,|g'`
}

function get_mounted_disks() {
  MOUNTED_DISKS=`df -h | awk '{print$1}' \
	  | grep -v "\([0-9]\)\{1,3\}.\([0-9]\)\{1,3\}.\([0-9]\)\{1,3\}.\([0-9]\)\{1,3\}" \
		| grep -v "^Filesystem$" | grep -v "^tmpfs$" | grep -v "^udev$" \
		| xargs | sed 's| |,|g'`
}

function get_lvm_swap_disks() {
  LVM_AND_SWAP_DISKS=`blkid | grep -E "TYPE=\"swap\"|TYPE=\"LVM2_member\"" \
	  | awk '{print$1}' | sed 's|:||g' | xargs | sed 's| |,|g'`
}

function init_disks() {
  get_source_disks
	get_mounted_disks
	get_lvm_swap_disks  
}

function remove_tail_number() {
  if [ -n "${1}" ]; then
		echo "${1}" | sed 's|\([0-9]\+\)$||g' 
  fi
}

function mount_disks() {
  if [ "${SOFT_DISK}" == "true" ]; then
		init_disks
		if [ -n "${SOURCE_DISKS}" ]; then
      OLD_IFS="${IFS}"
			IFS=",${now},"
			for SOURCE_DISK in ${SOURCE_DISKS}; do
				IS_SOURCE_DISK_MOUNTED="false"
				IS_LVM_OR_SWAP_DISK="false"
				if [ -b "${SOURCE_DISK}" ]; then
					if [ -n "${MOUNTED_DISKS}" ]; then
					  for MOUNTED_DISK in ${MOUNTED_DISKS}; do
							if [ -b "${MOUNTED_DISK}" ]; then
								if [ "${SOURCE_DISK}" == "${MOUNTED_DISK}" ]; then
				          IS_SOURCE_DISK_MOUNTED="true"
								else 
				          MOUNTED_DISK_NO_TAIL_NUMBER=`remove_tail_number "${MOUNTED_DISK}"`
									if [ "${SOURCE_DISK}" == "${MOUNTED_DISK_NO_TAIL_NUMBER}" ]; then
				            IS_SOURCE_DISK_MOUNTED="true"
									fi
								fi
							fi
					  done
						for LVM_OR_SWAP_DISK in ${LVM_AND_SWAP_DISKS}; do
							if [ -b "${LVM_OR_SWAP_DISK}" ]; then
								if [ "${SOURCE_DISK}" == "${LVM_OR_SWAP_DISK}" ]; then
									IS_SOURCE_DISK_LVM_OR_SWAP="true"
								else
				          LVM_OR_SWAP_DISK_NO_TAIL_NUMBER=`remove_tail_number "${LVM_OR_SWAP_DISK}"`
									if [ "${SOURCE_DISK}" == "${LVM_OR_SWAP_DISK_NO_TAIL_NUMBER}" ]; then
									  IS_SOURCE_DISK_LVM_OR_SWAP="true"
									fi
								fi
							fi
						done
				  fi
				fi
				if [ "${IS_SOURCE_DISK_MOUNTED}" == "true" ]; then
					echo -e "`get_current_time` Disk:[\033[32m${SOURCE_DISK}\033[0m] has already mounted -- \033[32mOK\033[0m"
				else
					if [ "${IS_SOURCE_DISK_LVM_OR_SWAP}" == "false" ]; then
					  echo -e "`get_current_time` Disk:[\033[31m${SOURCE_DISK}\033[0m] has not mount -- \033[32mOK\033[0m"
				  fi
				fi
			done
			IFS="${OLD_IFS}"
		fi
  fi
}

#############################################MAIN ENTRANCE##################################
function action() {
  record
  playback
  add_user
	mount_disks
}

