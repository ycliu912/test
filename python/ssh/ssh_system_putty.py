'''
Created on 2015-3-30

@author: liu.yanchao
'''
import paramiko
import os

def MAIN():

    host = '10.30.22.215'
    port = 22
    user = 'root'
    pswd = 'vimicro!@#'

    #os.system('putty -l root -pw vimicro!@# 10.30.22.215')
    
    '''
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, pswd)
    #stdin, stdout, stderr = ssh.exec_command('tcpdump -i eth0 -c 1 net 10.30.22.43')
    stdin,stdout,stderr = ssh.exec_command('python /root/test/tcpdump.py')
    #stdin, stdout, stderr = ssh.exec_command('')
    print(stdout.read())
    ssh.close()
    '''
    
    
    
    t = paramiko.Transport(host,port)
    t.connect(user,pswd)
    sftp = paramiko.SFTPClient.from_transport(t)
    remotepath='/tmp/test.pcap'
    localpath='D:\2\test.pcap'
    sftp.get(remotepath,localpath)
    t.close()
    #dir = os.listdir('D:\2\')
    #print(dir)
    os.system("start D:\\2\\test.pcap")
    
    
if __name__=='__main__':
    try:
        MAIN()
    except Exception as e:
        print('e')
