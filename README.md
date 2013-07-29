[fabrician.org](http://fabrician.org/)
==========================================================================
Oracle Database 11gR2 Enabler Guide
==========================================================================

Introduction
--------------------------------------
A Silver Fabric Enabler allows an external application or application platform, such as a 
J2EE application server to run in a TIBCO Silver Fabric software environment. The Oracle 
Database 11gR2 Enabler for Silver Fabric provides integration between Silver Fabric and the Oracle Database 11gR2. 
The Enabler supports configuration and runtime management of a standalone Oracle Database, Oracle Enterprise Manager and Oracle Network Listener.  

Supported Platforms
--------------------------------------
* Silver Fabric 5
* Linux

Prerequisites
--------------------------------------
The following operating system groups and user are required when you are installing Oracle Database:

* The OSDBA group (dba) - It identifies operating system user accounts that have database administrative privileges (the SYSDBA privilege). 
  The default name for this group is dba. 
* The Oracle Inventory group (oinstall) - This group owns the Oracle inventory, which is a catalog of all Oracle software installed on the system.
* The Oracle software owner user (typically, oracle) - This user owns all of the software installed during the installation. This user must have the Oracle Inventory 
  group as its primary group. It must also have the OSDBA as a secondary group.

Refer to the Oracle Documentation for more information: http://docs.oracle.com/cd/E11882_01/install.112/e24321/pre_install.htm#BABHHEJD

The Silver Fabric engine that will be running the Oracle Database 11gR2 Enabler can either be run as the user created above or as root.  If 
the engine is run as root, the RuntimeContextVariable ${UNIX_USER_NAME} value needs to be set to the user created above. Additionally, the
path to the engine work directory needs to have read and execute priviledges for the user created above.

Installation
--------------------------------------
The Oracle Database 11gR2 Enabler consists of an Enabler Runtime Grid Library and a Distribution Grid 
Library. The Enabler Runtime contains information specific to a Silver Fabric version that is 
used to integrate the Enabler, and the Distribution contains the application server or program 
used for the Enabler. Installation of the Oracle Database 11gR2 Enabler involves copying these Grid 
Libraries to the SF_HOME/webapps/livecluster/deploy/resources/gridlib directory on the Silver Fabric Broker.  

Runtime Grid Library
--------------------------------------
The Enabler Runtime Grid Library is created by building the maven project. The build depends on the SilverFabricSDK jar file that is distributed with TIBCO Silver Fabric. 
The SilverFabricSDK.jar file needs to be referenced in the maven pom.xml or it can be placed in the project root directory.  

The build also depends on the Oracle JDBC Driver (ojdbc6.jar). The ojdbc6.jar needs to be copied to the ${project root directory}/src/main/resources/jars directory.
The ojdbc6.jar can be found at http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html

```bash
mvn package
```

Distribution Grid Library
--------------------------------------
The Distribution Grid Library is created by performing the following steps:
* Download File 1 and File 2 of Oracle Database 11g Release 2 (11.2.0.1.0) for Linux (x86-64 or x86) at 
  http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html.
* Unzip both files to the same directory.
* Create a grid-library.xml file with the below contents and place it alongside the database directory. Operating system is 
  either 'linux' or 'linux64', depending on the files downloaded.
* Create a tar.gz of the contents.

```xml
    <grid-library os="linux64">
        <grid-library-name>oracle-database11gR2-distribution</grid-library-name>
        <grid-library-version>11.2.0.1.0</grid-library-version>
    </grid-library>
```

Feature Summary
--------------------------------------
* **Oracle RAC support** - No
* **Dynamic clustering support** - No         
* **Persistent software product install support** - No        
* **Persistent data support** - Yes

Component Activation
--------------------------------------
Depending on resources and hardware, the value of "Maximum Activation Time" of the component might need to be increased.  If you find that the component is 
timing out during activation, increase the value.

Activations of more than one Oracle component on the same host when the Runtime Context Variable DB_INSTALL_OPTION is set to "INSTALL_DB_AND_CONFIG" are synchronous. 
The value of "Maximum Activation Time" of the component will need to be increased.  Say t represents the time it takes activate one component on a host and n represents
the number of components that are activating on the same host.  Then it will take approximately t*n for all the components to activate.  

Otherwise the activations are asynchronous.

Configuring Database Control increases the time it takes for component activation.  If you would like to reduce activation time and this feature is not necessary, 
set the CONFIG_DBCONTROL Runtime Context Variable to "false".  It is defaulted to "true". 

Statistics
--------------------------------------
Statistics are not tracked.


Runtime Context Variables
--------------------------------------
* **ORACLE_DIR** - Oracle work directory.  
    * Type: Environment
    * Default value: ${ENGINE_WORK_DIR}/oracle
* **ORACLE_MAINT_FILE** - Oracle maintenance file.  
    * Type: Environment
    * Default value: ${ORACLE_DIR}/oracle.mnt 
* **DBCA_RESPONSE_FILE** - DBCA silent install response file.
    * Type: Environment
    * Default value: ${ORACLE_DIR}/database/response/db_install.rsp
* **NETCA_RESPONSE_FILE** - NETCA silent install response file. 
    * Type: Environment
    * Default value: ${ORACLE_DIR}/database/response/netca.rsp    
* **EMCA_RESPONSE_FILE** - EMCA silent install response file. 
    * Type: Environment
    * Default value: ${ORACLE_DIR}/response/emca.rsp
* **CONFIG_DBCONTROL** - Configure Database Control. 
    * Type: Environment
    * Default value: true
* **EMAIL_ADDRESS** - Email address for Enterprise Manager notifications. 
    * Type: String
    * Default value: 
* **MAIL_SERVER_NAME** - SMTP Mail server for EM notifications. 
    * Type: String
    * Default value: 
* **TCP_PORT** - TNS Listener TCP port. 
    * Type: Environment
    * Default value: 1522      
* **TCPS_PORT** - TNS Listener TCPS port. 
    * Type: Environment
    * Default value: 2484    
* **DBCONTROL_HTTP_PORT** - DB Control Https Port. 
    * Type: Environment
    * Default value: 1158  
* **AGENT_PORT** - Management Agent port for Database Control. 
    * Type: Environment
    * Default value: 3938    
* **RMI_PORT** - RMI port for Database Control. 
    * Type: Environment
    * Default value: 5520     
* **JMS_PORT** - JMS port for Database Control. 
    * Type: Environment
    * Default value: 5540
* **DB_INSTALL_OPTION** - INSTALL_DB_SWONLY, INSTALL_DB_AND_CONFIG. 
    * Type: Environment
    * Default value: INSTALL_DB_AND_CONFIG
* **UNIX_GROUP_NAME** - Primary unix group name for Oracle unix user. 
    * Type: Environment
    * Default value: oinstall
* **UNIX_USER_NAME** - Oracle unix user name, if engine is run as root. 
    * Type: Environment
    * Default value:   
* **INVENTORY_LOCATION** - Oracle inventory location. 
    * Type: String
    * Default value:  ${ORACLE_DIR}/app/oraInventory 
* **ORAINST** - Oracle inventory location file. 
    * Type: Environment
    * Default value:  ${ORACLE_DIR}/oraInst.loc
* **SELECTED_LANGUAGES** - Comma spearated list of 2-letter lanaguge codes. 
    * Type: Environment
    * Default value:  en
* **ORACLE_HOME** - Oracle home directory. 
    * Type: Environment
    * Default value:  ${ORACLE_BASE}/product/${container.getDistributionVersion()}/dbhome  
* **ORACLE_BASE** - Oracle base directory. 
    * Type: Environment
    * Default value:  ${ORACLE_DIR}/app/oracle 
* **DB_INSTALL_EDITION** - EE, SE, SEONE, PE. 
    * Type: String
    * Default value:  EE
* **DB_IS_CUSTOM_INSTALL** - Is it a custom install. 
    * Type: String
    * Default value:  true
* **DB_CUSTOM_COMPONENTS** - List of custom components in the form internal-component-name:version. 
    * Type: String
    * Default value: 
* **DB_DBA_GROUP** - DBA group name. 
    * Type: String
    * Default value: dba 
* **DB_TYPE** - GENERAL_PURPOSE,TRANSACTION_PROCESSING, DATAWAREHOUSE. 
    * Type: String
    * Default value:  GENERAL_PURPOSE
* **DB_GLOBAL_NAME** - Global Database name. 
    * Type: Environment
    * Default value:  ${ORACLE_SID}          
* **DB_NAME** - Database name. 
    * Type: Environment
    * Default value:  orcl   
* **ORACLE_SID** - Oracle SID. 
    * Type: Environment
    * Default value:  orcl
* **ORACLE_UNQNAME** - Oracle Unique Name. 
    * Type: Environment
    * Default value:  ${ORACLE_SID}
* **DB_CHARACTER_SET** - Database character set: See Oracle documentation. 
    * Type: String
    * Default value:  AL32UTF8
* **DB_MEMORY_LIMIT** - Database memory limit, at least 256 MB. 
    * Type: Environment
    * Default value:  776  
* **DB_MEMORY_OPTION** - Database memory options. 
    * Type: String
    * Default value:   true                                  
* **DB_EXAMPLE_SCHEMAS** - Install example schemas. 
    * Type: String
    * Default value:   false
* **DB_PASSWORD_ALL** - Password used for SYS, SYSTEM, SYSMAN, DBSNMP if not set. 
    * Type: String
    * Default value:   SuperAdmin01
* **SYS_PWD** - Password for SYS. 
    * Type: String
    * Default value:         
* **SYSTEM_PWD** - Password for SYSTEM. 
    * Type: String
    * Default value:     
* **DBSNMP_PWD** - Password for DBSNMP. 
    * Type: String
    * Default value:  
* **DB_CONTROL_TYPE** - DB_CONTROL, GRID_CONTROL. 
    * Type: String
    * Default value:  DB_CONTROL
* **GRID_CONTROL_URL** - GRID CONTROL Url, if enabled. 
    * Type: String
    * Default value:   
* **ENABLE_EMAIL_ALERTS** - Enable email notification for critical database alerts. 
    * Type: String
    * Default value:   false  
* **EMAIL_ADDRESS** - Email address to send database alerts. 
    * Type: String
    * Default value:  
* **ENABLE_AUTO_BACKUP** - Enable automated backups. 
    * Type: String
    * Default value:   false 
* **AUTO_BACKUP_USER** - OS user for automatic backup, if enabled. 
    * Type: String
    * Default value:     
* **AUTO_BACKUP_PASSWORD** - OS password for automatic backup, if enabled. 
    * Type: String
    * Default value: 
* **DB_STORAGE_TYPE** - FILE_SYSTEM_STORAGE, ASM_STORAGE. 
    * Type: String
    * Default value:   FILE_SYSTEM_STORAGE 
* **DB_DATA_LOC** - Data location. Warning: ORACLE_BASE is deleted on shutdown. 
    * Type: String
    * Default value:  ${ORACLE_BASE}/app/dbdata
* **DB_RECOVERY_LOCATION** - File system storage recovery location. 
    * Type: String
    * Default value:  ${ORACLE_DIR}/app/oraRecovery 
* **ASM_DISK_GROUP** - Automatic Storage Management disk group, if enabled. 
    * Type: String
    * Default value:   
* **ASM_SNMP_PASSWORD** - Automatic Storage Management SNMP password, if enabled. 
    * Type: String
    * Default value:   
* **MYORACLESUPPORT_USERNAME** - My Oracle Support user name. 
    * Type: String
    * Default value:     
* **MYORACLESUPPORT_PASSWORD** - My Oracle Support password. 
    * Type: String
    * Default value:           
* **SECURITY_UPDATES_VIA_MYORACLESUPPORT** - Security updates via my oracle support. 
    * Type: String
    * Default value:  false  
* **DECLINE_SECURITY_UPDATES** - Decline security updates. 
    * Type: String
    * Default value:  true 
* **PROXY_HOST** - Proxy host for security updates, if needed. 
    * Type: String
    * Default value:   
* **PROXY_PORT** - Proxy port for security updates, if needed. 
    * Type: String
    * Default value:    
* **PROXY_USER** - Proxy user name, if needed. 
    * Type: String
    * Default value:              
* **PROXY_PWD** - Proxy password, if needed. 
    * Type: String
    * Default value:                                          
