#########################################################################
# File Name: functions.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2016-11-16 13:25:51
#########################################################################
#!/bin/bash

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
 echo "Usage: ${this} [-r|--record] [-p|playback] [-u|--user] [-d|-disk] [-j|-jdk] [-a|-all]" 
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
        if [ -n "${1}" ]; then
          ARGS_MOUNT_DISK_PREFIX="${1}"
          shift
        fi
        if [ -n "${1}" ]; then
          ARGS_DISK_FILE_TYPE="${1}"
          shift
        fi
        if [ -n "${1}" ]; then
          ARGS_FORMAT_UNMOUNT_DISK="${1}"
          shift
        fi
        ;;
      -j|-J|--jdk|--Jdk|--JDK)
        SOFT_JDK="true"
        shift
        ;;
      -a|-A|--all|--All|--ALL)
        SOFT_ALL="true"
        SOFT_USER="true"
        SOFT_DISK="true"
    SOFT_JDK="true"
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

function safe_remove() {
  if [ -n "${1}" ]; then
    if [ -d "${1}" ] || [ -f "${1}" ] && [ "${1}" != "/" ]; then
      rm -rf "${1}"
    fi
  fi
}

function backup() {
  if [ -n "${1}" ] && [ -d "${1}" ] || [ -f "${1}" ]; then
    safe_remove "${1}.back"
    cp -r "${1}" "${1}.back"
  fi
}

function extract_args_tar_file() {
  if [ -e "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ]; then
    tar -tvf "${1}" | grep "${3}" > /dev/null
  i=$?
  if [ "${i}" -eq 0 ]; then
    tar -xvf "${1}"-C "${2}" > /dev/null
  else
    create_dir "${2}/${3}"
    tar -xvf "${1}" -C "${2}/${3}" > /dev/null
  fi
  fi
}

#replace old word to new word in file
function replace_args_value_in_file() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -f "${3}" ]; then
    /bin/sed -i "s/${1}/${2}/" "${3}"
  fi
}

#replace old word with path symbol to new word in file
function replace_args_value_with_path_symbol_in_file() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -f "${3}" ]; then
    /bin/sed -i "s|${1}|${2}|" "${3}"
  fi
}

#install soft by rpm file
function install_rpm() {
  RPM_PATH="${1}"
  if [ -e "${RPM_PATH}" ];
    if [ -e "${2}" ]; then
    /bin/rpm -ivh --prefix="${2}" "${RPM_PATH}"
  else
    /bin/rpm -ivh "${RPM_PATH}"
  fi
  fi
}

#get line of the args context in args file
function get_args_context_line_in_args_file() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -f "${2}" ]; then
    /bin/grep -n "${1}" "${2}" | sed 's|:| |' | awk '{print$1}'
  fi
}

function replace_all_line_with_path_symbol_in_file() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -f "${3}" ]; then
    /bin/sed -i "${1}s|.*|${2}|" "${3}"
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

function get_default_disk_value() {
  if [ -z "${MOUNT_DISK_PREFIX}" ]; then
    MOUNT_DISK_PREFIX="/mnt/disk"
  fi
  if [ -z "${FORMAT_UNMOUNT_DISK}" ]; then
    FORMAT_UNMOUNT_DISK="false"
  fi
  if [ -z "${DISK_FILE_TYPE}" ]; then
    DISK_FILE_TYPE="ext3"
  fi
}

function init_fstab_file() {
  FSTAB_FILE="/etc/fstab"
}

function get_setted_disks_in_fstab() {
  init_fstab_file
  SETTED_DISKS_IN_FSTAB=`cat "${FSTAB_FILE}" | awk '{print$1}' | grep "^/" | xargs | sed 's| |,|g'`
}

