# -*- coding: utf-8 -*-
"""
Created on Mon Mar 25 13:18:37 2013

@author: A12956
"""

import sys
import csv

filename1=sys.argv[1]   # csv files: delimiter should be tab or capital T
filename2=sys.argv[2]   # output file: delimiter will be tabs
client_list=sys.argv[3] # client_id list: delimiter should be tabs

graphList=list(csv.reader(file(filename1),delimiter='\t'))
glength=len(graphList)
graphOut =[]

clientList=list(csv.reader(file(client_list),delimiter='\t'))

"""
Main procedure below
"""

def convert_client(graphStr,clientList):    #clientList should be a list
    for x in clientList:
        if graphStr==x[0]:
            return x[1]

for i in range(glength):
    if i == 0:
        graphOut.append([graphList[i][0],'First','TVCM',graphList[i][1],graphList[i][2]])
        graphOut.append([graphList[i][0],'TVCM',convert_client(graphList[i+1][3],clientList),graphList[i][1],graphList[i][2]])
    elif i < glength-1 and i > 0:
        if graphList[i][0]!=graphList[i-1][0]:
            graphOut.append([graphList[i][0],'First','TVCM',graphList[i][1],graphList[i][2]])
            graphOut.append([graphList[i][0],'TVCM',convert_client(graphList[i+1][3],clientList),graphList[i][1],graphList[i][2]])
        elif graphList[i][0]==graphList[i+1][0]:
            if graphList[i][2]!=graphList[i+1][2] and graphList[i][3]!=graphList[i+1][3]:
                graphOut.append([graphList[i][0],convert_client(graphList[i][3],clientList),convert_client(graphList[i+1][3],clientList),graphList[i][1],graphList[i][2]])
        elif graphList[i][0]!=graphList[i+1][0]:
            graphOut.append([graphList[i][0],convert_client(graphList[i][3],clientList),'CV',graphList[i][1],graphList[i][2]])
        elif graphList[i][0]!=graphList[i-1][0]:
            graphOut.append([graphList[i][0],'First',convert_client(graphList[i][3],clientList),graphList[i][1],graphList[i][2]])
    elif i==glength-1:
        graphOut.append([graphList[i][0],convert_client(graphList[i][3],clientList),'CV',graphList[i][1],graphList[i][2]])

print graphOut[1]
        
fp = open(filename2,'w')
for x in graphOut:
    fp.write(str(x[0])+'\t'+str(x[1])+'\t'+str(x[2])+'\t'+str(x[3])+'\t'+str(x[4])+'\n')
fp.close()
