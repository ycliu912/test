'''
Created on 2015-3-31

@author: liu.yanchao
'''
import paramiko
import os
import sys
from sys import *
import time

host = '10.30.27.135'
port = 922
user = 'root'
pswd = 'laotang@1234'

def ssh(contains):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, pswd)
    #stdin, stdout, stderr = ssh.exec_command('tcpdump -i eth0 -c 1 net 10.30.22.43')
    ans = input("%s" % contains)
    stdin,stdout,stderr = ssh.exec_command("/root/test/pro_tcpdump.sh %s" % ans)
    #time.sleep(5)
    print(stdout.readlines())
    stdout.close()
    stdin.close()
    stderr.close()
    ssh.close()
    
def ssh_invoke(contains):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, pswd)
    #stdin, stdout, stderr = ssh.exec_command('tcpdump -i eth0 -c 1 net 10.30.22.43')
    ans = input("%s" % contains)
    #stdin,stdout,stderr = ssh.exec_command("/root/test/pro_tcpdump.sh %s" % ans)
    #time.sleep(5)
    #print(stdout.readlines())
    channel = ssh.invoke_shell()
    stdin = channel.makefile('wb')
    stdout = channel.makefile('rb')


    stdin.write('''
    cd /root/test
    /root/test/pro_tcpdump.sh %s
    exit
    ''' % ans)
    print(str(stdout.read()))
    
    stdout.close()
    stdin.close()
    ssh.close()
    
def sftp_01():    
    t = paramiko.Transport((host,port))
    t.connect(username = user, password = pswd)
    sftp = paramiko.SFTPClient.from_transport(t)
    remotepath='/tmp/name.pcap'
    #remotepath_01='/root/test_python.pcap'
    localpath='D:\\2\\name.pcap'
    sftp.get(remotepath, localpath)
    #sftp.put(localpath,remotepath_01)
    t.close()

def start():
    os.system("start D:\\2\\name.pcap")
    
#ssh("package name[name]:")
ssh_invoke("type a command[name]:")
ssh("stop it[stop]:")
sftp_01()
start()
    

    
    
    
'''    
if __name__=='__main__':
    try:
        MAIN()
    except Exception as e:
        print('e')
'''