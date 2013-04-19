# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt

def predict(wvec,xvec):
    out=np.dot(wvec,xvec)
    if out>=0:
        res=1
    else:
        res=-1
    return [res,out]

def train(wvec,xvec,label):
    [res,out]=predict(wvec,xvec)
    if out*label<0:
        wtmp=wvec+0.5*label*xvec
        return wtmp
    else:
        return wvec

if __name__=='__main__':
    
    item_num=100
    loop=1000
    init_wvec=[1,-1,1]
    
    x1_1=np.ones(int(item_num/2))+10*np.random.random(int(item_num/2))
    x1_2=np.ones(int(item_num/2))+10*np.random.random(int(item_num/2))
    x2_1=-np.ones(int(item_num/2))-10*np.random.random(int(item_num/2))
    x2_2=-np.ones(50)-10*np.random.random(int(item_num/2))
    z=np.ones(int(item_num/2))

    x1=np.c_[x1_1,x1_2,z]
    x2=np.c_[x2_1,x2_2,z]
    class_x=np.array(np.r_[x1,x2])
    label1=np.ones(int(item_num/2))
    label2=-1*np.ones(int(item_num/2))
    label_x=np.array(np.r_[label1,label2])

    wvec=np.vstack((init_wvec,init_wvec))
    
    for j in range(loop):
        for i in range(item_num):
            wvec_new=train(wvec[-1],class_x[i,:],label_x[i])
            wvec=np.vstack((wvec,wvec_new))
    w=wvec[-1]
    print w

    x_fig=range(-15,16)
    y_fig=[-(w[1]/w[0])*xi-(w[2]/w[1]) for xi in x_fig]

    plt.scatter(x1[:,0],x1[:,1],marker='o',color='g',s=100)
    plt.scatter(x2[:,0],x2[:,1],marker='s',color='b',s=100)
    plt.plot(x_fig,y_fig)
    plt.show()