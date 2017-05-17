#########################################################################
# File Name: auto-install.sh
# Author: chaofei
# mail: chaofeibest@163.com
# Created Time: 2016-11-16 13:27:30
#########################################################################
#!/bin/bash

CURRENT_DIR=`pwd`
if [ -f "${CURRENT_DIR}/functions.sh" ]; then
  source "${CURRENT_DIR}/functions.sh" 
fi

init_log
