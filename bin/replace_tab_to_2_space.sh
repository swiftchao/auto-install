#########################################################################
# File Name: replace_tab_to_args_space.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2017-08-08 04:14:06
#########################################################################
#!/bin/bash

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

function replace_tab_to_2_space() {
  if [ -n "${1}" ]; then 
    sed -i -e "s/\t/  /g" "${1}" 
    if [ -n "${2}" ]; then
      shift
      replace_tab_to_2_space $*
    fi
  else
    usage
  fi
}

function usage() {
 echo "Usage:${this} file
Example:
   ${this} functions.sh
   ${this} *.sh
"
}

convert_relative_path_to_absolute_path
get_soft_home
replace_tab_to_2_space $*
