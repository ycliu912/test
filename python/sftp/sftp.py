'''
Created on 2015-3-26

@author: liu.yanchao
'''

import paramiko
import os
import subprocess

def MAIN():

        host = '10.30.22.215'
        port = '22'
        user = 'root'
        pswd = 'vimicro!@#' 

        t = paramiko.Transport((host,22))

        t.connect(username = user, password = pswd)

        sftp = paramiko.SFTPClient.from_transport(t)

        remotepath='/tmp/test.pcap'
        #remotepath_01='/root/test_python.pcap'

        localpath='D:\\2\\test.pcap'

        sftp.get(remotepath, localpath)
#        sftp.put(localpath,remotepath_01)

        t.close()

        os.system("start D:\\2\\test.pcap")
        #subprocess.call("start","cmd")
    
if __name__=='__main__':
    try:
        MAIN()
    except Exception as e:
        print('e')

