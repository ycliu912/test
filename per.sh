#!/bin/bash

log_path="/root/log"
tag_date=`date +%F-%H-%M-%S`

if [ -n "${1}" ];then
   :
else
   echo "per.sh para"
   exit 1
fi

sar -n DEV 10 99999 >> ${log_path}/${1}_sar_${tag_date}\.txt &
iostat -t -x 10 99999 >> ${log_path}/${1}_iostat_${tag_date}\.txt &
vmstat 10 99999 >> ${log_path}/${1}_vmstat_${tag_date}\.txt &
iotop -o -b -u oracle >> ${log_path}/${1}_iotop_${tag_date}\.txt &
