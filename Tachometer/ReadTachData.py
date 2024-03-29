#Reads serial output of arduino. "Ardino outputs rpm following an 'r' and time following a 't'
#the csv file created by this just ends up in the same folder as where this script is
import time
import math
import csv
import numpy as np
import matplotlib.pyplot as plt #requires download
import serial                   #requires download

plt.style.use('ggplot') #Adds grid to plots
print('Loading.....')

def main(): #Saves data to csv file and plots data vs time
    t=0
    incoming=0
    line1=[]
    tim=[] #time values
    

    PortA='RPM'#label what sensor is
    Adata=[]   #initialize data



    fileid=input('Name the file (Include .csv)\n')
    iTime=time.time()
    try:
        with open(fileid, "w",newline='') as csvfile:  #opens file to write data
            fieldnames = ['Time',PortA]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerow({'Time': '(s)', PortA: '-', }) #Units
            ArduinoSerial = serial.Serial(port='COM9', baudrate=9600)
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
                
                writer.writerow({'Time':t,PortA:A,})

                tim.append(t)
                Adata.append(A)


##                line1=live_plotter_xy(tim,Adata,PortA,line1) # NUMBER 5.1 ###################### NUMBER 5.1
##                ii+=1
##                if ii>120:    #set time to take data
##                    break

    except:
        if time.time()-iTime < 2:
            print('There was an error, check connections and restart')
        else:
            print('Data saved to {}\n'.format(fileid))
            plotter(tim,Adata,PortA,'Plot 1')



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
