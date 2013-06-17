# -*- coding: utf-8 -*-

import numpy as np
from numpy import *
from scipy import *
import sys
import random
from scipy import *
from scipy.linalg import norm
import matplotlib.pyplot as plt

class svm(object):
    """
    Support Vector Machine
    using SMO Algorithm.
    Courtesy of http://d.hatena.ne.jp/se-kichi/20100306/1267858745
    """

    def __init__(self,
                 kernel=lambda x,y:dot(x,y),
                 c=10000,
                 tol=1e-2,
                 eps=1e-2,
                 loop=float('inf')):
        """
        Arguments:
        - `kernel`: カーネル関数
        - `c`: パラメータ
        - `tol`: KKT条件の許容する誤差
        - `eps`: αの許容する誤差
        - `loop`: ループの上限
        """
        self._kernel = kernel
        self._c = c
        self._tol = tol
        self._eps = eps
        self._loop = loop


    def _takeStep(self, i1, i2):
        if i1 == i2:
            return False
        alph1 = self._alpha[i1]
        alph2 = self._alpha[i2]
        y1 = self._target[i1]
        y2 = self._target[i2]
        e1 = self._e[i1]
        e2 = self._e[i2]
        s = y1 * y2

        if y1 != y2:
            L = max(0, alph2 - alph1)
            H = min(self._c, self._c-alph1+alph2)
        else:
            L = max(0, alph2 + alph1 - self._c)
            H = min(self._c, alph1+alph2)

        if L == H:
            return False

        k11 = self._kernel(self._point[i1], self._point[i1])
        k12 = self._kernel(self._point[i1], self._point[i2])
        k22 = self._kernel(self._point[i2], self._point[i2])
        eta = 2 * k12 - k11 - k22
        if eta > 0:
            return False

        a2 = alph2 - y2 * (e1 - e2) / eta

        a2 = min(H, max(a2, L))

        if abs(a2 - alph2) < self._eps * (a2 + alph2 + self._eps):
            return False
        a1 = alph1 + s * (alph2 - a2)

        # update
        da1 = a1 - alph1
        da2 = a2 - alph2

        self._e += array([(da1 * self._target[i1] * self._kernel(self._point[i1], p) +
                           da2 * self._target[i2] * self._kernel(self._point[i2], p))
                          for p in self._point])

        self._alpha[i1] = a1
        self._alpha[i2] = a2
        return True

    def _search(self, i, lst):
        if self._e[i] >= 0:
            return reduce(lambda j,k: j if self._e[j] < self._e[k] else j, lst)
        else:
            return reduce(lambda j,k: j if self._e[j] > self._e[k] else j, lst)

    def _examinEx(self, i2):
        y2 = self._target[i2]
        alph2 = self._alpha[i2]
        e2 = self._e[i2]
        r2 = e2*y2
        if ((r2 < -self._tol and alph2 < self._c - self._eps) or
            (r2 > self._tol and alph2 > self._eps)):
            alst1 = [i for i in range(len(self._alpha))
                     if self._eps < self._alpha[i] < self._c - self._eps]
            if alst1:
                i1 = self._search(i2, alst1)
                if self._takeStep(i1, i2):
                    return True
                random.shuffle(alst1)
                for i1 in alst1:
                    if self._takeStep(i1, i2):
                        return True

            alst2 = [i for i in range(len(self._alpha))
                     if (self._alpha[i] <= self._eps or
                         self._alpha[i] >= self._c - self._eps)]
            random.shuffle(alst2)
            for i1 in alst2:
                if self._takeStep(i1, i2):
                    return True
        return False

    def _calc_b(self):
        self._b = 0.0
        for i in self._m:
            self._b += self._target[i]
            for j in self._s:
                self._b -= (self._alpha[j]*self._target[j]*
                            self._kernel(self._point[i], self._point[j]))
        self._b /= len(self._m)

    def calc(self, x):
        ret = self._b
        for i in self._s:
            ret += (self._alpha[i]*self._target[i]*
                    self._kernel(x, self._point[i]))
        return ret

    def learn(self, point, target):

        self._target = target
        self._point = point

        self._alpha = zeros(len(target), dtype=float)
        self._b = 0
        self._e = -1*array(target, dtype=float)
        changed = False
        examine_all = True
        count = 0

        while changed or examine_all:
            count += 1
            if count > self._loop:
                break

            changed = False

            if examine_all:
                for i in range(len(self._target)):
                    changed |= self._examinEx(i)
            else:
                for i in (j for j in range(len(self._target))
                          if self._eps < self._alpha[j] < self._c - self._eps):
                    changed |= self._examinEx(i)

            if examine_all:
                examine_all = False
            elif not changed:
                examine_all = True

        self._s = [i for i in range(len(self._target))
                   if self._eps < self._alpha[i]]
        self._m = [i for i in range(len(self._target))
                   if self._eps < self._alpha[i] < self._c - self._eps]
        self._calc_b()

    def _get_s(self):
        return self._s

    s = property(_get_s)

    def _get_m(self):
        return self._m

    m = property(_get_m)

    def _get_alpha(self):
        return self._alpha

    alpha = property(_get_alpha)




if __name__=='__main__':
    try:
        import psyco
        psyco.full()
    except ImportError:
        pass

    s = svm(c=1, kernel=lambda x,y:exp(-norm(x-y)/4))    

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
    s.learn(p, t)

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