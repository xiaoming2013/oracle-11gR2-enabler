#!/bin/sh

binDir=`dirname $0`

. $binDir/setenv.sh


doSetup() 
{
	echo "Creating install directory: ${ORACLE_BASE}"
	/bin/mkdir -p ${ORACLE_BASE}
	
	TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S%p`
	export TIMESTAMP
	
	SCRATCH_DIR=${ORACLE_DIR}/OraInstall-${TIMESTAMP}
	export SCRATCH_DIR
	echo "Creating install scratch directory: ${SCRATCH_DIR}"
	/bin/mkdir ${SCRATCH_DIR}

	ORACLE_JDK_VERSION=`ls ${ORACLE_DIR}/database/stage/Components/oracle.jdk`
 	export ORACLE_JDK_VERSION
 	
 	ORACLE_DB_VERSION=`ls ${ORACLE_DIR}/database/stage/Components/oracle.swd.oui`
	export ORACLE_DB_VERSION
	
	echo "${ORACLE_DIR}/database/install/unzip -q ${ORACLE_DIR}/database/stage/Components/oracle.jdk/${ORACLE_JDK_VERSION}/1/DataFiles/\*.jar -d ${SCRATCH_DIR}"
	${ORACLE_DIR}/database/install/unzip -q ${ORACLE_DIR}/database/stage/Components/oracle.jdk/${ORACLE_JDK_VERSION}/1/DataFiles/\*.jar -d ${SCRATCH_DIR}
	
	echo "${ORACLE_DIR}/database/install/unzip -q ${ORACLE_DIR}/database/stage/Components/oracle.swd.oui/${ORACLE_DB_VERSION}/1/DataFiles/\*.jar -d  ${SCRATCH_DIR}"
	${ORACLE_DIR}/database/install/unzip -q ${ORACLE_DIR}/database/stage/Components/oracle.swd.oui/${ORACLE_DB_VERSION}/1/DataFiles/\*.jar -d  ${SCRATCH_DIR}

	echo "${ORACLE_DIR}/database/install/unzip  -q ${ORACLE_DIR}/database/stage/Components/oracle.swd.oui.core/${ORACLE_DB_VERSION}/1/DataFiles/\*.jar -d ${SCRATCH_DIR}"
	${ORACLE_DIR}/database/install/unzip -q ${ORACLE_DIR}/database/stage/Components/oracle.swd.oui.core/${ORACLE_DB_VERSION}/1/DataFiles/\*.jar -d ${SCRATCH_DIR}
 	
 	echo "cp -r ${ORACLE_DIR}/database/stage/ext  ${SCRATCH_DIR}/"
	cp -r ${ORACLE_DIR}/database/stage/ext  ${SCRATCH_DIR}/
	
	echo "chmod -fR u+x ${SCRATCH_DIR}"
 	chmod -fR u+x ${SCRATCH_DIR}
 	
	if [ "${UNIX_USER_NAME}" != "" ]
	then
		echo "chown -R ${UNIX_USER_NAME} ${ORACLE_DIR}"
		chown -R ${UNIX_USER_NAME} ${ORACLE_DIR}
		
		echo "chgrp -R ${UNIX_GROUP_NAME} ${ORACLE_DIR}"
		chgrp -R ${UNIX_GROUP_NAME} ${ORACLE_DIR}
	fi
}

doSudoInstall()
{
    echo "Sudo Install"
	sudo -u ${UNIX_USER_NAME} ${SCRATCH_DIR}/jdk/jre/bin/java \
		-Doracle.installer.library_loc=${SCRATCH_DIR}/oui/lib/linux \
		-Doracle.installer.oui_loc=${SCRATCH_DIR}/oui \
		-Doracle.installer.bootstrap=TRUE \
		-Doracle.installer.startup_location=${ORACLE_DIR}/database/install \
		-Doracle.installer.jre_loc=${SCRATCH_DIR}/jdk/jre \
		-Doracle.installer.nlsEnabled="TRUE" \
		-Doracle.installer.prereqConfigLoc= \
		-Doracle.installer.unixVersion=2.6.31.5-0.1-desktop \
		-mx256m \
		-cp ${SCRATCH_DIR}:${SCRATCH_DIR}/ext/jlib/OraPrereq.jar:${SCRATCH_DIR}/ext/jlib/instdb.jar:${SCRATCH_DIR}/ext/jlib/orai18n-utility.jar:${SCRATCH_DIR}/ext/jlib/cvu.jar:${SCRATCH_DIR}/ext/jlib/OraPrereqChecks.jar:${SCRATCH_DIR}/ext/jlib/emocmutl.jar:${SCRATCH_DIR}/ext/jlib/ssh.jar:${SCRATCH_DIR}/ext/jlib/instcommon.jar:${SCRATCH_DIR}/ext/jlib/installcommons_1.0.0b.jar:${SCRATCH_DIR}/ext/jlib/remoteinterfaces.jar:${SCRATCH_DIR}/ext/jlib/orai18n-mapping.jar:${SCRATCH_DIR}/ext/jlib/jsch.jar:${SCRATCH_DIR}/ext/jlib/prov_fixup.jar:${SCRATCH_DIR}/oui/jlib/OraInstaller.jar:${SCRATCH_DIR}/oui/jlib/oneclick.jar:${SCRATCH_DIR}/oui/jlib/xmlparserv2.jar:${SCRATCH_DIR}/oui/jlib/share.jar:${SCRATCH_DIR}/oui/jlib/OraInstallerNet.jar:${SCRATCH_DIR}/oui/jlib/emCfg.jar:${SCRATCH_DIR}/oui/jlib/emocmutl.jar:${SCRATCH_DIR}/oui/jlib/OraPrereq.jar:${SCRATCH_DIR}/oui/jlib/jsch.jar:${SCRATCH_DIR}/oui/jlib/ssh.jar:${SCRATCH_DIR}/oui/jlib/remoteinterfaces.jar:${SCRATCH_DIR}/oui/jlib/http_client.jar:${SCRATCH_DIR}/oui/jlib/OraCheckPoint.jar:${SCRATCH_DIR}/oui/jlib/InstImages.jar:${SCRATCH_DIR}/oui/jlib/InstHelp.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_de.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_es.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_fr.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_it.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_ja.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_ko.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_pt_BR.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_zh_CN.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_zh_TW.jar:${SCRATCH_DIR}/oui/jlib/oracle_ice.jar:${SCRATCH_DIR}/oui/jlib/help4.jar:${SCRATCH_DIR}/oui/jlib/help4-nls.jar:${SCRATCH_DIR}/oui/jlib/ewt3.jar:${SCRATCH_DIR}/oui/jlib/ewt3-swingaccess.jar:${SCRATCH_DIR}/oui/jlib/ewt3-nls.jar:${SCRATCH_DIR}/oui/jlib/swingaccess.jar::${SCRATCH_DIR}/oui/jlib/jewt4.jar:${SCRATCH_DIR}/oui/jlib/jewt4-nls.jar:${SCRATCH_DIR}/oui/jlib/orai18n-collation.jar:${SCRATCH_DIR}/oui/jlib/orai18n-mapping.jar:${SCRATCH_DIR}/oui/jlib/ojmisc.jar:${SCRATCH_DIR}/oui/jlib/xml.jar:${SCRATCH_DIR}/oui/jlib/srvm.jar:${SCRATCH_DIR}/oui/jlib/srvmasm.jar \
		oracle.install.ivw.db.driver.DBInstaller \
		-scratchPath ${SCRATCH_DIR} \
		-sourceLoc ${ORACLE_DIR}/database/stage/products.xml \
		-sourceType network \
		-timestamp ${TIMESTAMP} \
		-invPtrLoc ${ORAINST} \
		-ignoreSysPrereqs -silent -responseFile ${DBCA_RESPONSE_FILE}
	
	cd ${ORACLE_HOME}
	if [ "${DB_INSTALL_OPTION}" == "INSTALL_DB_SWONLY" ]
	then
	   #echo "CALLING DBCA MANUALLY WITH RESPONSE FILE: ${DBCA_RESPONSE_FILE}"
	   echo "Creating Database"       
       sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc -sid ${ORACLE_SID} -gdbName ${DB_GLOBAL_NAME} -emConfiguration LOCAL \
       -dbsnmpPassword ${DBSNMP_PWD} -sysmanPassword ${SYSMAN_PWD} \
       -storageType FS -datafileDestination ${DB_DATA_LOC} -datafileJarLocation ${ORACLE_HOME}/assistants/dbca/templates \
       -responseFile ${DBCA_RESPONSE_FILE} -characterset ${DB_CHARACTER_SET}  \
       -automaticMemoryManagement -totalMemory ${DB_MEMORY_LIMIT} \
       -sysPassword ${SYS_PWD} -systemPassword ${SYSTEM_PWD}
	
        echo "Restarting Database with init.ora"
        ${ORACLE_HOME}/bin/sqlplus /nolog <<EOF
        connect sys/${SYS_PWD} as sysdba
        shutdown immediate
        startup PFILE='${ORACLE_DIR}/dbs/init.ora'
        quit
EOF
        echo "Creating and registering listener"
        sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/netca /silent /responsefile ${NETCA_RESPONSE_FILE}		
        sleep 60
        if [ "${CONFIG_DBCONTROL}" == "true" ]
        then
            echo "Reconfiguring dbcontrol"
            sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/emca -deconfig dbcontrol db -repos drop -silent -respFile ${EMCA_RESPONSE_FILE}
            sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/emca -config dbcontrol db -repos create -silent -respFile ${EMCA_RESPONSE_FILE}
        fi	
	else
        echo "Configuring Listener"
        sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/lsnrctl stop LISTENER
        rm ${ORACLE_HOME}/network/admin/listener.ora
        sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/netca /silent /responsefile ${NETCA_RESPONSE_FILE}
        ${ORACLE_HOME}/bin/sqlplus sys/${SYS_PWD} as sysdba <<EOF 
        alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${TCP_PORT}))' scope=both;    
EOF
        sleep 60
        if [ "${CONFIG_DBCONTROL}" == "true" ]
        then            
            echo "Reconfiguring dbcontrol"
            sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/emca -deconfig dbcontrol db -repos drop -silent -respFile ${EMCA_RESPONSE_FILE}
            sudo -u ${UNIX_USER_NAME} ${ORACLE_HOME}/bin/emca -config dbcontrol db -repos create -silent -respFile ${EMCA_RESPONSE_FILE}
        fi
	fi	
}

doUserInstall()
{
    echo "User Install"
	${SCRATCH_DIR}/jdk/jre/bin/java \
		-Doracle.installer.library_loc=${SCRATCH_DIR}/oui/lib/linux \
		-Doracle.installer.oui_loc=${SCRATCH_DIR}/oui \
		-Doracle.installer.bootstrap=TRUE \
		-Doracle.installer.startup_location=${ORACLE_DIR}/database/install \
		-Doracle.installer.jre_loc=${SCRATCH_DIR}/jdk/jre \
		-Doracle.installer.nlsEnabled="TRUE" \
		-Doracle.installer.prereqConfigLoc= \
		-Doracle.installer.unixVersion=2.6.31.5-0.1-desktop \
		-mx256m -cp \
		${SCRATCH_DIR}:${SCRATCH_DIR}/ext/jlib/OraPrereq.jar:${SCRATCH_DIR}/ext/jlib/instdb.jar:${SCRATCH_DIR}/ext/jlib/orai18n-utility.jar:${SCRATCH_DIR}/ext/jlib/cvu.jar:${SCRATCH_DIR}/ext/jlib/OraPrereqChecks.jar:${SCRATCH_DIR}/ext/jlib/emocmutl.jar:${SCRATCH_DIR}/ext/jlib/ssh.jar:${SCRATCH_DIR}/ext/jlib/instcommon.jar:${SCRATCH_DIR}/ext/jlib/installcommons_1.0.0b.jar:${SCRATCH_DIR}/ext/jlib/remoteinterfaces.jar:${SCRATCH_DIR}/ext/jlib/orai18n-mapping.jar:${SCRATCH_DIR}/ext/jlib/jsch.jar:${SCRATCH_DIR}/ext/jlib/prov_fixup.jar:${SCRATCH_DIR}/oui/jlib/OraInstaller.jar:${SCRATCH_DIR}/oui/jlib/oneclick.jar:${SCRATCH_DIR}/oui/jlib/xmlparserv2.jar:${SCRATCH_DIR}/oui/jlib/share.jar:${SCRATCH_DIR}/oui/jlib/OraInstallerNet.jar:${SCRATCH_DIR}/oui/jlib/emCfg.jar:${SCRATCH_DIR}/oui/jlib/emocmutl.jar:${SCRATCH_DIR}/oui/jlib/OraPrereq.jar:${SCRATCH_DIR}/oui/jlib/jsch.jar:${SCRATCH_DIR}/oui/jlib/ssh.jar:${SCRATCH_DIR}/oui/jlib/remoteinterfaces.jar:${SCRATCH_DIR}/oui/jlib/http_client.jar:${SCRATCH_DIR}/oui/jlib/OraCheckPoint.jar:${SCRATCH_DIR}/oui/jlib/InstImages.jar:${SCRATCH_DIR}/oui/jlib/InstHelp.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_de.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_es.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_fr.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_it.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_ja.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_ko.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_pt_BR.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_zh_CN.jar:${SCRATCH_DIR}/oui/jlib/InstHelp_zh_TW.jar:${SCRATCH_DIR}/oui/jlib/oracle_ice.jar:${SCRATCH_DIR}/oui/jlib/help4.jar:${SCRATCH_DIR}/oui/jlib/help4-nls.jar:${SCRATCH_DIR}/oui/jlib/ewt3.jar:${SCRATCH_DIR}/oui/jlib/ewt3-swingaccess.jar:${SCRATCH_DIR}/oui/jlib/ewt3-nls.jar:${SCRATCH_DIR}/oui/jlib/swingaccess.jar::${SCRATCH_DIR}/oui/jlib/jewt4.jar:${SCRATCH_DIR}/oui/jlib/jewt4-nls.jar:${SCRATCH_DIR}/oui/jlib/orai18n-collation.jar:${SCRATCH_DIR}/oui/jlib/orai18n-mapping.jar:${SCRATCH_DIR}/oui/jlib/ojmisc.jar:${SCRATCH_DIR}/oui/jlib/xml.jar:${SCRATCH_DIR}/oui/jlib/srvm.jar:${SCRATCH_DIR}/oui/jlib/srvmasm.jar \
		oracle.install.ivw.db.driver.DBInstaller \
		-scratchPath ${SCRATCH_DIR} \
		-sourceLoc ${ORACLE_DIR}/database/stage/products.xml \
		-sourceType network \
		-timestamp ${TIMESTAMP} \
		-invPtrLoc ${ORAINST} \
		-ignoreSysPrereqs -silent -responseFile ${DBCA_RESPONSE_FILE} 
			
	cd ${ORACLE_HOME}
	if [ "${DB_INSTALL_OPTION}" == "INSTALL_DB_SWONLY" ]
	then
	   echo "Creating Database"
	   ${ORACLE_HOME}/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc -sid ${ORACLE_SID} -gdbName ${DB_GLOBAL_NAME} -emConfiguration LOCAL \
	   -dbsnmpPassword ${DBSNMP_PWD} -sysmanPassword ${SYSMAN_PWD} \
	   -storageType FS -datafileDestination ${DB_DATA_LOC} -datafileJarLocation ${ORACLE_HOME}/assistants/dbca/templates \
	   -responseFile ${DBCA_RESPONSE_FILE} -characterset ${DB_CHARACTER_SET}  \
	   -automaticMemoryManagement -totalMemory ${DB_MEMORY_LIMIT} \
	   -sysPassword ${SYS_PWD} -systemPassword ${SYSTEM_PWD}
		
		echo "Initializing Database with init.ora"
		${ORACLE_HOME}/bin/sqlplus /nolog <<EOF
        connect sys/${SYS_PWD} as sysdba
        shutdown immediate
        startup PFILE='${ORACLE_DIR}/dbs/init.ora'
        quit
EOF
        echo "Creating and registering listener"
		${ORACLE_HOME}/bin/netca /silent /responsefile ${NETCA_RESPONSE_FILE}
		sleep 60
		if [ "${CONFIG_DBCONTROL}" == "true" ]
		then
			echo "Reconfiguring dbcontrol"
            ${ORACLE_HOME}/bin/emca -deconfig dbcontrol db -repos drop -silent -respFile ${EMCA_RESPONSE_FILE}
            ${ORACLE_HOME}/bin/emca -config dbcontrol db -repos create -silent -respFile ${EMCA_RESPONSE_FILE}
		fi
	else
	    echo "Configuring Listener"
		${ORACLE_HOME}/bin/lsnrctl stop LISTENER
		rm ${ORACLE_HOME}/network/admin/listener.ora
		${ORACLE_HOME}/bin/netca /silent /responsefile ${NETCA_RESPONSE_FILE}
		${ORACLE_HOME}/bin/sqlplus sys/${SYS_PWD} as sysdba <<EOF 
		alter system set local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = ${TCP_PORT}))' scope=both;	
EOF
		sleep 60
		if [ "${CONFIG_DBCONTROL}" == "true" ]
		then			
			echo "Reconfiguring dbcontrol"
			${ORACLE_HOME}/bin/emca -deconfig dbcontrol db -repos drop -silent -respFile ${EMCA_RESPONSE_FILE}
			${ORACLE_HOME}/bin/emca -config dbcontrol db -repos create -silent -respFile ${EMCA_RESPONSE_FILE}
		fi
	fi
}

doMain()
{
	doSetup
	cd ${ORACLE_DIR}/database
	
	if [ "${UNIX_USER_NAME}" != "" ]
	then
		doSudoInstall
	else	
		doUserInstall
	fi
	touch ${ORACLE_DIR}/'.#dsoracle'
}


doMain







