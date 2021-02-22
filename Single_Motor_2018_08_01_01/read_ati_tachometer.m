function rpm = read_ati_tachometer(file)
%read the tachometer csv file and output in a matrix

fid = fopen(file,'r');
rpm = [];
counter = 1;

while ~feof(fid)
    if counter < 8
        line = fgetl(fid);
        counter = counter + 1;
    else
        line = fgetl(fid);
        
        [num,remain] = strtok(line,',');
        reading = erase(remain,',');
        rpm(end+1) = str2double(reading);
        
    end
end
fclose(fid);