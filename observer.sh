#!/bin/bash

function dgmgrl_run(){
sys_name="sys"
sys_passwd="vimicro"
primary_database_tns_server_name="pri"
log_observer="/tmp/log_observer.log"
file_tmp_observer="tmp_observer.1"
file_tmp_path="/opt/oracle"

cd $file_tmp_path

if [ ! -f ".${file_tmp_observer}" ];then
   touch $file_tmp_observer
   echo "stop observer;" >>$file_tmp_observer
   echo "start observer;" >>$file_tmp_observer
   echo "file $file_tmp_observer has been created:"
   cat $file_tmp_observer
   mv $file_tmp_observer .$file_tmp_observer

fi

dgmgrl ${sys_name}/${sys_passwd}@${primary_database_tns_server_name}<${file_tmp_path}/.${file_tmp_observer} >>${log_observer} &
echo "observer has been worked." 
}

role_user=`whoami`

if [ "${role_user}" == "oracle" ];then
   dgmgrl_run
else
   echo "please as user oracle run this script!"
fi

