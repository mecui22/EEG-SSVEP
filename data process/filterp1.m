function [ y] = filterp1(x,a,b)
    dbstop if error
    fs = 1000;
%     x = double(x);
%     BS=[9,11];
%     [c,d]=butter(6,BS/(fs/2),'bandpass'); 
%     
%      y = filtfilt(c,d,x'); 
% 
%     bpFilt = designfilt('bandpassiir','FilterOrder',50, ...
%          'HalfPowerFrequency1',4,'HalfPowerFrequency2',50, ...
%          'SampleRate',fs);
%      y = filtfilt(bpFilt,x');
     y1 = eegfilt(x',fs,0,b,0,0,0,'firls',0);
     y2 = eegfilt(y1,fs,a,0,0,0,0,'firls',0);
     y = y2';
%        y = filtfilt(c,d,x);
end