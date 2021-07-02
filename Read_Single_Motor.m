function Single_Motor_Arduino
%%% This function takes the FT readings and tachometer data from a single
%%% motor test run using the arduino to control the motor.
%%% The function aims to determine the relationship between rpm and thrust,
%%% be it linear or nonlinear

close all

% check if the files have already been parsed
if fopen('data.mat') ~= -1
    load('data.mat')
else
    file = 'Single_Motor_2021_04_16_10';
    stepsize=9.5; %size of steps in seconds
    skiptime=2.5;    %time to take off beginning and end of  step
    %NEED TO DELETE DATA FILE AFTER CHANGING
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHECK NUMSTEPS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                     
    [jr3,tach] = string_form(file);
    rpm=getRPM(tach);
    ft=getFT(jr3);
    
%     
%     %%% fix 3/15/21 data %%%%%%%%%
%     ft.fz=1.927*ft.fz-1.560;%fix calibration from 3/15/21 trials
%     ft(ft.fz <= 0, :) = [];
%     rpm.Time=rpm.Time./1000; % fix time adjustment from 3/15/21
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    [rpm_aligned,ft_aligned]=align_data(rpm,ft,stepsize,skiptime);
    save('data','ft','rpm','ft_aligned','rpm_aligned')

    
end

    
    plot_data(rpm_aligned,ft_aligned)
    
    figure(2)
    yyaxis left
    scatter(rpm.Time,rpm.RPM)
    hold on
    yyaxis right
    scatter(ft.Time,ft.fz)
    
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
   	rpm(rpm.RPM <= 0, :) = [];
end

function ft=getFT(jr3)
    ft=readtable(jr3);
    ft.Properties.VariableNames{1}='Time';
    ft(ft.fz <= 0, :) = [];
end


