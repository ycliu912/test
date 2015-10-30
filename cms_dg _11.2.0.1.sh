#!/bin/bash
################################################################
# HA script for ViSS 3.2 product                               #
# This script is tested under Linux and Solaris                #
# Version: 1.0                                                 #
# Author:  Tang, Hongxing                                      #
# Date:    2011-06-27                                          #
################################################################


#======================== User Parameters Start ========================================
#Please set each user parameters and each user functions correctly
#Please check script 'start/stop/status all' before using HA scripts formally
#脟毛脮媒脠路脡猫脰脙脫脙禄搂虏脦脢媒潞脥脫脙禄搂潞炉脢媒虏驴路脰
#脭脷HA陆脜卤戮脮媒脢陆脝么脫脙脟掳拢卢脟毛录矛虏茅陆脜卤戮脝么露炉隆垄脥拢脰鹿隆垄录矛虏茅脛拢驴茅脳麓脤卢脢脟路帽脮媒脠路

#If NO_TOMCAT_WATCHDOG=1, no watchdog to start tomcat.
#If Apache Tomcat modules run in same user account, please set NO_TOMCAT_WATCHDOG=1.
# 脠莽鹿没脫脨露脿赂枚Apache Tomcat脛拢驴茅脢鹿脫脙脧脿脥卢碌脛脫脙禄搂脮脢潞脜拢卢脟毛脡猫脰脙NO_TOMCAT_WATCHDOG=1隆拢
# 脠莽鹿没NO_TOMCAT_WATCHDOG=1拢卢Apache Tomcat脛拢驴茅陆芦虏禄脢鹿脫脙watchdog脝么露炉拢卢
#  脮芒脰脰脟茅驴枚脥篓鲁拢陆枚脫脙脫脷脢碌脩茅脢脪虏芒脢脭隆拢
NO_TOMCAT_WATCHDOG=0

#If you not used HA, please comments the following line.
# 脠莽鹿没虏禄脢鹿脫脙HA拢卢脟毛脳垄脢脥脧脗脕脨脨脨隆拢
START_NO_FORK=-nofork

# The delay time to kill module's processes, unit: seconds
# 脭脷脥拢脰鹿HA路镁脦帽脢卤拢卢脩脫鲁脵露脿脡脵脢卤录盲(碌楼脦禄拢潞脙毛)潞贸脟驴脰脝kill脛拢驴茅陆酶鲁脤隆拢
KILL_DELAY=2



export PATH=/sbin:/bin:/usr/sbin:/usr/local/bin:/usr/bin:$PATH
OS_TYPE=`uname`

##********************************************************************************
sqlplus_passwd="Vimicro123"
dgmgrl_passwd="Vimicro123"
oracle_sid=orcl

oracle_exist=`ps -ef | grep ora_dbw0_${oracle_sid} | grep -v grep | wc -l`

#--------------------
#CMS module
#--------------------
CMS=cms
#If no CMS module to be handled, comments the CMS_USER line,
# otherwise, please set the following parameters correctly
# Èç¹û²»ÐèÒªHA½Å±¾Æô¶¯CMSÄ£¿é£¬Çë×¢ÊÍCMS_USERÐÐ£¬
#  ·ñÔò£¬ÇëÕýÈ·ÉèÖÃCMSµÄwatchdog½Å±¾¼°ÆäÂ·¾¶¡¢Apache TomcatµÄbinÄ¿Â¼Â·¾¶¡£
CMS_USER=viss311
CMS_COMMAND=./watchdog_cms.pl
CMS_PATH=/home/viss311/cms/cms/bin
CMS_WEB_PATH=/home/viss311/cms/apache-tomcat-6.0.35/bin



#--------------------
#CCS module
#--------------------
CCS=ccs
CCS_SIP=CCSSipSubSystem
#If no CCS module to be handled, comments the CCS_USER line,
# otherwise, please set the following parameters correctly
# Èç¹û²»ÐèÒªHA½Å±¾Æô¶¯CCSÄ£¿é£¬Çë×¢ÊÍCCS_USERÐÐ£¬
#  ·ñÔò£¬ÇëÕýÈ·ÉèÖÃCCSºÍSIPSUBSYSTEM_CCSµÄwatchdog½Å±¾¼°Æä¹²ÓÃµÄÂ·¾¶¡£
CCS_USER=viss311
CCS_SIP_COMMAND=./watchdog_sip_ccs.pl
CCS_COMMAND=./watchdog_ccs.pl
CCS_PATH=/home/viss311/ccs/ccs/ccsapp