function set_disk_default_value_in_args() {
  if [ -n "${ARGS_MOUNT_DISK_PREFIX}" ]; then
    MOUNT_DISK_PREFIX="${ARGS_MOUNT_DISK_PREFIX}"
  fi
  if [ -n "${ARGS_DISK_FILE_TYPE}" ]; then
    DISK_FILE_TYPE="${ARGS_DISK_FILE_TYPE}"
  fi
  if [ -n "${ARGS_FORMAT_UNMOUNT_DISK}" ] && [ "${ARGS_FORMAT_UNMOUNT_DISK}" == "true" ]; then
    FORMAT_UNMOUNT_DISK="true"
  fi
}

function init_disks() {
  get_source_disks
  get_mounted_disks
  get_lvm_swap_disks  
  DISK_NUMBER=`get_max_disk_number`
  get_default_disk_value
  get_setted_disks_in_fstab
  set_disk_default_value_in_args
}

function remove_tail_number() {
  if [ -n "${1}" ]; then
    echo "${1}" | sed 's|\([0-9]\+\)$||g' 
  fi
}

function is_args_disk_in_args_disks() {
  IS_ARGS_DISK_IN_ARGS_DISKS="false"
  if [ -n "${2}" ]; then
    for TMP_DISK in ${2}; do
      if [ -b "${TMP_DISK}" ]; then
        if [ "${1}" == "${TMP_DISK}" ]; then
          IS_ARGS_DISK_IN_ARGS_DISKS="true"
          break
        else 
          TMP_DISK_NO_TAIL_NUMBER=`remove_tail_number "${TMP_DISK}"`
          if [ "${1}" == "${TMP_DISK_NO_TAIL_NUMBER}" ]; then
            IS_ARGS_DISK_IN_ARGS_DISKS="true"
            break;
          fi
        fi
      fi
    done
  fi
  echo "${IS_ARGS_DISK_IN_ARGS_DISKS}"
}

function is_mounted_disk() {
  is_args_disk_in_args_disks "${1}" "${MOUNTED_DISKS}"
}

function is_lvm_or_swap_disk() {
  is_args_disk_in_args_disks "${1}" "${LVM_AND_SWAP_DISKS}"
}

function is_setted_disk() {
  is_args_disk_in_args_disks "${1}" "${SETTED_DISKS_IN_FSTAB}"
}

function is_not_system_disk() {
  if [ -n "${1}" ]; then
    echo "${1}" | grep "^/dev/" | grep -v "swap$" | grep -v "da$" > /dev/null 2>&1
    echo "$?"
  fi
}

function get_max_disk_number() {
  MAX_DISK_NUMBER=0
  LAST_DISK_NUMBER=`df -h | awk '{print$6}' | grep "${MOUNT_DISK_PREFIX}" \
    | sed 's|/||g' | sed 's|\([a-z]\+\)||g' | sed 's|\([A-Z]\+\)||g' \
    | grep "\([0-9]\+\)" | sort -r | xargs | awk '{print$1}'`
  if [ -n "${LAST_DISK_NUMBER}" ]; then
    MAX_DISK_NUMBER=${LAST_DISK_NUMBER}
  fi
  echo "${MAX_DISK_NUMBER}"
}

function delete_old_args_disk_in_fstab() {
  if [ -n "${1}" ]; then
    init_fstab_file
    cat "${FSTAB_FILE}" | grep -v "^${1}" >tmpfstab && cat tmpfstab > "${FSTAB_FILE}" && rm -rf tmpfstab
  fi
}

function set_args_disk_in_fstab() {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -n "${4}" ]; then
    init_fstab_file
    backup "${FSTAB_FILE}"
    if [ "${4}" == "true" ]; then
      delete_old_args_disk_in_fstab "${1}"
    fi
    echo "${1}                    ${2}                   ${3}    defaults        0 0" >> ${FSTAB_FILE}
  fi
}

