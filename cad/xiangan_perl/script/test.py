#!/usr/bin/python3

import re


def print_dir_contents(root_path):
    import os
    for schild in os.listdir(root_path):
        schildpath = os.path.join(root_path,schild)
        if os.path.isdir(schildpath):
            print_dir_contents(schildpath)
        else:
            print (schildpath)
            curdir = os.getcwd()
            print(curdir)



print_dir_contents("./")




'''
pat=re.compile(r'\w+\stest')
match=pat.match('hello test 123')
if match:
    print (match.group())
    print (11111)


test="hello 1234"


m=re.match(r'hello' , test )
print(m.group())










def add2 (a,b=5):
    ret = a + b
    return ret     #reture value

val = add2(10,)
print(val)




def add_sum (data_sum):
    acc=1
    for v in data_sum :
        acc=acc*v    
    return acc     #reture value

data_set=[1,2,3,4,5]
val = add_sum(data_set)
print(val)








for v in range(5):
    print (v)
    v=v+2
    print (v)

    
message_1 = """ Test 1 !\\ """
print (message_1 + "\n\n\n\n")

#message_2 = '   "Test 2 !"   '
#print (message_2.strip())
#
#hebing = message_1 + message_2
#print (hebing.upper())
#print (hebing.lower())
#    
#my_number = 27
#print ("my favorite number is" + str(my_number) + "!")



dynasty = ['tang','song','yuan', 'ming','qing']
length=len(dynasty)
print(dynasty)
print(length)

for chaodai in dynasty:
        print("chaodai\n")
        print("chaodai is  " + chaodai.title() + "\n")


for value in range(1,5):
    print (value)    
for value in range(1,5,2):
    print (value)    

for value in range(5,1,-1):
    print (value)    



'''

