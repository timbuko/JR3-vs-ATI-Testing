function Single_Motor_Arduino
%%% This function takes the FT readings and tachometer data from a single
%%% motor test run using the arduino to control the motor.
%%% The function aims to determine the relationship between rpm and thrust,
%%% be it linear or nonlinear

% check if the files have already been parsed
if fopen('data.mat') ~= -1
    load('data.mat')
else
    file = 'Single_Motor_2021_03_15_06';
    [jr3,tach] = string_form(file);
    rpm=getRPM(tach);
    ft=getFT(jr3);
    [rpm_aligned,ft_aligned]=align_data(rpm,ft);
    save('data','ft','rpm','ft_aligned','rpm_aligned')

    
end
    ft.fz=1.927*ft.fz-1.560;%fix calibration from 3/15/21 trials
    plot_data(rpm_aligned,ft_aligned)
    
    
    figure(2)
    yyaxis left
    plot(rpm_aligned.Time./1000,rpm_aligned.RPM)
    hold on
    yyaxis right
    plot(ft_aligned.Time,ft_aligned.fz)
    
    figure(3)
    scatter(rpm_aligned.RPM.^2,ft_aligned.fz,'*')
    title('Thrust vs \omega^2')
    hold on
    figure(4)
    scatter(rpm_aligned.RPM,ft_aligned.fz,'*')
    title('Thrust vs \omega')
    hold on
    
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

function [rpm_aligned,ft]=align_data(rpm,ft)
%align the data and interpolate so points match up 
    rpm(rpm.RPM<2000,:)=[];
    ft(ft.fz<1,:)=[];
    rpm.Time=rpm.Time-rpm.Time(1);
    ft.Time=ft.Time-ft.Time(1);
    
    len_rpm=length(rpm.RPM);
    len_fz=length(ft.fz);
    rpm_a.Time= interp1(1:len_rpm,rpm.Time,linspace(1,len_rpm,len_fz))';
    rpm_a.RPM = interp1(1:len_rpm,rpm.RPM,linspace(1,len_rpm,len_fz))';
    rpm_aligned=struct2table(rpm_a);
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