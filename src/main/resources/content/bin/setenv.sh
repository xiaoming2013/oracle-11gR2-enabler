#!/bin/sh

  unset DISPLAY
  unset UNZIP
  export ORACLE_DIR ORACLE_HOME ORACLE_BASE ORACLE_SID
  export DBCA_RESPONSE_FILE UNIX_USER_NAME UNIX_GROUP_NAME
  export EMCA_RESPONSE_FILE NETCA_RESPONSE_FILE
  
  ORACLE_UNQNAME=${ORACLE_SID}
  export ORACLE_UNQNAME
  
  # core dump file size
  ulimit -c ${MAX_CORE_FILE_SIZE_SHELL:-0} 2>/dev/null

  # max number of processes for user
  ulimit -u ${PROCESSES_MAX_SHELL:-16384} 2>/dev/null

  # max number of open files for user
  ulimit -n ${FILE_MAX_SHELL:-65536} 2>/dev/null