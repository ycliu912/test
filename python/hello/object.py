'''
Created on 2015-3-27

@author: liu.yanchao
'''
class Bird(object):
    have_feather = True
    way_of_reproduction = 'egg'
    def move(self,dx,dy):
        position = [0,0]
        position[0] = position[0] + dx
        position[1] = position[1] + dy
        return position
    

class Chicken(Bird):
    way_of_move = 'walk'
    possible_in_KFC = True

class Oriole(Bird):
    way_of_move = 'fly'
    possible_in_KFC = False
    
summer = Bird()
print(summer.way_of_reproduction)
print('alter move:',summer.move(55, 55))

summer = Chicken()
print(summer.have_feather)
print(summer.move(33,33))


class happyBird(Bird):
    def __init__(self,more_words):
        print('We are happy birds,',more_words)

summer = happyBird('Happy,Happy!')

class Human(object):
    laugh = 'hahahaha'
    def __init__(self,input_gender):
        self.gender = input_gender
    def printGender(self):
        print(self.gender)
        
    def show_laugh(self):
        print(self.laugh)
    def laugh_3th(self):
        for i in range(3):
            self.show_laugh()
            
#li_lei = Human()
#li_lei.laugh_3th()

li_lei = Human('male')
print(li_lei.gender)
li_lei.printGender()