#************************** Internal Functions *******************************

#*****************************************************************************
# Function:
#  Start the module by watchdog
#  If watchdog is not found, the script will exit with return code 1
# Arguments:
#  $1: The user of the module to be started
#  $2: The directory which contains the watchdog
#  $3: The file name of watchdog
#*****************************************************************************
Start_Watchdog ()
{
        if [ -e $2/$3 ];then
          if [ -n "$START_NO_FORK" ];then
            echo su - $1 -c "cd $2;$3 start -nofork > /dev/null"
            su - $1 -c "cd $2;$3 start -nofork > /dev/null"
          else
            echo su - $1 -c "cd $2;$3 start > /dev/null"
            su - $1 -c "cd $2;$3 start > /dev/null"
          fi
        else
          echo "$2/$3 not found."
          exit 1
        fi
}

#*****************************************************************************
# Function:
#  Stop the module by watchdog
# Arguments:
#  $1: The user of the module to be stopped
#  $2: The directory which contains the watchdog
#  $3: The file name of watchdog
#*****************************************************************************
Stop_Watchdog ()
{
        echo su - $1 -c "cd $2;$3 stop > /dev/null"
        su - $1 -c "cd $2;$3 stop > /dev/null"
}

#*****************************************************************************
# Function:
#  Get the status of module by watchdog
# Arguments:
#  $1: The user of the module
#  $2: The directory which contains the watchdog
#  $3: The file name of watchdog
# Output:
#  $?: The status of the module. 0: running, the others: stopped
#*****************************************************************************
Status_Watchdog ()
{
        su - $1 -c "cd $2;$3 status > /dev/null"
}

#*****************************************************************************
# Function:
#  Start the module by starting apache tomcat
#  If tomcat is not found, the script will exit with return code 1
# Arguments:
#  $1: The user of the module to be started
#  $2: The directory which contains startup.sh
#*****************************************************************************
Start_Tomcat ()
{
        if [ -e $2/startup.sh ];then
          echo su - $1 -c "cd $2;./startup.sh > /dev/null"
          su - $1 -c "cd $2;./startup.sh > /dev/null"
        else
          echo "$2/startup.sh not found."
          exit 1
        fi
}

#*****************************************************************************
# Function:
#  Stop the module by stopping apache tomcat
# Arguments:
#  $1: The user of the module to be stopped
#  $2: The directory which contains shutdown.sh
#*****************************************************************************
Stop_Tomcat ()
{
        echo su - $1 -c "cd $2;./shutdown.sh > /dev/null"
        su - $1 -c "cd $2;./shutdown.sh > /dev/null"
}

#*****************************************************************************
# Function:
#  Get the status of module by checking the cmd line of apache tomcat
# Arguments:
#  $1: The user of the module
#  $2: The directory which contains the bin files of apache tomcat
# Output:
#  $RESULT: The status of the module. 0: stopped, the others: running
#*****************************************************************************
Status_Tomcat ()
{
        if [ "$OS_TYPE" == "Linux" ];then
          # Linux OS. Include ReaHat Linux and Suse Linux, and so on
          RESULT=`pgrep -u $1 -f $2 | wc -l`;
        else
          # Other OS. Like Solaris, and so on
          RESULT=`pgrep -u $1 -f java | wc -l`;
        fi
}

#*****************************************************************************
# Function:
#  Force to kill all process of module
#  Force to release all resources of module
# Arguments:
#  $1: The user of the module
#*****************************************************************************
Kill_User_Process ()
{
        pkill -9 -u $1
        ipcs -s | grep $1 | awk '{print "ipcrm -s "$2}' | bash
        ipcs -m | grep $1 | awk '{print "ipcrm -m "$2}' | bash
}

