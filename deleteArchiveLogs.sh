#!/bin/sh

ORACLE_HOME=/opt/oracle/product/11gR2/db
ORACLE_USER=oracle
KEEP_DAYS_RETENTION=2
KEEP_DAYS_ARCHIVELOG=2

PATH_LOG=/var/log/rman
TAG_DATE=`date +%F-%H-%M-%S`

# ÇÀKEEP_DAYSÌǰµĹ鵵È־

# ÿһСʱִÐһ´Îå
# crontab -e
# 0 3 * * * /root/bin/deleteArchiveLogs.sh
# service cron restart

if [ -e  "${PATH_LOG}" ];then
   :
else
   mkdir -p $PATH_LOG
   chown -R oracle:oinstall $PATH_LOG
fi


su - $ORACLE_USER -c "$ORACLE_HOME/bin/rman target / <<! >>${PATH_LOG}/rman_${TAG_DATE}.log
show all;
configure backup optimization on;
configure controlfile autobackup on;
configure retention policy to recovery window of $KEEP_DAYS_RETENTION days;
configure archivelog deletion policy to applied on standby;
delete noprompt obsolete;
crosscheck archivelog all;
delete noprompt archivelog all completed before 'sysdate-$KEEP_DAYS_ARCHIVELOG';
show all;
!
"
echo "!!!please see logfile ${PATH_LOG}/rman_${TAG_DATE}.log"
