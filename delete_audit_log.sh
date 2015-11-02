#!/bin/bash

# crontab -e
# 0 4 * * * /root/bin/delete_audit_log.sh
# service cron restart

path_oracle_admin=/opt/oracle/admin
path_audit_log=`find ${path_oracle_admin}/* -type d | grep adump$`
keep_days=1
audit_log_size=`du -cs ${path_audit_log} | sed -n '$p' | awk '{print $1}'`
#700M
threshold_size=716800

if [ "${audit_log_size}" -ge "${threshold_size}" ];then
   find ${path_audit_log} -name "*.aud" -mtime +${keep_days} -exec rm -f {} \;
else
   :
#   echo "audit log size is ${audit_log_size}"
fi



