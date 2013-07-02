# -*- coding: utf-8 -*-
"""
Created on Wed Oct 10 11:39:21 2012

"""

import cv

storage=cv.CreateMemStorage()

if __name__ == '__main__':
    hc=cv.Load("C:\OpenCV2.2\data\haarcascades\haarcascade_frontalface_alt.xml")
    img=cv.LoadImage("running_club.jpg")
    faces=cv.HaarDetectObjects(img,hc,storage,1.1,5,0,(5,5))
    
    color=(0,0,255)
    
    for (x,y,w,h), n in faces:
        p1 = (x,y)
        p2 = (x+w, y+h)
        cv.Rectangle(img,p1,p2,color,thickness=5)
    cv.SaveImage("face_detected2.jpg",img)
    