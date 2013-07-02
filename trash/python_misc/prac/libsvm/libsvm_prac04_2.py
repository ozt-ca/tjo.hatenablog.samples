# -*- coding: utf-8 -*-
"""
Created on Tue Oct 09 16:47:47 2012

"""

import cv
import numpy as np
from numpy import *
from scipy import *
from matplotlib import *
from guidata import *
from guiqwt import *
from svm import *
from svmutil import *
import matplotlib.pyplot as plt
import matplotlib as mpl
 
if __name__=='__main__':
    x1_1=ones(50)-1.2*np.random.random(50)
    x1_2=ones(50)-1.2*np.random.random(50)
    x2_1=-ones(50)+1.2*np.random.random(50)
    x2_2=ones(50)-1.2*np.random.random(50)
    x3_1=-ones(50)+1.2*np.random.random(50)
    x3_2=-ones(50)+1.2*np.random.random(50)
    x4_1=ones(50)-1.2*np.random.random(50)
    x4_2=-ones(50)+1.2*np.random.random(50)
    class1=c_[x1_1,x1_2]
    class2=c_[x2_1,x2_2]
    class3=c_[x3_1,x3_2]
    class4=c_[x4_1,x4_2]
    class_all=r_[class1,class2,class3,class4]
    label1=ones(50)
    label2=2*ones(50)
    label3=3*ones(50)
    label4=4*ones(50)
    label_all=r_[label1,label2,label3,label4]
    prob = svm_problem(label_all.tolist(),class_all.tolist()) #問題提起：
    param = svm_parameter('-s 0 -t 2 -g 0.5 -c 10') #識別器のパラメータ設定 
    model = svm_train(prob,param) #学習
    testx = [-0.5,-0.5]
    label = svm_predict([3,],[testx],model) #未知データの適用

    xx,yy=meshgrid(linspace(-3,3,500), linspace(-3,3,500))
    
    zz=np.zeros([500,500])
    for i in range(0,499):
        for j in range(0,499):
            labelc=svm_predict([1,],[[xx[i,j],yy[i,j]]],model)
            tmp=labelc[0]
            zz[i,j]=tmp[0]

    plt.scatter(class1[:,0],class1[:,1],marker='o',color='g',s=100)
    plt.scatter(class2[:,0],class2[:,1],marker='s',color='b',s=100)
    plt.scatter(class3[:,0],class3[:,1],marker='o',color='k',s=100)
    plt.scatter(class4[:,0],class4[:,1],marker='s',color='m',s=100)
    plt.scatter(testx[0],testx[1],marker='+',color='r',s=1000)
    plt.contour(xx,yy,zz)
    print label
    plt.show()
