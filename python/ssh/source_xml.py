'''
Created on 2015-4-3

@author: liu.yanchao
'''
#-*-conding: utf-8 -*-

import xml.etree.ElementTree as ET
#from xml.etree.ElementTree import ElementTree
#from xml.etree import ElementTree
#import xml.etree.ElementTree as xml 
#from xml.etree.ElementTree import ElementTree as ET

def xml_info(id1):
    tree = ET.parse('D:\\computerinfo.xml')
    root = tree.getroot()
    tag = root.tag 
    attrib = root.attrib

    for child in root:
        print(child.tag,child.attrib)
    
    for computer in root.findall('computer'):
        if id1 == computer.get('id'):
            #host = computer.get('host')
            #port = computer.get('port')
            #user = computer.get('user')
            #pswd = computer.get('pswd')
    
            host = computer.find('host').text
            port = computer.find('port').text
            user = computer.find('user').text
            pswd = computer.find('pswd').text
     
            print(id1,host,port,user,pswd)
    
    for intro in root.iter('intro'):
        new_intro = 'test'
        intro.text = str(new_intro)
        intro.set('updated','yes')
    tree.write('D:\\computerinfo.xml')
    
#xml_info('001')
xml_info('002')
    
