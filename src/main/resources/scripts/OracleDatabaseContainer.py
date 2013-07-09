import os
import time
import sys
import os.path

from jarray import array

from java.lang import StringBuilder
from java.lang import Boolean
from java.lang import Long
from java.net import InetAddress

from java.sql import Connection
from java.sql import ResultSet
from java.sql import Statement
from java.sql import SQLException

from  oracle.jdbc.pool import OracleDataSource

from com.datasynapse.fabric.common import RuntimeContextVariable
from com.datasynapse.fabric.util import ContainerUtils
from com.datasynapse.fabric.domain import Options
    
class OracleDatabase:
    def __init__(self, additionalVariables):
        " initialize oracle database"
        
        self.__hostname = "localhost";
        try:
            self.__hostname = InetAddress.getLocalHost().getCanonicalHostName()
        except:
            type, value, traceback = sys.exc_info()
            logger.severe("Hostname error:" + `value`)
        
        additionalVariables.add(RuntimeContextVariable("ORACLE_HOSTNAME", self.__hostname, RuntimeContextVariable.ENVIRONMENT_TYPE))

        dbPassword = getVariableValue("DB_PASSWORD_ALL")
        
        if dbPassword and dbPassword.strip():
            self.__sysPassword = dbPassword
            additionalVariables.add(RuntimeContextVariable("SYS_PWD", dbPassword, RuntimeContextVariable.ENVIRONMENT_TYPE))
            additionalVariables.add(RuntimeContextVariable("DBSNMP_PWD", dbPassword, RuntimeContextVariable.ENVIRONMENT_TYPE));
            additionalVariables.add(RuntimeContextVariable("SYSMAN_PWD", dbPassword, RuntimeContextVariable.ENVIRONMENT_TYPE))
            additionalVariables.add(RuntimeContextVariable("SYSTEM_PWD", dbPassword, RuntimeContextVariable.ENVIRONMENT_TYPE));
        else:
            self.__sysPassword = getVariableValue("SYS_PWD")
            
        dbDataLocation = getVariableValue("DB_DATA_LOC")
        if dbDataLocation and os.path.isdir(dbDataLocation):
            dbName = getVariableValue("DB_NAME")
            
            dbDataDir = os.path.join(dbDataLocation, dbName)
            if os.path.isdir(dbDataDir):
                logger.info("DB Data directory already exists:" + dbDataDir + "; Setting DB_INSTALL_OPTION to INSTALL_DB_SWONLY")
                additionalVariables.add(RuntimeContextVariable( "DB_INSTALL_OPTION", "INSTALL_DB_SWONLY", RuntimeContextVariable.ENVIRONMENT_TYPE))
        

        tcpPort = getVariableValue("TCP_PORT");
        self.__serviceName = getVariableValue("DB_GLOBAL_NAME")

        sb = StringBuilder("jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)")
        sb.append("(HOST=").append(self.__hostname).append(")")
        sb.append("(PORT=").append(tcpPort).append("))")
        sb.append("(CONNECT_DATA=(SERVICE_NAME=").append(self.__serviceName).append(")))")
        
        self.__oracleServiceUrl = sb.toString()
        
        logger.info("Oracle listener service URL:" + self.__oracleServiceUrl)
        
        self.__jdbcUrl = "jdbc:oracle:thin:@" + self.__hostname +":"+ tcpPort + ":" + self.__serviceName
        runtimeContext.addVariable(RuntimeContextVariable("JDBC_URL", self.__jdbcUrl, RuntimeContextVariable.STRING_TYPE, "Oracle Thin Driver JDBC Url", True, RuntimeContextVariable.NO_INCREMENT))
        
        
        oracleDriver = "oracle.jdbc.OracleDriver"
        runtimeContext.addVariable(RuntimeContextVariable("JDBC_DRIVER", oracleDriver, RuntimeContextVariable.STRING_TYPE, "Oracle Thin Driver class", True, RuntimeContextVariable.NO_INCREMENT))
        
        self.__dbControl = Boolean.parseBoolean(getVariableValue("CONFIG_DBCONTROL", "false"))
        
        if self.__dbControl:
            self.__dbCtrlPort = getVariableValue("DBCONTROL_HTTP_PORT")
            additionalVariables.add(RuntimeContextVariable( "HTTPS_PORT", self.__dbCtrlPort, RuntimeContextVariable.STRING_TYPE))
        
        oracleDir = getVariableValue("ORACLE_DIR")
        self.__markerFilePath = os.path.join(oracleDir, ".#dsoracle")
        
        self.__maintFilePath = getVariableValue("ORACLE_MAINT_FILE")
        
        dbInstallOption = getVariableValue("DB_INSTALL_OPTION")
        if dbInstallOption == "INSTALL_DB_AND_CONFIG":
            globalLockString = "OracleEnabler-" + self.__hostname
            logger.info("Requesting Global Lock with name: " + globalLockString)
            domain = proxy.getContainer().getCurrentDomain()
            options = domain.getOptions()
            maxActivationTimeOut = options.getProperty(Options.MAX_ACTIVATION_TIME_IN_SECONDS)
            lockTimeOut = Long.parseLong(maxActivationTimeOut) * 1000
            acquired = ContainerUtils.acquireGlobalLock(globalLockString, lockTimeOut , lockTimeOut)
            if acquired:
                logger.info("Acquired Global lock with name: " + globalLockString)
            else:
                logger.severe("Could not acquire Global lock with name: " + globalLockString)
                raise Exception("Could not acquire Global lock with name: " + globalLockString)

    def installActivationInfo(self, info):
        "install activation info"

        if self.__dbControl:
            propertyName = "EnterpriseManager"
            propertyValue = "https://" + self.__hostname + ":" + self.__dbCtrlPort + "/em"
            logger.info("Set activation info:" + propertyName + " = " + propertyValue)
            info.setProperty(propertyName, propertyValue)
        
        propertyName="JDBC_URL"
        propertyValue = self.__jdbcUrl
        logger.info("Set activation info:" + propertyName + " = " + propertyValue)
        info.setProperty(propertyName, propertyValue)
        
    def isServerRunning(self):
        " is server running"
        running = False
        
        if self.__maintFilePath  and os.path.isfile(self.__maintFilePath):
            running = True
        else:
            running = self.__connectToDatabase()
            
        return running
    
    def hasServerStarted(self):
        " has server started"
        
        started = False
        if os.path.isfile(self.__markerFilePath):
            started = self.__connectToDatabase()
        
        return started
        
    
    def __connectToDatabase(self):
        "check database meta data"

        success = False
        ods = None
        conn = None
        stmt = None
        rset = None

        try:
            ods = OracleDataSource()
            ods.setURL(self.__oracleServiceUrl)
            ods.setUser("sys AS SYSDBA")
            ods.setPassword(self.__sysPassword)
            conn = ods.getConnection()

            if conn:
                stmt = conn.createStatement()
                if stmt:
                    rset = stmt.executeQuery("SELECT * FROM sys.dual");

                    if rset.next():
                        success = True
                    else:
                        logger.info("No meta data found for Oracle service URL:" + self.__oracleServiceUrl + ":SELECT * FROM sys.dual")
                else:
                    logger.info("Unable to create JDBC SQL statement for Oracle service URL:" + self.__oracleServiceUrl + ":SELECT * FROM sys.dual")
            else:
                logger.info("Unable to get JDBC connection for Oracle service URL:" + self.__oracleServiceUrl)
        except:
            type, value, traceback = sys.exc_info()
            logger.severe("MetaData error for Oracle service URL:" + self.__oracleServiceUrl + ":"+ `value`)
            
        finally:
            if rset:
                try:
                    rset.close()
                except:
                    type, value, traceback = sys.exc_info()
                    
            if stmt:
                try:
                    stmt.close()
                except:
                    type, value, traceback = sys.exc_info()
                    
            if conn:
                try:
                    conn.close()
                except:
                    type, value, traceback = sys.exc_info()

        return success;

        