function [rpm_aligned,ft_aligned]=align_data(rpm,ft,stepsize,skiptime)
%align the data and interpolate so points match up (does whole set
%together

    [~,loc1]=findpeaks(rpm.RPM,'MinPeakHeight',2000); %find first step 
    [~,loc2]=findpeaks(ft.fz,'MinPeakHeight',.4);
    
    numSteps = findSteps(ft,stepsize);
    rpm=rpm([loc1(1):loc1(end)],:); %isolate stepping portion of data
    ft=ft([loc2(1):loc2(end)],:);
    
    rpm.Time=rpm.Time-rpm.Time(1); %shift times to start at zero
    ft.Time=ft.Time-ft.Time(1);
    
  
    
    %i think i just have to interpolate a fuck ton of points then fit to
    %ft.Time cuz polyfit wont work for this data
    
    len_rpm=length(rpm.RPM);
    temptime= interp1(1:len_rpm,rpm.Time,linspace(1,len_rpm,1000000))';
    temprpm = interp1(1:len_rpm,rpm.RPM,linspace(1,len_rpm,1000000))';
        
    
    tempindex=zeros(length(ft.Time),1);
    %find Rpm for times of each ft time
    try %the rpm might not go exactly as long as ft so this breaks if not enough rpm
        for i=1:length(ft.Time) 
            tempindex(i)= find(temptime>ft.Time(i),1);
        end
    catch ME
        if (strcmp(ME.identifier,'MATLAB:matrix:singleSubscriptNumelMismatch')) 
            warning('RPM time is shorter than ft time, so leftover ft time was left out')
            ft([i:end],:)=[];
            tempindex([i:end],:)=[];
        else
            rethrow(ME)
        end

    end
    
    
    rpm_aligned.Time=temptime(tempindex);
    rpm_aligned.RPM=temprpm(tempindex);
    

    [rpm_index]=setIndex(rpm_aligned,stepsize,skiptime,numSteps); %Get indicies of data i want, separated into each step
    [ft_index]=setIndex(ft,stepsize,skiptime,numSteps);
    
    rpm_aligned=struct2table(rpm_aligned);
    rpm_aligned=rpm_aligned(rpm_index,:);
    ft_aligned=ft(ft_index,:);
   

end


function [index]=setIndex(data,stepsize,skiptime,numSteps)
%set index of desired data (cut out the step itself)


% %Use for if you want each step separate
% index=cell(numSteps,1);
% index{1}=find(data.Time>skiptime/2 & data.Time<stepsize-skiptime/2);
% for i=2:numSteps-1    
%     index{i}=find(data.Time>(i-1)*stepsize+skiptime/2 & data.Time<(i)*stepsize-skiptime/2);
% end
% index{i+1}=find(data.Time>(i+1)*stepsize+skiptime/2 & data.Time<data.Time(end)-skiptime/2);


%Use to get single list of indices
index=[];
index=[index,find(data.Time>skiptime/2 & data.Time<stepsize-skiptime/2)'];
for i=2:numSteps-1    
    index=[index,find(data.Time>(i-1)*stepsize+skiptime/2 & data.Time<(i)*stepsize-skiptime/2)'];
end
index=[index,find(data.Time>(i+1)*stepsize+skiptime/2 & data.Time<data.Time(end)-skiptime/2)'];

end

function numSteps = findSteps(ft,stepsize)
%find the number of steps in the data set using the derivative
    [len,~]=size(ft);
    delta=zeros(len-1,1);
    for i=1:len-1 %start at 20 to skip any noise when first turnign on sensor
        delta(i)=abs(ft.fz(1+i)-ft.fz(i));
    end
    
    [pks,locs]=findpeaks(delta,'MinPeakDistance',7*(stepsize-2),'MinPeakHeight',.15); %uses 7 as sample rate
    numSteps=length(locs)-1;
    
    figure(22)
    title(['FT data and Differentiation, Calc numSteps=',num2str(numSteps)])
    yyaxis left
    plot(ft.Time(2:end),delta)
    hold on
    plot(ft.Time(locs),pks,'v')
    yyaxis right
    plot(ft.Time,ft.fz)
    
    
    
end

% function [rpm_aligned,ft_aligned]=align_data(rpm,ft,stepsize,skiptime) % This func doesnt work cuz the rpm isnt spread even so cant use indexes to find locations in data. have to use time
% 
% %align the data and interpolate so points match up (does whole set
% %together
% 
%     [~,loc1]=findpeaks(rpm.RPM,'MinPeakHeight',2000); %find first step 
%     [~,loc2]=findpeaks(ft.fz,'MinPeakHeight',1);
%     
%     rpm=rpm([loc1(1):loc1(end)],:); %isolate stepping portion of data
%     ft=ft([loc2(1):loc2(end)],:);
%     
%     rpm.Time=rpm.Time-rpm.Time(1); %shift times to start at zero
%     ft.Time=ft.Time-ft.Time(1);
%     
%     len_rpm=length(rpm.RPM); %interpolate rpm data to match ft data 
%     len_fz=length(ft.fz);
%     rpm_a.Time= interp1(1:len_rpm,rpm.Time,linspace(1,len_rpm,len_fz))';
%     rpm_a.RPM = interp1(1:len_rpm,rpm.RPM,linspace(1,len_rpm,len_fz))';
%     rpm_aligned=struct2table(rpm_a);    
%     ft_aligned=ft;
%     %Justin used resample() but it doesnt work that well
%     
%     %ignore section where step occurs
%      sampleRate=length(rpm_aligned.Time)/rpm_aligned.Time(end);
%      numSteps=round(len_fz/(sampleRate*stepsize)); 
%    
%        index=[];
%     for i=1:numSteps-1
%         index=[index,round(i*sampleRate*stepsize-round(skiptime*sampleRate)):...
%             round((i)*sampleRate*stepsize+round(skiptime*sampleRate))];
%     end
%         index=[index,1:round(skiptime*sampleRate),...
%             round(len_fz-round(skiptime*sampleRate)):len_fz];
%     rpm_aligned(index,:)=[];
% 
%     
%     sampleRate=length(ft_aligned.Time)/ft_aligned.Time(end);
%     numSteps=round(len_fz/(sampleRate*stepsize));
%     index=[];
%     for i=1:numSteps-1
%         index=[index,round(i*sampleRate*stepsize-round(skiptime*sampleRate)):...
%             round((i)*sampleRate*stepsize+round(skiptime*sampleRate))];
%     end
%         index=[index,1:round(skiptime*sampleRate),...
%             round(len_fz-round(skiptime*sampleRate)):len_fz];
%         
%     ft_aligned(index,:)=[];
%     
% end

function plot_data(rpm,ft)
% Take the raw data and plot against time


figure('Visible','on','Name','Sensor Data')

omega = uitab('Title','RPM');
omegaax = axes(omega);
scatter(omegaax,rpm.Time,rpm.RPM,'.')
xlabel('Time (2Hz sample)')
ylabel('RPM')
title('RPM readings from Arduino Tach')

f_t = uitab('Title','Fz');
ftax = axes(f_t);
scatter(ftax,ft.Time,ft.fz,'.')
xlabel('Time (7.076Hz sample rate)')
ylabel('Force (N)')
title('JR3 Fz Readings')
end