#*****************************************************************************
# Function:
#  Show the status of the module which is running
# Arguments:
#  $1: The name of the module
#*****************************************************************************
Show_Module_Running ()
{
        echo "$1 is running."
}

#*****************************************************************************
# Function:
#  Show the status of the module which is stopped
# Arguments:
#  $1: The name of the module
#*****************************************************************************
Show_Module_Stopped ()
{
        echo "$1 is stopped."
}

#*****************************************************************************
# Function:
#  Show the status of module whether is started or not
#  If module is not started successfully, the script will exit with return code 1
# Input:
#  $?: 0: success to start module, the others: failed to start module
# Arguments:
#  $1: The name of the module
#*****************************************************************************
Judge_Start_Status ()
{
        if [ $? -ne 0 ]; then
          echo "$1 failed to start."
          exit 1
        else
          echo "$1 is started."
        fi
}

#*****************************************************************************
# Function:
#  Deal with the module's status
#  Show the module's status
#  If $2 is not "all" and module is stopped,
#    then exit the script with return code 1
#  If $2 is "all" and module is stopped,
#    then just set $EXIT=1.
# Input:
#  $RESULT: The status of the module. 0: stopped, the others: running
# Arguments:
#  $1: The name of the module
#  $2: all: no exit script even if module is stopped.
#*****************************************************************************
Judge_Module_Status ()
{
        if [ $RESULT -eq 0 ] ; then
          Show_Module_Stopped $1
          if [ "$2" == "all" ];then
            EXIT=1
          else
            exit 1
          fi
        else
          if [ "$2" == "all" ];then
            Show_Module_Running $1
          fi
        fi
}

#*****************************************************************************
# Function:
#  Deal with the module's status returned by watchdog
# Input:
#  $?: The status of the module. 0: running, the others: stopped
# Arguments:
#  $1: The name of the module
#  $2: all: no exit script even if module is stopped.
#*****************************************************************************
Judge_Watchdog_Status ()
{
        if [ $? -ne 0 ] ; then
          RESULT=0
        else
          RESULT=1
        fi
        Judge_Module_Status $1 $2
}


function mode_as_dgmgrl_nopwd(){
su - oracle -C "dgmgrl -silent /"<<EOF 2>/dev/null
connect /;
$1
exit
EOF
}




function mode_as_dgmgrl(){
su - oracle -C "dgmgrl -silent sys/${1}@${2}"<<EOF
$3
exit
EOF
}


function mode_as_sqlplus(){
su - oracle -c 'sqlplus -S / as sysdba '<<EOF 2>/dev/null
set head off
set feedback off
set pages 0
$1
exit 
EOF
}


function mode_as_sqlplus_pwd(){
su - oracle -c "sqlplus -S sys/${1}@${2} as sysdba "<<EOF 2>/dev/null
set head off
set feedback off
set pages 0
$3
exit 
EOF
}

function switch_prepare_reboot(){
mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "shutdown immediate;"
mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "startup;"
sleep 3
}

function switch_prepare_logswitch(){
mode_as_sqlplus_pwd "${sqlplus_passwd}"  "${primary_database}" "alter system archive log current;"
sleep 1
}

function switchover_method(){
mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "switchover to ${physical_standby_database};"
}

function failover_method(){
mode_as_sqlplus_pwd "${sqlplus_passwd}"  "${primary_database}" "alter system archive log current;"
mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "shutdown abort;" 
sleep 10
}

uptime_s=`cat /proc/uptime | cut -d" " -f 1 | cut -d"." -f 1`


#primary database switchover/failover prepare method:0 or 1
#0:switch_prepare_reboot
#1:switch_prepare_logswitch
switch_prepare_method=0

#Change the role of database from a primary database to a standby database using either a switchover or a failover operation
#0:using switchover operation
#1:using failover operation
role_change_method=0


#**oracle doesn't work*******************************************
    if [ "${uptime_s}" -lt 480 ] ; then       
          if [ "${oracle_exist}" -ne 0 ] ; then
             :
          else
             su - oracle -C 'lsnrctl start;' >/dev/null 2>&1
             sleep 15
             mode_as_sqlplus "startup mount;"
             db_unique_name=$(mode_as_sqlplus "select db_unique_name from v\$database;")
