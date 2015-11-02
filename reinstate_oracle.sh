#!/bin/bash


dgmgrl_passwd="Vimicro123"
oracle_sid=orcl

oracle_exist=`ps -ef | grep ora_dbw0_${oracle_sid} | grep -v grep | wc -l`
uptime_s=`cat /proc/uptime | cut -d" " -f 1 | cut -d"." -f 1`

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

#**oracle doesn't work*******************************************
    if [ "${uptime_s}" -gt 480 ] ; then
          if [ "${oracle_exist}" -ne 0 ] ; then
             :
          else
             su - oracle -C 'lsnrctl start;' >/dev/null 2>&1
             sleep 15
             mode_as_sqlplus "startup mount;"
             db_unique_name=$(mode_as_sqlplus "select db_unique_name from v\$database;")

             sleep 10

             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "shutdown immediate;"
             sleep 5
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}" "startup;"
             sleep 60

             primary_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep  "Primary database" | cut -d'-' -f1 | tr -d "^ ")
             physical_standby_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep "Physical standby database" | cut -d'-' -f1 | tr -d "^ ")
             configuration_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Configuration Status:" | tr -d  "^ \t\n" | cut -d : -f 2)             
             
             until [ "${configuration_status}" == "SUCCESS" ];do

             mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "enable database ${physical_standby_database};"
             mode_as_dgmgrl "${dgmgrl_passwd}"  "${primary_database}" "reinstate database ${physical_standby_database};"
             sleep 60
             configuration_status=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep -A 1 "Configuration Status:" | tr -d  "^ \t\n" | cut -d : -f 2)
             primary_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep  "Primary database" | cut -d'-' -f1 | tr -d "^ ")
             physical_standby_database=$(mode_as_dgmgrl "${dgmgrl_passwd}"  "${db_unique_name}"  "show configuration;" | grep "Physical standby database" | cut -d'-' -f1 | tr -d "^ ")

             done
           fi
    else
          :

    fi

