#!/usr/bin/python3

import re
import os
'''
#current dir find keyword in line
def key_word_find(perl_path,keyword):
    filelist = os.listdir(perl_path) #list current dir file
    print(filelist)
    for perl_file in filelist: #
        if ".pl" in perl_file: #only care perl file 
            pl_file = open(perl_path+perl_file) #join path and file 
            for line in pl_file.readlines(): #read every line
                if keyword in line: #if keyword is in this line then print
                    print(perl_file + "\t\t" + line)


key_word_find("./","use")


#recursive find keyword in line
def print_dir_contents(root_path,keyword):
    for schild in os.listdir(root_path):
        schildpath = os.path.join(root_path,schild)
        if os.path.isdir(schildpath):
            print_dir_contents(schildpath,keyword)
        else:
                #print (schildpath)
                #curdir = os.getcwd()
                #print(curdir)
                if (".v") in schildpath or (".pl") in schildpath : #only care perl file 
                    pl_file = open(schildpath) 
                    for line in pl_file.readlines(): #read every line
                        if keyword in line: #if keyword is in this line then print     
                            print(schildpath + "\t\t" + line)


print_dir_contents("./" , "use")



#recursive find pattern in line
def find_pattern(root_path):
    for schild in os.listdir(root_path):
        schildpath = os.path.join(root_path,schild)
        if os.path.isdir(schildpath):
            find_pattern(schildpath)
        else:
                #print (schildpath)
                #curdir = os.getcwd()
                #print(curdir)
                if (".v") in schildpath or (".pl") in schildpath : #only care perl file 
                    pl_file = open(schildpath) 
                    for line in pl_file.readlines(): #read every line
                         m=re.match(r'^use\s(\w+)\:\:(\w+)',line)
                         if m :
                            print(m.string)
                            print(m.expand(r'\1'))             
                            print(m.expand(r'\2'))             

find_pattern("./")


'''


a="test test---"
print(a,end="")
b="test"
print (b*3)
c="test"*3
print(c)

a=r"test test test \n"
print(a,end="")


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