#####        path_alert_log=`find $ORACLE_BASE | grep alert | grep log$ | grep ${db_unique_name}`

             sleep 10
             
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
             sleep 5
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"
             sleep 60
#             primary_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep  "Primary database" | cut -d'-' -f1 | tr -d "^ ")
#             physical_standby_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep "Physical standby database" | cut -d'-' -f1 | tr -d "^ ")
 
#             mode_as_dgmgrl "${dgmgrl_passwd}"  "${physical_standby_database}" "shutdown immediate;"
#             sleep 5
#             mode_as_dgmgrl "${dgmgrl_passwd}"  "${physical_standby_database}" "startup;"
#             sleep 35
#             mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "enable database ${physical_standby_database};"
#             mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "reinstate database ${physical_standby_database};"
#             sleep 60
           fi 
    else
          :
                 
    fi


#mode_as_sqlplus "select db_unique_name from v\$database;"
#mode_as_sqlplus "select database_role from v\$database;"

db_unique_name=$(mode_as_sqlplus "select db_unique_name from v\$database;")
database_role=$(mode_as_sqlplus "select database_role from v\$database;")
mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep 'Primary database' | cut -d'-' -f1 | tr -d "^ "
#mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep 'Physical standby database' | cut -d'-' -f1 | tr -d "^ "
#mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 'Configuration Status:' | tr -d  "^ \t\n" | cut -d : -f 2

#mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Primary database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/'
#mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Physical standby database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/'

primary_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep  "Primary database" | cut -d'-' -f1 | tr -d "^ ")
physical_standby_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep "Physical standby database" | cut -d'-' -f1 | tr -d "^ ")
configuration_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Configuration Status:" | tr -d  "^ \t\n" | cut -d : -f 2)

primary_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Primary database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/')
standby_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Physical standby database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/')

local_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show database verbose ${db_unique_name};" | grep -A 1 "Database Status:" | tr -d  "^ \t\n" | cut -d : -f 2)

####path_alert_log=`find $ORACLE_BASE | grep alert | grep log$ | grep ${db_unique_name}`

##********************************************************************************

#If you want to set the default route, please set ROUTE_BONDING=1
# and modify the Default_Route and Restore_Route functions according to the real case.
# 如果需要HA脚本管理路由，请设置ROUTE_BONDING=1，
#  并且按照实际情况修改Default_Route和Restore_Route函数。
ROUTE_BONDING=1

#######################################################################
# Function:
#  Set the default route of system
#######################################################################
#At the beginning of HA Start, chanage the default route via float IP address
# 在HA启动时，正确设置系统的路由包括浮动IP地址。
# 举例：
#  ip route replace default via 缺省网关IP地址 dev 浮动网卡1 src 浮动IP地址1
#  ip route replace 网段 dev 浮动网卡2 scop link src 浮动IP地址2
# 仅当ROUTE_BONDING=1时，该函数才会被调用
Default_Route ()
{
	if [ "$OS_TYPE" == "Linux" ];then
	  # Linux OS. Include ReaHat Linux and Suse Linux, and so on
	  ip route replace default via 10.30.27.250 dev eth0:0 src 10.30.27.187
#	  ip route replace 135.251.10.0/24 dev bond1:0 scope link src 135.251.10.133
	fi
}

#At the end of HA Stop, change back to the default system route
# 在HA停止时，正确恢复系统的路由设置
# 举例：
#  ip route replace default via 缺省网关IP地址 dev 本地网卡1
#  ip route replace 网段 dev 本地网卡2 scop link
# 仅当ROUTE_BONDING=1时，该函数才会被调用
Restore_Route ()
{
	if [ "$OS_TYPE" == "Linux" ];then
	  # Linux OS. Include ReaHat Linux and Suse Linux, and so on
	  ip route replace default via 10.30.27.250 dev eth0
#	  ip route replace 135.251.10.0/24 dev bond1 scope link
	fi
}

