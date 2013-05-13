# -*- coding: utf-8 -*-
"""
Created on Mon Mar 25 13:18:37 2013

@author: A12956
"""

import sys
import csv
import re

# re.split('\t|,',str) can split strings by multiple delimiters such as tab & comma.

#class excel(Dialect):
#    """Describe the usual properties of Excel-generated CSV files."""
#    delimiter = ','
#    quotechar = '"'
#    doublequote = True
#    skipinitialspace = False
#    lineterminator = '\r\n'
#    quoting = QUOTE_MINIMAL

filename1=sys.argv[1]   # csv files: delimiter should be tab or capital T
filename2=sys.argv[2]   # output file: delimiter will be tabs
client_list=sys.argv[3] # client_id list: delimiter should be tabs

graphList=list(csv.reader(file(filename1),delimiter='\t'))
glength=len(graphList)
graphOut =[]

clientList=list(csv.reader(file(client_list),delimiter='\t'))

"""
For the first time, we have to extract time stamps
"""

fp_tmp=open('dump1.txt','w')
for xt in graphList:
    fp_tmp.write(str(xt[1])+'\n')
fp_tmp.close()
timeListtmp1=list(csv.reader(file('dump1.txt','r'),delimiter='.'))
fp_tmp=open('dump2.txt','w')
for xt in timeListtmp1:
    fp_tmp.write(str(xt[0])+'\n')
fp_tmp.close()
timeListtmp2=list(csv.reader(file('dump2.txt','r'),delimiter='T'))
fp_tmp=open('dump3.txt','w')
for xt in timeListtmp2:
    fp_tmp.write(str(xt[0])+'\t'+str(xt[1])+'\n')
fp_tmp.close()

timeList=list(csv.reader(file('dump3.txt','r'),delimiter='\t'))

"""
Main procedure below
"""

def convert_client(graphStr,clientList):    #clientList should be a list
    for x in clientList:
        if graphStr==x[0]:
            return x[1]

for i in range(glength):
    if i < glength-1:
        if graphList[i][0]==graphList[i+1][0]:
            if timeList[i]!=timeList[i+1] and graphList[i][2]!=graphList[i+1][2]:
                graphOut.append([graphList[i][0],convert_client(graphList[i][2],clientList),convert_client(graphList[i+1][2],clientList),timeList[i][0],timeList[i][1]])
        elif graphList[i][0]!=graphList[i+1][0]:
            graphOut.append([graphList[i][0],convert_client(graphList[i][2],clientList),'No',timeList[i][0],timeList[i][1]])
    elif i==glength-1:
        graphOut.append([graphList[i][0],convert_client(graphList[i][2],clientList),'No',timeList[i][0],timeList[i][1]])

print graphOut[1]
        
fp = open(filename2,'w')
for x in graphOut:
    fp.write(str(x[0])+'\t'+str(x[1])+'\t'+str(x[2])+'\t'+str(x[3])+'\t'+str(x[4])+'\n')
fp.close()