function mount_disks() {
  if [ "${SOFT_DISK}" == "true" ]; then
    init_disks
    if [ -n "${SOURCE_DISKS}" ]; then
      OLD_IFS="${IFS}"
      IFS=",${now},"
      for SOURCE_DISK in ${SOURCE_DISKS}; do
        IS_MOUNTED_DISK="false"
        IS_LVM_OR_SWAP_DISK="false"
        TO_SET_DISK_IN_FSTAB="false"
        if [ -b "${SOURCE_DISK}" ]; then
          IS_MOUNTED_DISK=`is_mounted_disk "${SOURCE_DISK}"`  
          IS_LVM_OR_SWAP_DISK=`is_lvm_or_swap_disk "${SOURCE_DISK}"`
          IS_NOT_SYSTEM_DISK=`is_not_system_disk "${SOURCE_DISK}"`
          IS_SETTED_DISK=`is_setted_disk "${SOURCE_DISK}"`
          if [ "${IS_MOUNTED_DISK}" == "true" ]; then
            echo -e "`get_current_time` Disk:[\033[32m${SOURCE_DISK}\033[0m] has already mounted -- \033[32mOK\033[0m"
          else
            if [ "${IS_LVM_OR_SWAP_DISK}" == "false" ] && [ "${IS_NOT_SYSTEM_DISK}" -eq 0 ]; then
              DISK_NUMBER=$((DISK_NUMBER+1))
              create_dir "${MOUNT_DISK_PREFIX}${DISK_NUMBER}"
              mount "${SOURCE_DISK}" "${MOUNT_DISK_PREFIX}${DISK_NUMBER}" > /dev/null 2>&1
              MOUNT_RESULT=$?
              if [ "${MOUNT_RESULT}" -eq 0 ]; then
                TO_SET_DISK_IN_FSTAB="true"
                echo -e "`get_current_time` Mount disk:[\033[32m${SOURCE_DISK}\033[0m] -- \033[32mOK\033[0m"
              else
                if [ "${FORMAT_UNMOUNT_DISK}" == "true" ]; then
                  echo y | mkfs -t "${DISK_FILE_TYPE}" -L "${MOUNT_DISK_PREFIX}${DISK_NUMBER}" "${SOURCE_DISK}"
                  FORMAT_DISK_RESULT=$?
                  if [ "${FORMAT_DISK_RESULT}" -eq 0 ]; then
                    echo -e "`get_current_time` Format disk:[\033[32m${SOURCE_DISK}\033[0m] -- \033[32mOK\033[0m"
                    mount "${SOURCE_DISK}" "${MOUNT_DISK_PREFIX}${DISK_NUMBER}" > /dev/null 2>&1
                    REMOUNT_DISK_RESULT=$?
                    if [ "${REMOUNT_RESULT}" -eq 0 ]; then
                      TO_SET_DISK_IN_FSTAB="true"
                      echo -e "`get_current_time` Mount disk:[\033[32m${SOURCE_DISK}\033[0m] -- \033[32mOK\033[0m"
                    fi
                  fi
                else
                  echo -e "`get_current_time` Disk:[\033[32m${SOURCE_DISK}\033[0m] has not mounted -- \033[36mWARING\033[0m"
                fi
              fi
            fi
          fi
        fi
        if [ "${TO_SET_DISK_IN_FSTAB}" == "true" ]; then
          set_args_disk_in_fstab "${SOURCE_DISK}" "${MOUNT_DISK_PREFIX}${DISK_NUMBER}" "${DISK_FILE_TYPE}" "${IS_SETTED_DISK}"
        fi
      done
      IFS="${OLD_IFS}"
    fi
  fi
}

