function Single_Motor_Arduino
%%% This function takes the FT readings and tachometer data from a single
%%% motor test run using the arduino to control the motor.
%%% The function aims to determine the relationship between rpm and thrust,
%%% be it linear or nonlinear

% check if the files have already been parsed
if fopen('data.mat') ~= -1
    load('data.mat')
else
    file = 'Single_Motor_2021_03_08_01';
    [jr3,tach] = string_form(file);
    rpm=getRPM(tach);
    ft=getFT(jr3);
    plot(rpm.Time,rpm.RPM)
    
    
end
end

function [jr3,tach] = string_form(file)
jr3 = sprintf('%s_FT',file);
tach = sprintf('%s_Tacho.csv',file);
end

function rpm=getRPM(tach)
    rpm=readtable(tach);
   	rpm(rpm.RPM == 0, :) = []
end

function ft=getFT(jr3)
    ft