case "$1" in
     start)
	  ulimit -n 8196

	  #************* BONDING ROUTE ***************
	  if [ $ROUTE_BONDING -eq 1 ];then
	    Default_Route
	  fi
          
          if [ "${configuration_status}" == "SUCCESS" ] ; then
                if [ "${database_role}" == "PRIMARY" ] ; then  
                    :
                else
                    if [ ${switch_prepare_method} == "0" ];then
                       switch_prepare_reboot
                    else
                       switch_prepare_logswitch
                    fi
                    
                    if [ ${role_change_method} == "0" ];then
                       switchover_method
                    else
                       failover_method
                    fi
                fi
          elif [ "${configuration_status}" == "WARNING" ] ; then
                if [ "${database_role}" == "PRIMARY" ] ; then
                    :
                else
                    if [ ${switch_prepare_method} == "0" ];then
                       switch_prepare_reboot
                    else
                       switch_prepare_logswitch
                    fi
                    
                    if [ ${role_change_method} == "0" ];then
                       switchover_method
                    else
                       failover_method
                    fi
          
                fi
           
          elif [ "${configuration_status}" == "WARNING" ] ; then
              if [ "${database_role}" == "PRIMARY" ] ; then
                  if [ "${primary_database_status}" == "ORA-16817" ] && [ "${standby_database_status}" == "ORA-16661" ] ; then
                     :
                  fi
              fi
          
          elif [ "${configuration_status}" == "ERROR" ] ; then
                if [ "${database_role}" == "PRIMARY" ] ; then
                   if [ "${primary_database_status}" == "ORA-16820" ] || [ "${standby_database_status}" == "ORA-16820" ] ; then
                       :
                   fi

                else
                   if [ ${switch_prepare_method} == "0" ];then
                      switch_prepare_reboot
                   else
                      switch_prepare_logswitch
                   fi 
                   
                   if [ ${role_change_method} == "0" ];then
                      switchover_method
                   else
                      failover_method
                   fi
                fi
          elif [ "${configuration_status}" == "ORA-16610" ] ; then
              if [ "${database_role}" == "PRIMARY" ] ; then
                   if [ "${local_database_status}" == "ERROR" ] ; then
                       mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
                       mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"
                       sleep 60
                   else
                       :
                   fi
              else
                   :
              fi 
          
