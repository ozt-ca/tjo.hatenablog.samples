# -*- coding: utf-8 -*-
"""
Created on Tue Oct 09 16:47:47 2012

@author: A12956
"""

import numpy as np
from numpy import *
from scipy import *
from matplotlib import *
from guidata import *
from guiqwt import *
import matplotlib.pyplot as plt
import matplotlib as mpl

class svm(object):
    """
    SVM with SMO
    The structure of this class is based on a code open on a blog post below.
    (http://d.hatena.ne.jp/se-kichi/20100306/1267858745)
    """
    
    def __init__(self,
                 kenel=lambda x,y:dot(x,y)
                 c=1,
                 tol=0.001,
                 eps=0.04,
                 loop=float('inf')):
        """
        Arguments:
            -'kernel': kernel function (Gaussian)
            -'c': Margin parameter
            -'tol': Tolerance of KKT condition
            -'eps': Tolerance of alpha
            -'loop': Maximum value of iteration
        """
        self._kernel=kernel
        self._c=c
        self._tol=tol
        self._eps=eps
        self._loop=loop
        
    def _Es(self,i):
        output1=self._alpha[i]+self._learn_stlength*(1-(self._ylabel[i]*smargin(self._xlist[i],self._xlist[:,],self._ylabel,self._delta,self._clength)))
        return output1
        
    def _Ks(self,p,q):
        norm_dat=norm(self._xlist[p]-self._xlist[q])
        abs_dat=(norm_dat)^2
        x=(abs_dat)/(2*(self._delta)^2)
        output2=exp(-x)
        return output2
    
    def _takeStep(self,i1,i2):
        if i1==i2:
            return False
        alpha1=self._alpha[i1]
        alpha2=self._alpha[i2]
        y1=self._ylabel[i1]
        y2=self._ylabel[i2]
        
        e1=self._e[i1]
        e2=self._e[i2]
        s=y1*y2
        
    def main_routine(self,xlist,ylabel):
        self._xlist=xlist
        self._ylabel=ylabel
        


def svm_classifier(label,alpha):
    return np.dot(label,alpha) # 単なる内積 w*x
    
def svm_predict(xvec,wvec,x_list,delta,bias,clength):
    wbyx = 0
    for i in range(1,clength):
        wbyx = wbyx + wvec[i]*kernel(xvec,x_list[:,i],delta)
    new_m = wbyx + bias
    if new_m > 0:
        print "Group 1"
    elif new_m < 0:
        print "Group 2"
    else:
        print "On the border"
    return new_m
    
#def svm_smo(x_list,y_list,alpha,delta,Cmax,clength,learn_stlength,loop):
#    idx=np.random.permutation(clength) # idx is an array
#    i1=idx[0]
#    e_list=[0 for i in range(clength)]
# import tjo_smo.py
# tjo_smo.mainRoutine()
    
    return alpha_smo,bias
    

def kernel(x1,x2,delta):
    norm_dat = np.linalg.norm(x1-x2)
    abs_dat = (norm_dat)^2
    p = (abs_dat)/(2*(delta)^2)
    return np.exp(-p)

def soft_margin(fix_v,x_var,alpha_var,y_var,delta,clength):
    marg = 0
    for i in range(1,clength):
        marg = marg + (alpha_var[i]*y_var[i]*kernel(fix_v,x_var[:,i],delta))
    return marg

def Es():
    #

def Ks():
    #

def takeStep():
    #

def updateThreshold():
    #

def updateErrorList():
    #

def examEx():
    #

def secondChoiceHeuristic():
    #

def mainRoutine():
    #




if __name__=='__main__':
    x1_1=ones(50)-1.2*np.random.random(50)
    x1_2=ones(50)-1.2*np.random.random(50)
    x2_1=-ones(50)+1.2*np.random.random(50)
    x2_2=ones(50)-1.2*np.random.random(50)
    x3_1=-ones(50)+1.2*np.random.random(50)
    x3_2=-ones(50)+1.2*np.random.random(50)
    x4_1=ones(50)-1.2*np.random.random(50)
    x4_2=-ones(50)+1.2*np.random.random(50)
    x13_1=r_[x1_1,x3_1]
    x13_2=r_[x1_2,x3_2]    
    x24_1=r_[x2_1,x4_1]
    x24_2=r_[x2_2,x4_2]
    class1=c_[x13_1,x13_2]
    class2=c_[x24_1,x24_2]
    class_all=r_[class1,class2]
    label1=ones(100)
    label2=-1*ones(100)
    label_all=r_[label1,label2]
    
    
    tjo_smo.mainRoutine()
    
    prob = svm_problem(label_all.tolist(),class_all.tolist()) #問題提起：
    param = svm_parameter('-s 0 -t 2 -g 0.5 -c 10') #識別器のパラメータ設定 
    model = svm_train(prob,param) #学習
    testx = [-0.5,-0.5]
    label = svm_predict([1,],[testx],model) #未知データの適用

    xx,yy=meshgrid(linspace(-3,3,500), linspace(-3,3,500))
    
    zz=np.zeros([500,500])
    for i in range(0,499):
        for j in range(0,499):
            labelc=svm_predict([1,],[[xx[i,j],yy[i,j]]],model)
            tmp=labelc[0]
            zz[i,j]=tmp[0]

    plt.scatter(class1[:,0],class1[:,1],marker='o',color='g',s=100)
    plt.scatter(class2[:,0],class2[:,1],marker='s',color='b',s=100)
    plt.scatter(testx[0],testx[1],marker='+',color='r',s=500)
    plt.contour(xx,yy,zz)
    print label
    plt.show()
