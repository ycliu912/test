#!/bin/bash

#---------------------------------------------------------
ans="60"
path_archived_log="/opt/oracle/archivelog/orcl"
path_oracle_base="/opt/oracle"
path_databasefile_dbf="/opt/oracle/oradata/orcl"
path_online_redo_log="/opt/oracle/oradata/orcl"
path_standby_online_redo_log="/opt/oracle/oradata/orcl/dg"
path_audit_log="/opt/oracle/admin/orcl/adump"
path_fast_recovery_area="/opt/oracle/fast_recovery_area"
PATH_LOG=/var/log/arch
#----------------------------------------------------------

function size_find(){
find "$1" -name "$2"  | xargs du -csh | sed -n '$p' | awk '{print $1}'
}

function size_du(){
du -csh "$1" | sed -n '$p' | awk '{print $1}'
}

if [ -e  "${PATH_LOG}" ];then
   :
else
   mkdir -p $PATH_LOG
   chown -R oracle:oinstall $PATH_LOG
fi

size_archived_log=`size_find "${path_archived_log}" "*.dbf"`
size_oracle_base=`size_du "${path_oracle_base}"`
size_database_file_dbf=`size_find "${path_databasefile_dbf}" "*.dbf"`
size_online_redo_log=`size_find "${path_online_redo_log}" "redo*.log"`
size_standby_online_redo_log=`size_find "${path_standby_online_redo_log}" "standby*.log"`
size_audit_log=`size_du "${path_audit_log}"`
size_fast_recovery_area=`size_du "${path_fast_recovery_area}"`
size_flashback_log=`size_find "${path_fast_recovery_area}" "*.flb"`

if [ -e "${path_archived_log}" ];then
   :
else
   echo "$path_archived_log does't exist."
   exit 1
fi

#read -p "How many days do you want to display?" ans
while [ "$ans" -ge 0 ]
do
  tempdate=`date --date="$ans day ago" +%Y-%m-%d`

  for filename in `find "${path_archived_log}" -name "*.dbf" -o -name "*.arc"`
  do
    if [ `date -r $filename +%Y-%m-%d` == "${tempdate}" ];then
        du $filename >>/tmp/${tempdate}.$$ 
    else
        :
    fi
  done

  if [ -f "/tmp/${tempdate}.$$" ];then

  num_arch=`cat /tmp/${tempdate}.$$ | wc -l` 
  sum_arch_Bytes=`awk 'BEGIN{sum=0}{sum+=$1}END{print sum}' /tmp/${tempdate}.$$ | tr -d "^ "`
  sum_arch_MB=`expr ${sum_arch_Bytes} / 1024 `

  echo -e "${tempdate}\t\t${num_arch}\t\t${sum_arch_Bytes}\t\t${sum_arch_MB}" >>/tmp/tmp_01.$$

  rm -rf /tmp/${tempdate}.$$ 
  else
       :
  fi
 
  ans=$[ $ans - 1 ]
done
 
num_total=`awk 'BEGIN{sum=0}{sum+=$2}END{print sum}' /tmp/tmp_01.$$ | tr -d "^ "` >/dev/null 2>&1
sum_Bytes_total=`awk 'BEGIN{sum=0}{sum+=$3}END{print sum}' /tmp/tmp_01.$$ | tr -d "^ "`  >/dev/null 2>&1
sum_MB_total=`awk 'BEGIN{sum=0}{sum+=$4}END{print sum}' /tmp/tmp_01.$$ | tr -d "^ "`  >/dev/null 2>&1
#sum_GB_total_tmp=`echo "${sum_Bytes_total} / 1048576 " | bc`
#sum_GB_total=`printf "%-10.3f" ${sum_Bytes_total_tmp}`
#sum_MB_total=`awk 'BEGIN{sum=0}{sum+=$4}END{print sum}' /tmp/tmp_01.$$ | tr -d "^ "`

p_clr=`clear`
p_dat=`date`
p_htn=`hostname`
p_k01=`echo -e "\t\t\t"`
p_k02=`echo -e "\t\t"`
p_k03=`echo -e "\t"`
TAG_DATE=`date +%F-%H-%M-%S`


cat <<! >>${PATH_LOG}/arch_${TAG_DATE}.log && echo "!!!please see log file in ${PATH_LOG}/arch_${TAG_DATE}.log"
$p_clr
$p_dat ${p_k02} $p_htn
----------------------------------------------------------------
ARCHIVED LOG TOTAL SIZE                     ${size_archived_log}
================================================================
DATE${p_k01}NUMBER${p_k02}SIZE(Bytes)${p_k03}SIZE(MB)
----------------------------------------------------------------
`cat /tmp/tmp_01.$$`
----------------------------------------------------------------
TOTAL${p_k01}${num_total}${p_k02}${sum_Bytes_total}${p_k02}${sum_MB_total}
================================================================
ORACLE BASE SIZE                           ${size_oracle_base} 
----------------------------------------------------------------
DATABASE FILE SIZE                         ${size_database_file_dbf}
----------------------------------------------------------------
ONLINE REDO LOG SIZE                       ${size_online_redo_log}
----------------------------------------------------------------
STANDBY ONLINE REDO LOG SIZE               ${size_standby_online_redo_log}
----------------------------------------------------------------
FAST RECOVERY AREA SIZE                    ${size_fast_recovery_area}
----------------------------------------------------------------
FLASHBACK LOG SIZE                         ${size_flashback_log}
----------------------------------------------------------------
AUDIT LOG SIZE                             ${size_audit_log}
================================================================
++++++++++++++++++++++++++DISK SPACE++++++++++++++++++++++++++++
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`df -h`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
================================================================
+++++++++++++++++FAST RECOVERY AREA SIZE++++++++++++++++++++++++
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`du -h "${path_fast_recovery_area}"`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!


rm -rf /tmp/tmp_01.$$
