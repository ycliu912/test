#!/bin/bash
################################################################
# HA script for Oracle dataguard 11.2.0.4                      #
# This script is tested under Linux                            #
# Version: 1.0                                                 #
# Author:  Liu.yanchao                                         #
# Date:    2015-06-09                                          #
################################################################


##**************USER DEFINE BEGIN*******************************
sqlplus_passwd="vimicro"
dgmgrl_passwd="vimicro"
oracle_sid=orcl
#primary database switchover/failover prepare method:0 or 1
#0:switch_prepare_reboot
#1:switch_prepare_logswitch
switch_prepare_method=1

#Change the role of database from a primary database to a standby database using either a switchover or a failover operation
#0:using switchover operation
#1:using failover operation
role_change_method=0
##**************USER DEFINE END*********************************

oracle_exist=`ps -ef | grep ora_dbw0_${oracle_sid} | grep -v grep | wc -l`
uptime_s=`cat /proc/uptime | cut -d" " -f 1 | cut -d"." -f 1`

function mode_as_dgmgrl_nopwd(){
su - oracle -c "dgmgrl -silent /"<<EOF 2>/dev/null
connect /;
$1
exit
EOF
}


function mode_as_dgmgrl(){
su - oracle -c "dgmgrl -silent sys/${1}@${2}"<<EOF
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

#**oracle doesn't work*******************************************
    if [ "${uptime_s}" -lt 480 ] ; then       
          if [ "${oracle_exist}" -ne 0 ] ; then
             :
          else
             su - oracle -c 'lsnrctl start;' >/dev/null 2>&1
             sleep 15
             mode_as_sqlplus "startup mount;"
             db_unique_name=$(mode_as_sqlplus "select db_unique_name from v\$database;")

             sleep 10
             
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
             sleep 5
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"
             sleep 60
           fi 
    else
          :
                 
    fi



db_unique_name=$(mode_as_sqlplus "select db_unique_name from v\$database;")
database_role=$(mode_as_sqlplus "select database_role from v\$database;")
local_database_open_mode=$(mode_as_sqlplus "select open_mode from v\$database;")

primary_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep  "Primary database" | cut -d'-' -f1 | tr -d "^ ")
physical_standby_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep "Physical standby database" | cut -d'-' -f1 | tr -d "^ ")
configuration_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Configuration Status:" | tr -d  "^ \t\n" | cut -d : -f 2)

primary_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Primary database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/')
standby_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Physical standby database" | tr -d  "^ \n" | sed 's/.*\(ORA-[0-9]\{5\}\).*/\1/')

local_database_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show database verbose ${db_unique_name};" | grep -A 1 "Database Status:" | tr -d  "^ \t\n" | cut -d : -f 2)


##********************************************************************************
case "$1" in
     start)
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
          #**command "REINSTATE DATABASE standby database" in progress
          elif [ "${configuration_status}" == "ORA-16610" ] ; then
              if [ "${database_role}" == "PRIMARY" ] ; then
                  sleep 5
                  :
                  exit 0;
              else
                  exit 1;
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
          elif [ "${local_database_open_mode}" == "READ WRITE" ] ; then
              exit 0; 
          else 
                exit 1
          fi    
          

          exit 0;
          ;;
     stop) 
          

          #************* STOP DATABASE  ****************
#         if [ "${configuration_status}" == "SUCCESS" ] ; then
#              if [ "${database_role}" == "PRIMARY" ] ; then
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"   
#                   :
#              else
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
#                   mode_as_dgmgrl  "${dgmgrl_passwd}"  "${db_unique_name}" "startup mount;"
#                   :   
#              fi
#           
#          else
#              ###dgmgrl client is swithover to std,ha waitting time is expire,then will stop this service and start other service. 
#                   :
#          fi

	  # exit 0: Sucess to stop service
	  # exit the others: Failed to stop service
	  exit 0;
	  ;;
    status) 
           
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
          #**command "REINSTATE DATABASE standby database" in progress
          elif [ "${configuration_status}" == "ORA-16610" ] ; then
              if [ "${database_role}" == "PRIMARY" ] ; then
                  sleep 5
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
          #***local database open mode read write   
          elif [ "${local_database_open_mode}" == "READ WRITE" ] ; then
              exit 0;
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
