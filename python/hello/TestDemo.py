'''
Created on 2015-3-24

@author: liu.yanchao
'''
print('Hello World!')

value = 2 + 2

print(value)
print('The value of i is ',value)

def fib(n):
    a,b = 0,1
    while a < n:
        print(a,end=' \n')
        a,b = b,a+b
    print()
tmp = fib(20000)   
print(tmp) 

def ask_ok(prompt,retries=4,complaint='Yes or no,please!'):
    while True:
        ok = input(prompt)
        if ok in ('y','ye','yes'):
            return True
        if ok in ('n','no','nop','nope'):
            return False
        retries = retries - 1
        if retries < 0:
            raise IOError('uncooperative user')
        print(complaint)
           
ask_ok('Do you really want to quit?')
#ask_ok('OK to overwrite the file?',2)
#ask_ok('OK to overwrite the file?',2,'Come on, only yes or no!') 

import os

os.system("net use d:\\10.30.26.24\build\ViSS3.5\temp")




