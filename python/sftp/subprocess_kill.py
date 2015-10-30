'''
Created on 2015-3-26

@author: liu.yanchao
'''
import subprocess
import time
import os
import signal
from subprocess import call


y = 'y'

filename = input("What file would you to display?\n")
#process = subprocess.Popen(filename)
process = subprocess.Popen("tcpdump -nN -i any -w /tmp/filename",shell=True)
#time.sleep(3)
ans = input("stop it[y/n]:")
if(y == ans):
    os.kill(process.pid,signal.SIGINT)
else:
    exit()