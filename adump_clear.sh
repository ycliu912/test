#!/bin/bash



path_adump_clear_sh="/opt/oracle"


role_user=`whoami`

if [ "${role_user}" == "oracle" ];then
   :
else
   echo "please as user oracle run this script!"
   exit 1
fi

path_oracle_base=$ORACLE_BASE

  
path_adump=`find ${path_oracle_base}/* | grep adump$`

#echo $path_adump

adump_size=`cd $path_adump;du -h | awk '{print $1}'` 

#echo $adump_size

clear

cat <<!
`date`                                            
--------------------adump info-------------------------
path_adump             $path_adump
adump_size             $adump_size
!

read -p "do you want to clear up?[y/n]"  ans
case $ans in
y)
  echo "how many days do you want to keep ?"
  echo "please type a number,at least 1 day."
  read answer
   
  if [ 1 -le "${answer}" ]; then
      :
  else
      echo "please type a number,like 1"
      exit 1
  fi
   

  echo "Please wait a moment..."
  cd $path_adump || echo "$path_adump doesn't right. `exit 1`" 
  find . -name "*.aud" -mtime +${answer} -exec rm -f {} \; 
  
  bash ${path_adump_clear_sh}/adump_clear.sh
  ;;
n) 
  exit 0 
  ;;
*) 
  echo "error choice"
  ;;
esac