#          elif [ "${configuration_status}" == "ORA-12543" ] || [ "${configuration_status}" == "ORA-01034" ] ; then
#                if [ "${database_role}" == "PHYSICAL STANDBY" ] ; then
#                   mode_as_sqlplus "alter database recover managed  standby database finish;alter database commit to switchover to primary;shutdown immediate;startup;" 
#                fi  
          else 
                exit 1
          fi    
          
           #************* START CMS ********************
          if [ -n "$CMS_USER" ];then
            if [ $NO_TOMCAT_WATCHDOG -eq 1 ];then
              Start_Tomcat $CMS_USER $CMS_WEB_PATH
            else
              Start_Watchdog $CMS_USER $CMS_PATH $CMS_COMMAND
            fi
            Judge_Start_Status $CMS
            sleep 10
          fi 

          
          #************* START CCS ********************
          if [ -n "$CCS_USER" ];then
            Start_Watchdog $CCS_USER $CCS_PATH $CCS_SIP_COMMAND
            Judge_Start_Status $CCS_SIP
            Start_Watchdog $CCS_USER $CCS_PATH $CCS_COMMAND
            Judge_Start_Status $CCS
          fi           


          exit 0;
          ;;
     stop) 
          

          #************* STOP CMS ********************
          if [ -n "$CMS_USER" ];then
            if [ $NO_TOMCAT_WATCHDOG -eq 1 ];then
              Stop_Tomcat $CMS_USER $CMS_WEB_PATH
            else
              Stop_Watchdog $CMS_USER $CMS_PATH $CMS_COMMAND
            fi
          fi


          #************* STOP CCS ********************
          if [ -n "$CCS_USER" ];then
            Stop_Watchdog $CCS_USER $CCS_PATH $CCS_COMMAND
            Stop_Watchdog $CCS_USER $CCS_PATH $CCS_SIP_COMMAND
          fi

           #************* Kill the process, which is still running, for all modules *************
          for loop in $CMS_USER $AAA_USER $AS_USER $MAPS_USER $PAS_USER $CCS_USER $MDU_USER $SA_USER $VOD_USER $VAU_USER $VAU_MS_USER $MSP_USER $HFS_USER $PORTAL_USER
            do Kill_User_Process $loop
          done
          #************* STOP DATABASE  ****************
          if [ "${configuration_status}" == "SUCCESS" ] ; then
              if [ "${database_role}" == "PRIMARY" ] ; then
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"   
                   :
              else
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "startup mount;"
                   :   
              fi
           
          else
              ###dgmgrl client is swithover to std,ha waitting time is expire,then will stop this service and start other service. 
                   :
          fi
          
	  #************* BONDING ROUTE **************
	  if [ $ROUTE_BONDING -eq 1 ];then
	    Restore_Route
	  fi

	  # exit 0: Sucess to stop service
	  # exit the others: Failed to stop service
	  exit 0;
	  ;;
    status) 
          #************* CCS STATUS ****************************************
          if [ -n "$CCS_USER" ];then
            Status_Watchdog $CCS_USER $CCS_PATH $CCS_SIP_COMMAND
            Judge_Watchdog_Status $CCS_SIP $2

            Status_Watchdog $CCS_USER $CCS_PATH $CCS_COMMAND
            Judge_Watchdog_Status $CCS $2
          fi

          #************* CMS STATUS ****************************************
          if [ -n "$CMS_USER" ];then
            if [ $NO_TOMCAT_WATCHDOG -eq 1 ];then
              Status_Tomcat $CMS_USER $CMS_WEB_PATH
              Judge_Module_Status $CMS $2
            else
              Status_Watchdog $CMS_USER $CMS_PATH $CMS_COMMAND
              Judge_Watchdog_Status $CMS $2
            fi
          fi           
          
           
          #**dataguard works well 
          if [ "${configuration_status}" == "SUCCESS" ] ; then    
              if [ "${database_role}" == "PRIMARY" ] ; then
                  :
                  exit 0;
              else
                  exit 1;
              fi
          #**observer doesn't work
          elif [ "${configuration_status}" == "WARNING" ] ; then   
              if [ "${database_role}" == "PRIMARY" ] ; then
                  if [ "${primary_database_status}" == "ORA-16817" ] && [ "${standby_database_status}" == "ORA-16661" ] ; then
                     :
                     exit 0;
                  fi
                  
              else
                  exit 1;
              fi
          #** ERROR ORA-16820: Fast-Start Failover observer is no longer observing this database
          elif [ "${configuration_status}" == "ERROR" ] ; then     
              if [ "${database_role}" == "PRIMARY" ] ; then
                  if [ "${primary_database_status}" == "ORA-16820" ] || [ "${standby_database_status}" == "ORA-16820" ] ; then
                     :
                     exit 0;
                  fi

              else
                  exit 1;
              fi 
          #**ORA-12543:TNS:destination host unreachable
          elif [ "${configuration_status}" == "ORA-12543" ] || [ "${configuration_status}" == "ORA-01034" ] ; then    
                if [ "${database_role}" == "PRIMARY" ] ; then
                   :
                   exit 0;
                else
                   exit 1;  
                fi 
          #***standby database power off   
          elif [ "${configuration_status}" == "ORA-16610" ] ; then    
              if [ "${database_role}" == "PRIMARY" ] ; then
                   sleep 3  
                   if [ "${local_database_status}" == "ERROR" ] ; then
                      exit 1;
                   else
                      exit 0;
                   fi
              else
                   exit 1;
              fi 
          #**standby database shutdown abort
          elif [ "${configuration_status}" == "ERROR" ] ; then       
              if [ "${database_role}" == "PRIMARY" ] ; then
                  if [ "${primary_database_status}" == "ORA-16825" ] && [ "${standby_database_status}" == "ORA-01034" ] ; then
                     :
                     exit 0;
                  fi

              else
                  exit 1;
              fi   
          else
              exit 1;
          fi
	  ;;
	*)
	  echo "usage:$0 [start|stop|status|status all]"
	  echo "Please set each user parameters and user functions correctly in $0"
	  echo "Please check $0 [start|stop|status all] before using HA scripts formally"

	  exit 1
	  ;;
esac	  
