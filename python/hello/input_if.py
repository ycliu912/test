'''
Created on 2015-3-26

@author: liu.yanchao
'''
#!/usr/bin/python

number = 23

guess = int(input("Enter an integer:\n"))
if guess == number:
    print("Congratulations,you gussed it.") #new block starts here
    print("but you do not win any prizes!") #new block ends here
elif guess < number:
    print("No,it is a little higher than that")
    # you can do whatever you want in a black
else:
    print("No,it is a little lower than that")
    # you must have guess > number to reach here
print("Done")
#This last statement is always executed,after the if statement is executed