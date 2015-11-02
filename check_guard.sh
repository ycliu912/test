#!/bin/bash

sqlplus_passwd="vimicro"
dgmgrl_passwd="vimicro"
oracle_sid=orcl
tns_name_pri=pri
tns_name_std=std


function mode_as_dgmgrl(){
su - oracle -c "dgmgrl -silent sys/${1}@${2}"<<EOF
$3
exit
EOF
}

function mode_as_sqlplus_pwd(){
su - oracle -c "sqlplus -S sys/${1}@${2} as sysdba "<<EOF 2>/dev/null
set head off
set feedback off
set pages 0
set linesize 180
col db_unique_name for a5
col database_role for a18
col open_mode for a23
col protection_mode for a23
col protection_level for a23
col switchover_status for a18
$3
exit
EOF
}


mode_as_dgmgrl "${dgmgrl_passwd}"  "${tns_name_pri}"  "show configuration ;" >>/tmp/tmp_01.$$
mode_as_dgmgrl "${dgmgrl_passwd}"  "${tns_name_pri}"  "show fast_start failover;" >>/tmp/tmp_02.$$

whole_info_pri=$(mode_as_sqlplus_pwd "${sqlplus_passwd}" "${tns_name_pri}" "select db_unique_name,database_role,open_mode,protection_mode,protection_level,switchover_status,current_scn,standby_became_primary_scn from v\$database;")

whole_info_std=$(mode_as_sqlplus_pwd "${sqlplus_passwd}" "${tns_name_std}" "select db_unique_name,database_role,open_mode,protection_mode,protection_level,switchover_status,current_scn,standby_became_primary_scn from v\$database;")


cat <<!
======================================================================================================================================================================
----------------------------------------------------------------------------------------------------------------------------------------------------------- ----------
${whole_info_pri}                                                                                                                                                     
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
${whole_info_std}                                                                                                                                                     
======================================================================================================================================================================
--------------show configuration---------------------------------------------------------------------------------------------------------------------------------------`cat /tmp/tmp_01.$$`
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
======================================================================================================================================================================
--------------show fast_start failover---------------------------------------------------------------------------------------------------------------------------------
`cat /tmp/tmp_02.$$`
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
======================================================================================================================================================================
!

rm -rf /tmp/tmp_01.$$
rm -rf /tmp/tmp_02.$$
rm -rf /tmp/tmp_03.$$