def getVariableValue(name, value=None):
    "get runtime variable value"
    var = runtimeContext.getVariable(name)
    if var != None:
        value = var.value
    
    return value

def doInit(additionalVariables):
    "do init"
    logger.info("OracleDatabaseContainer: doInit:Enter")
    oracleDatabase = OracleDatabase(additionalVariables)
    oracleDatabaseRcv = RuntimeContextVariable("ORACLE_DATABASE_OBJECT", oracleDatabase, RuntimeContextVariable.OBJECT_TYPE)
    runtimeContext.addVariable(oracleDatabaseRcv)
    logger.info("OracleDatabaseContainer: doInit:Exit")
    
def hasContainerStarted():
    started = False
    try:
        oracleDatabase = getVariableValue("ORACLE_DATABASE_OBJECT")
        
        if oracleDatabase:
            started = oracleDatabase.hasServerStarted()
            
    except:
        type, value, traceback = sys.exc_info()
        logger.severe("Unexpected error in OracleDatabaseContainer:hasContainerStarted:" + `value`)
    
    return started
    
def isContainerRunning():
    running = False
    try:
        oracleDatabase = getVariableValue("ORACLE_DATABASE_OBJECT")
        if oracleDatabase:
            running = oracleDatabase.isServerRunning()
    except:
        type, value, traceback = sys.exc_info()
        logger.severe("Unexpected error in OracleDatabaseContainer:isContainerRunning:" + `value`)
    
    return running

def doInstall(info):
    " do install of activation info"

    logger.info("OracleDatabaseContainer: doInstall:Enter")
    hostname = "localhost";
    try:
        hostname = InetAddress.getLocalHost().getCanonicalHostName()
    except:
        type, value, traceback = sys.exc_info()
        logger.severe("Hostname error:" + `value`)
    
    dbInstallOption = getVariableValue("DB_INSTALL_OPTION")
    if dbInstallOption == "INSTALL_DB_AND_CONFIG":        
        globalLockString = "OracleEnabler-" + hostname
        ContainerUtils.releaseGlobalLock(globalLockString)
        logger.info("Released global lock with name: " + globalLockString)
        
    try:
        oracleDatabase = getVariableValue("ORACLE_DATABASE_OBJECT")
        if oracleDatabase:
            oracleDatabase.installActivationInfo(info)
    except:
        type, value, traceback = sys.exc_info()
        logger.severe("Unexpected error in OracleDatabaseContainer:doInstall:" + `value`)
        
    logger.info("OracleDatabaseContainer: doInstall:Exit")