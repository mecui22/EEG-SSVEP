clear;clc
load('D:\WRCdata\freqV.mat');
filename_2 = {'data.bdf','evt.bdf'};
filename_3 = {'data.bdf','data.1.bdf','evt.bdf'};
blocknum = [1:3];
stimTime = 3;
fs = 1000;
chan9 = [41,48:52,55:57];
path = ['D:\ALS\'];
% subject = ['gucheng','gaojinbo'];
subject = ['gaojinbo'];
freqlist = [8:0.2:15.8];
neuracle_chan = [1:5,8:59];
datum = zeros(stimTime*fs,64,40,length(blocknum));
for i = 1 : length(blocknum)
    filepath = [path,subject,'\',num2str(blocknum(i)),'\'];
    filenum = length(dir(filepath))-4;
    if filenum == 1
        EEG = readbdfdata(filename_2, filepath);
    else
        EEG = readbdfdata(filename_3, filepath);
    end
    event0 = EEG.event;
    k = 0;
    for j = 1 : size(event0,1)
        if ~(isletter(event0(j).type))
            k = k + 1;
            trigger(str2num(event0(j).type)) = event0(j).latency;
        end
    end

    for chan = 1 : size(EEG.data,1)
        data(chan,:) = filterp1(EEG.data(chan,:)',3,100)';
    end
    for ii = 1 : 40
        if trigger(ii) + stimTime*fs < size(data,2)
           temp = data(:,trigger(ii)+1:trigger(ii) + stimTime*fs);
        else
           temp = data(:,trigger(ii)+1:end);
        end
        datum(1:size(temp,2),:,ii,i) = temp';
    end
    clear data
end