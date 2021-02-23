fs = 1000;
freqs = [8:0.2:15.8];
timepts = [94:3:112,170:3:188];
block = 1;
epochLen = 3;
currDir = pwd;
dataPath = [currDir,'\data\'];
resultsPath = [currDir,'\results ', datestr(now,'mm-dd-yyyy HH-MM'),'\'];
filename = ['data_rest.bdf'];

%filepath = [dataPath,info(sub).name,'\',grps(group).name,'\'];
EEG = readbdfdata(filename, filepath);
datum = EEG.data;
datap = zeros(size(datum));
for chan = 1 : size(datum,1)
    datap(chan,:) = filterp1(EEG.data(chan,:)',3,100)';
end

for ii = 1:size(timepts,2)
    temp = datap(:,timepts(ii)*fs+1:(timepts(ii)+epochLen)*fs);
    epoch(:,:,block,ii) = temp;
end
        
data.EEG = epoch;
load('freqV_first.mat');

data_EEG = data.EEG;
datum0 = notch_filt_neuracle(data_EEG,fs);
padding = zeros(64,2000,block,14);
datum = cat(2,datum0,padding);
savepath = [resultsPath,info(sub).name,'\',grps(group).name,'\'];
sub_TopograhicAnalysis_rest(datum,freqV,savepath,group,'neuracle12');
sub_RhythmAnalysis_rest(datum,freqV,savepath,group,'neuracle12');