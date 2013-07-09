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
                 delta=2,
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
        self._elist=
        self._clength=
        
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
        
        e1=self._Es[i1]
        e2=self._Es[i2]
        s=y1*y2
        
        gamma=alpha1+alpha2*s
        
        if s==1:
            L=max(0, alpha1+alpha2-self._c)
            H=min(self._c, alpha2+alpha1) 
            
        else:
            L=max(0, alpha2-alpha1)
            H=min(self._c, self._c+alpha2-alpha1)
            
        if L==H:
            return null
        
        k11=self._Ks(i1,i1)
        k12=self._Ks(i1,i2)
        k22=self._Ks(i2,i2)
        
        eta=k11+k22-2*k12
        
        if eta>0:
            a2=alpha2+y2*(e1-e2)/eta
            a2=min(max(a2,L),H)
        else:
            Lobj=gamma-s*L+L-0.5*k11*(gamma-s*L)^2-0.5*k22*L^2-s*k12*(gamma-s*L)*L-y1*(gamma-s*L)
            Hobj=gamma-s*H+H-0.5*k11*(gamma-s*H)^2-0.5*k22*H^2-s*k12*(gamma-s*H)*H-y1*(gamma-s*H)
            if Lobj<Hobj-eps:
                a2=L
            elif Lobj>Hobj+eps:
                a2=H
            else:
                a2=alpha2
        
        if abs(a2-alpha2)<eps*(a2+alpha2+eps):
            return null
            
        a1=alpha1+s*(alpha2-a2)
        
        self._updateThreshold(i1,i2,a1,a2)
        alpha[i1]=a1
        alpha[i2]=a2
        self._updateErrorList
        
        return 1
    
        
    def _updateThreshold(self,i1,i2,a1,a2):
        alph1=self._alpha[i1]
        alph2=self._alpha[i2]
        y1=self._ylabel[i1]
        y2=self._ylabel[i2]
        
        e1=self._Es(i1)-y1
        e2=self._Es(i2)-y2
        
        b1=e1+y1*(a1-alph1)*self._Ks(i1,i1)+y2*(a2-alph2)*self._Ks(i1,i2)
        b2=e2+y1*(a1-alph1)*self._Ks(i1,i2)+y2*(a2-alph2)*self._Ks(i2,i2)
        
        if b1==b2:
            self._bias=b1
        else:
            self._bias=(b1+b2)/2
        
        
    def _updateErrorList(self):
        for j in range(1,self._clength):
            self._
        
        
    def _examEx(self,i2):
    
        
    def _secondChoiceHeuristic(self,i2):
        
        
    def main_routine(self,xlist,ylabel):
        self._xlist=xlist
        self._ylabel=ylabel
        





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
    
    
    p = class_all
    t = label_all
    s.main_routine(p, t)

    for i in range(len(p)):
        c = 'r' if t[i] > 0 else 'b'
        plt.scatter([p[i][0]], [p[i][1]], color=c)

    X, Y = meshgrid(arange(-2.5, 2.5, 00.1), arange(-2.5, 2.5, 00.1))
    w, h = X.shape
    X.resize(X.size)
    Y.resize(Y.size)
    Z = array([s.calc([x, y]) for (x, y) in zip(X, Y)])
    X.resize((w, h))
    Y.resize((w, h))
    Z.resize((w, h))

    CS = plt.contour(X, Y, Z, [0.0],
                     colors = ('k'),
                     linewidths = (3,),
                     origin = 'lower')

    plt.xlim(-2.5, 2.5)
    plt.ylim(-2.5, 2.5)
    plt.show()

    print s.alpha