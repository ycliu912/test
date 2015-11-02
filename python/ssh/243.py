'''
Created on 2015-4-2

@author: liu.yanchao
'''
'''
Created on 2015-3-31

@author: liu.yanchao
'''
import paramiko
import os
import sys
from sys import *
import time
import xml.etree.ElementTree as ET

'''
host = '10.30.22.215'
port = 22
user = 'root'
pswd = 'vimicro!@#'
'''

def xml_info(id1):
    tree = ET.parse('D:\\computerinfo.xml')
    root = tree.getroot()

    for computer in root.findall('computer'):
        if id1 == computer.get('id'):
            host = computer.find('host').text
            port = computer.find('port').text
            user = computer.find('user').text
            pswd = computer.find('pswd').text
     
    return(host,port,user,pswd)

def ssh(contains):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, port, user, pswd)
    #stdin, stdout, stderr = ssh.exec_command('tcpdump -i eth0 -c 1 net 10.30.22.43')
    ans = input("%s" % contains)
    stop = 'stop'
    while(ans != stop):
        print("please type [stop] command:\neg:stop it[stop]:stop")
        ans = input("%s" % contains)
        #continue
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
    
    
    #global cur_num,tot_num   
    t = paramiko.Transport((host,port))
    t.connect(username = user, password = pswd)
    sftp = paramiko.SFTPClient.from_transport(t)
    remotepath='/tmp/name.pcap'
    #remotepath_01='/root/test_python.pcap'
    localpath='D:\\2\\name.pcap'
    sftp.get(remotepath, localpath,_callback)
    #sftp.put(localpath,remotepath_01)
    t.close()

def start():
    os.system("start D:\\2\\name.pcap")

'''
def _callback(a,b):
    sys.stdout.write('Data Transmission %10d [%3.2f%%]\r' %(a,a*100./int(b)))
    sys.stdout.flush()
'''

def _callback(cur_num,tot_num):
    #global cur_num,tot_num
    bar_length=20
    #for percent in range(0, 100):
    percent = int(cur_num/tot_num * 100)
    hashes = '#' * int(percent/100.0 * bar_length)
    spaces = ' ' * (bar_length - len(hashes))
    sys.stdout.write("\rPercent: [%s] %d%%"%(hashes + spaces, percent))
    sys.stdout.flush()
    #time.sleep(0.05)
    
#ssh("package name[name]:")
xml_info_value = xml_info('10.30.27.135')

host = xml_info_value[0]
port = int(xml_info_value[1])
user = xml_info_value[2]
pswd = xml_info_value[3]

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