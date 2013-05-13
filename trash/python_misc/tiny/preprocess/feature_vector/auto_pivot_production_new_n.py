# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 11:24:18 2013

@author: A12956
"""

import sys
import csv

filename1=sys.argv[1]   # csv files: delimiter should be tabs
filename2=sys.argv[2]   # output file: delimiter will be tabs
client_list=sys.argv[3] # client_id list: delimiter should be tabs

rawList=list(csv.reader(file(filename1),delimiter='\t'))
rlength=len(rawList)
clientList=list(csv.reader(file(client_list),delimiter='\t'))
tmpList=[]
pivotOut=[]

def convert_client(appStr,clientList):    #clientList should be a list
    for x in clientList:
        if appStr==x[0]:
            return x[1]

if __name__=='__main__':
    for i in range(rlength):
        if i < rlength-1:
            # 同じUserIDが同じアプリを繰り返した場合は1回だけカウントして後は無視する
            # 即ち rawList[i][0]==rawList[i+1][0] and rawList[i][1]==rawList[i+1][1]
            # のみが無視の対象で、残りは全てカウントしなければならない
            if i==0:
                # 先頭は無条件にカウントする
                tmpList.append([rawList[i][0],rawList[i][1]])
            elif i > 0 and rawList[i][0]!=rawList[i-1][0]:
                # そもそもあるUserIDが直前と違ったらカウントする
                tmpList.append([rawList[i][0],rawList[i][1]])
            elif i> 0 and rawList[i-1][0]!=rawList[i][0]:
                # そもそもあるアプリが直前と違ったらカウントする
                tmpList.append([rawList[i][0],rawList[i][1]])
            elif i > 0 and rawList[i][0]==rawList[i-1][0]:
                # 同じUserIDが続く場合。。。
                if rawList[i][1]!=rawList[i-1][1]:
                    # アプリが違う場合はカウントする
                    tmpList.append([rawList[i][0],rawList[i][1]])
            elif i > 0 and rawList[i][1]==rawList[i-1][1]:
                # 同じアプリが続く場合。。。
                if rawList[i][0]!=rawList[i-1][0]:
                    # UserIDが違う場合はカウントする
                    tmpList.append([rawList[i][0],rawList[i][1]])
        elif i == rlength-1:
            if rawList[i-1][1]!=rawList[i][1]:
                # 最後もそもそもUserIDかアプリが直前と違った場合はカウントする
                tmpList.append([rawList[i][0],rawList[i][1]])
            elif rawList[i-1][0]!=rawList[i][0]:
                tmpList.append([rawList[i][0],rawList[i][1]])
    # ここまでOK!!!!!

    ft = open('dump_pivot.txt','w')
    for x in tmpList:
        ft.write(str(x[0])+'\t'+str(convert_client(x[1],clientList))+'\n')
    ft.close()
    
    tlength=len(tmpList)
    clength=len(clientList)
    eachCount=[0 for i in range(clength)]
    poolCount=[0 for i in range(clength)]
        
    for m in range(tlength):
        if m < tlength-1:
            if m == 0 and tmpList[m][0]==tmpList[m+1][0]:
                for n in range(clength):
                    if tmpList[m][1]==clientList[n][0]:
                        eachCount[n]=1
                    if tmpList[m][1]!=clientList[n][0]:
                        eachCount[n]=0
                for r in range(clength):
                    poolCount[r]=poolCount[r]+eachCount[r]
            elif m == 0 and tmpList[m][0]!=tmpList[m+1][0]:
                for n in range(clength):
                    if tmpList[m][1]==clientList[n][0]:
                        eachCount[n]=1
                    if tmpList[m][1]!=clientList[n][0]:
                        eachCount[n]=0
                for r in range(clength):
                    poolCount[r]=poolCount[r]+eachCount[r]
                pivotOut.append([tmpList[m][0]]+poolCount)
                eachCount=[0 for i in range(clength)]
                poolCount=[0 for i in range(clength)]
            elif m > 0 and tmpList[m][0]==tmpList[m+1][0]:
                for n in range(clength):
                    if tmpList[m][1]==clientList[n][0]:
                        eachCount[n]=1
                    if tmpList[m][1]!=clientList[n][0]:
                        eachCount[n]=0
                for r in range(clength):
                    poolCount[r]=poolCount[r]+eachCount[r]
            elif m > 0 and tmpList[m][0]!=tmpList[m+1][0]:
                for n in range(clength):
                    if tmpList[m][1]==clientList[n][0]:
                        eachCount[n]=1
                    if tmpList[m][1]!=clientList[n][0]:
                        eachCount[n]=0
                for r in range(clength):
                    poolCount[r]=poolCount[r]+eachCount[r]
                pivotOut.append([tmpList[m][0]]+poolCount)
                eachCount=[0 for i in range(clength)]
                poolCount=[0 for i in range(clength)]
        elif m == tlength-1:
            for n in range(clength):
                if tmpList[m][1]==clientList[n][0]:
                    eachCount[n]=1
                if tmpList[m][1]!=clientList[n][0]:
                    eachCount[n]=0
            for r in range(clength):
                poolCount[r]=poolCount[r]+eachCount[r]
            pivotOut.append([tmpList[m][0]]+poolCount)
                
    fp = open(filename2,'w')
    fp.write('UserID'+'\t')
    for r in range(clength):
        fp.write(str(clientList[r][1])+'\t')
    fp.write('YN'+'\n')
    for p in range(len(pivotOut)):
        for q in range(clength+1):
            fp.write(str(pivotOut[p][q])+'\t')
        fp.write('No'+'\n')
    fp.close()
    