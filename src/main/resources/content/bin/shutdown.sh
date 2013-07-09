#!/bin/sh

binDir=`dirname $0`

. $binDir/setenv.sh


doShutdown()
{
	${ORACLE_HOME}/bin/emctl stop dbconsole
	${ORACLE_HOME}/bin/lsnrctl stop LISTENER_1
	${ORACLE_HOME}/bin/lsnrctl stop LISTENER
	if [ -x ${ORACLE_HOME}/bin/sqlplus ]
	then
		${ORACLE_HOME}/bin/sqlplus /nolog <<EOF
        connect sys/${SYS_PWD} as sysdba
        shutdown immediate
        quit
EOF
	fi
}

doMain()
{
	cd ${ORACLE_HOME}
	doShutdown
}

doMain







