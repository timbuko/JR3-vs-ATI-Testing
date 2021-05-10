#This code does the same thing ast ReadTachData.py, but this one uses panda to write to csv
#This code allows you to choose the output path (line 58) and out puts to tach_data_x.csv

import time
import math
import numpy as np
import matplotlib.pyplot as plt #requires download
import serial                   #requires download
import os
import pandas as pd
import seqfile
import sys

base_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.insert(0, base_dir)

plt.style.use('ggplot') #Adds grid to plots
print('Loading.....')

def main(): #Saves data to csv file and plots data vs time
    t=0
    incoming=0
    line1=[]


    RPM=[]   #initialize data
    Time=[]
    data={"Time":Time,"RPM":RPM}

    iTime=time.time()
    try:
            ArduinoSerial = serial.Serial(port='COM9', baudrate=9600)# NUMBER 0 ###############  NUMBER 0
            #### Check COM in use with arduino app  ######
            ArduinoSerial.flushInput()
            print('Recording Data...')
            print('Press Ctrl c to finish recording')
            ii=0
            while 1:
                ser_bytes = ArduinoSerial.readline() #reads data from arduino
                incoming = str(ser_bytes[0:len(ser_bytes)-2].decode("utf-8")) #has -2 to get rid of '\n'
                [a,t]=sepIncoming(incoming) #if more sensors used have to edit function
                A=a
                t=str(int(t)/1000)

                data["Time"].append(t)
                data["RPM"].append(A)


##                line1=live_plotter_xy(tim,Adata,PortA,line1) # NUMBER 5.1 ###################### NUMBER 5.1
##                ii+=1
##                if ii>120:    #set time to take data
##                    break

    except:
        if time.time()-iTime < 2:
            print('There was an error, check connections and restart')
        else:
            in_path = os.path.expanduser('~\Documents\Aero Reasearch\JR3-vs-ATI-Testing\Tachometer\\tach_data')  ######Edit where file saves here ##########
            dataName=seqfile.findNextFile(in_path, prefix='tach_data_', suffix='.csv')
            out_path = dataName #saves file here
            data.to_csv(out_path)

            print('Data saved to {}\n'.format(dataName))
            plotter(data["Time"],data["RPM"],'RPM','Plot 1')



def plotter(x,y,dataLabel,setLabel):
    """
    Input x,y data and Ylabel
    """
    plt.scatter(x,y,label=dataLabel,color='r') #Label is what shows up in legend
    plt.xlabel('Time(ms)')
    plt.ylabel(dataLabel)
    plt.title('{} vs time'.format(dataLabel))
##    plt.legend()
    plt.show()

def sepIncoming(incoming):
    """
    Separate incoming arduino data into each data set
    """
    i=0
    while i<len(incoming):
        if incoming[i]=='r': #sensor in pin A0
            a=''
            i+=1
            while i<len(incoming): #reads digits after 'a' to variable a
                try:
                    temp=int(incoming[i])
                    a+=incoming[i]
                    i+=1
                except:
                    break
        elif incoming[i] == 't': #sensor in pin A1
            t=''
            i+=1
            while i<len(incoming):
                try:
                    temp=int(incoming[i])
                    t+=incoming[i]
                    i+=1
                except:
                    break

    return [a,t]



def mp(value, oldMin, oldMax, newMin, newMax):
    """
    mapping function
    """
    oldSpan = oldMax - oldMin
    newSpan = newMax - newMin
    valueScaled = float(value - oldMin) / float(oldSpan) #slope of old
    return newMin + (valueScaled * newSpan)              #y=mx+b

def live_plotter_xy(x_val,y1_data,dataLabel,line1):
    """
    Live plot of incoming data; Pass updated list of data points each loop
    """
    if line1==[]:
        # allows dynamic plotting
        plt.ion()  
        # intial set up figure and plot
        fig = plt.figure(figsize=(13,6))
        ax = fig.add_subplot(111)
        line1, = ax.plot(x_val,y1_data,'r-o',alpha=0.8)
        plt.xlabel('Time(s)')
        plt.ylabel(dataLabel)
        plt.title('{} vs time'.format(dataLabel))
        plt.show()
    line1.set_data(x_val,y1_data)
    #set limits of plot
    plt.xlim(np.min(x_val),np.max(x_val)+1)
    if np.min(y1_data)<=line1.axes.get_ylim()[0] or np.max(y1_data)>=line1.axes.get_ylim()[1]:
        plt.ylim([np.min(y1_data)-np.std(y1_data),np.max(y1_data)+np.std(y1_data)])

    return line1


main()
