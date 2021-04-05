function Single_Motor_Arduino
%%% This function takes the FT readings and tachometer data from a single
%%% motor test run using the arduino to control the motor.
%%% The function aims to determine the relationship between rpm and thrust,
%%% be it linear or nonlinear

% check if the files have already been parsed
if fopen('data.mat') ~= -1
    load('data.mat')
else
    file = 'Single_Motor_2021_03_15_07';
    [jr3,tach] = string_form(file);
    rpm=getRPM(tach);
    ft=getFT(jr3);
    save('data','ft','rpm')

    
end
    ft.fz=1.927*ft.fz-1.560;%fix calibration from 3/15/21 trials
    plot_data(rpm,ft)
    fclose('all');
end

function [jr3,tach] = string_form(file)
jr3 = sprintf('%s_FT',file);
tach = sprintf('%s_Tach.csv',file);
end

function rpm=getRPM(tach)
    rpm=readtable(tach);
   	rpm(rpm.RPM == 0, :) = [];
end

function ft=getFT(jr3)
    ft=readtable(jr3);
    ft.Properties.VariableNames{1}='Time';
end

function plot_data(rpm,ft)
% Take the raw data and plot against time

figure('Visible','on','Name','Sensor Data')

omega = uitab('Title','RPM');
omegaax = axes(omega);
plot(omegaax,rpm.Time,rpm.RPM)
xlabel('Time (2Hz sample)')
ylabel('RPM')
title('RPM readings from Arduino Tach')

f_t = uitab('Title','Fz');
ftax = axes(f_t);
plot(ftax,ft.Time,ft.fz)
xlabel('Time (7.076Hz sample rate)')
ylabel('Force (N)')
title('JR3 Fz Readings')
end