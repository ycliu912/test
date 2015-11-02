'''
Created on 2015-3-24

@author: liu.yanchao
'''

#!/usr/bin/python
# -*- coding:utf-8 -*-
# cp@chenpeng.info

import paramiko
import os
import sys
from sys import *

def MAIN():

    host = '10.30.22.215'
    port = 22
    user = 'root'
    pswd = 'vimicro!@#'

    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, pswd)
    #stdin, stdout, stderr = ssh.exec_command('tcpdump -i eth0 -c 1 net 10.30.22.43')
    stdin,stdout,stderr = ssh.exec_command("/root/test/tcpdump.py test")
    #stdin, stdout, stderr = ssh.exec_command('')
    print(stdout.readlines())
    ans = input("please type name:\n")
    stdin.write('ans')
    
    ssh.close()
    
    #os.system('putty -l root -pw vimicro!@# -m D:\\2\\cc.sh 10.30.22.215')
    '''
    t = paramiko.Transport((host,port))

    t.connect(username = user, password = pswd)

    sftp = paramiko.SFTPClient.from_transport(t)

    remotepath='/tmp/test.pcap'
    #remotepath_01='/root/test_python.pcap'

    localpath='D:\\2\\test.pcap'

    sftp.get(remotepath, localpath)
#   sftp.put(localpath,remotepath_01)

    t.close()

    os.system("start D:\\2\\test.pcap")
    
    '''
    
if __name__=='__main__':
    try:
        MAIN()
    except Exception as e:
        print('e')