#############################################JDK ENTRANCE##################################
#set JAVA_HOME and relevant varibribes in /etc/profile file
function set_java_home() {
  is_context_in_file "/etc/profile"
  "JAVA_HOME" > /dev/null
  IS_IN=$?
  if [ -n "${1}" ]; then
    java_home="${1}/${JAVA_VERSION}"
  #backup /etc/profile
  backup "/etc/profile"
  if [ "${IS_IN}" -ne 0 ]; then
    #not exist
    echo "JAVA_HOME=${java_home}
PATH=\$JAVA_HOME/bin:\$PATH
CLASSPATH=.:\$JAVA_HOME/lib/tools.jar
export JAVA_HOME
export PATH
export CLASSPATH" >> "/etc/profile"
  else
    JAVA_HOME_LINE=`get_args_context_line_in_args_file ^JAVA_HOME "/etc/profile"`
    replace_all_line_with_path_symbol_in_file "${JAVA_HOME_LINE}" "JAVA_HOME=${1}/${JAVA_VERSION}" "/etc/profile"
    echo -e "`get_current_time` reset JAVA_HOME=${1}/${JAVA_VERSION}" >> "${LOG_INFO_FILE}"
  fi
  export JAVA_HOME="${1}/${JAVA_VERSION}"
  load_args_file "/etc/profile"
  fi
}

#extract args jdk tar file
function extract_jdk_tar_file() {
  if [ -n "${1}" ]; then
    extract_args_tar_file "${SOFT_HOME}/thirdparty/software/jdk/${JDK_VERSION}" "${1}" "${JAVA_VERSION}"
  fi
}

function install_jdk_rpm() {
  if [ -n "${1}" ]; then
    install_rpm "${SOFT_HOME}/thirdparty/software/jdk/${JDK_VERSION}" "${1}" >> "${LOG_INFO_FILE}" 2>&1
  fi
}

function install_jdk() {
  if [ "${SOFT_JDK}" == "true" ]; then
    if [ -z "${JAVA_INSTALL_DIR}" ]; then
    JAVA_INSTALL_DIR="/usr/java"
  fi
  create_dir "${JAVA_INSTALL_DIR}"
  #set JAVA_HOME
  set_java_home "${JAVA_INSTALL_DIR}"
  SET_JAVA_HOME_RESULT=$?
  if [ "${SET_JAVA_HOME_RESULT}" -eq 0 ]; then
    echo -e "`get_current_time` set JAVA_HOME=${1}/${JAVA_VERSION} \033[32m OK \033[0m"
    echo -e "`get_current_time` set JAVA_HOME=${1}/${JAVA_VERSION} \033[32m OK \033[0m" >> "${LOG_INFO_FILE}"
  else
    echo -e "`get_current_time` set JAVA_HOME=${1}/${JAVA_VERSION} \033[31m FAILED \033[0m"
    echo -e "`get_current_time` set JAVA_HOME=${1}/${JAVA_VERSION} \033[31m FAILED \033[0m" >> "${LOG_ERROR_FILE}"
  fi
  #install jdk
  echo "${JDK_VERSION}" | grep "rpm$" > /dev/null
  IS_RPM=$?
  if [ "${IS_RPM}" -eq 0 ]; then
    JDK_VERSION_NUMBER=`echo "${JAVA_VERSION}" | /bin/sed 's/^jdk//'`
    /bin/rpm -qa | grep jdk | grep "${JDK_VERSION_NUMBER}" > /dev/null 2>&1
    IS_RPM_INSTALLED=$?
    if [ "${IS_RPM_INSTALLED}" ]; then
      install_jdk_rpm "${JAVA_INSTALL_DIR}"
    else
      extract_jdk_tar_file "${JAVA_INSTALL_DIR}"
    fi
    INSTALL_JAVA_RESULT=$?
    if [ "${INSTALL_JAVA_RESULT}" -eq 0 ]; then
      echo -e "`get_current_time` install jdk ${JDK_VERSION} \033[32m OK \033[0m"
      echo -e "`get_current_time` install jdk ${JDK_VERSION} \033[32m OK \033[0m" >> "${LOG_INFO_FILE}"
    else 
      echo -e "`get_current_time` install jdk ${JDK_VERSION} \033[31m FAILED \033[0m"
      echo -e "`get_current_time` install jdk ${JDK_VERSION} \033[31m FAILED \033[0m" >> "${LOG_ERROR_FILE}"
    fi
  fi
  fi
}

#############################################MAIN ENTRANCE##################################
function action() {
  record
  playback
  add_user
  mount_disks
  install_jdk
}
