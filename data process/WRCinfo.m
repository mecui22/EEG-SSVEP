clear;clc
stimTime = 3;
fs = 1000;
files1 = dir('DataNeuracleRaw');
num_sub1 = size(files1,1)-2;
load('freqV_first.mat')

for i = 1 : num_sub1
    i;
    load(['DataNeuracleRaw\S',num2str(i),'_neuracle.mat']);
    data_EEG = data.EEG;
    datum_notch = notch_filt_neuracle(data_EEG,fs);
    datum0 = datum_notch(:,500+1+140:500+stimTime*fs+140,:,:);
    padding = zeros(64,2000,4,40);
    datum = cat(2,datum0,padding);
    savepath = ['E:\BCI2018\DataNeuracleInfo\S',num2str(i),'\'];
    % Spectrum Analysis£º 1.Spectrum plot  
    sub_SpectrumAnalysis(datum,freqV,savepath,i,'neuracle')
%     % Topographic map of spectrum
    sub_TopograhicAnalysis(datum,freqV,savepath,i,'neuracle')
    % 3 SNR histogram
    sub_SNRAnalysis(datum,freqV,savepath,i,'neuracle')
    % FBCCA¡¢TRCA¡¢TRCA acc\ITR mat
    sub_BCIAnalysis(datum,savepath,i,'neuracle')
    % 4 band topographic map
    sub_RhythmAnalysis(datum,freqV,savepath,i,'neuracle')
    % save info txt
    sub_info(data,savepath)
end
%%
% load('freqV_second.mat')
% files2 = dir('DataNeuroscanRaw');
% num_sub2 = size(files2,1)-2;
% for i = 23
%     i
%     load(['DataNeuroscanRaw\S',num2str(i),'_neuroscan.mat']);
%     datum0 = data.EEG;
%     if size(datum0,2) < 4000
%        stimTime = 2;
%        datumt = datum0(:,500+1+140:500+stimTime*fs+140,:,:);
%        padding = zeros(64,3000,4,40);
%     else
%        stimTime = 3;
%        datumt = datum0(:,500+1+140:500+stimTime*fs+140,:,:);
%        padding = zeros(64,2000,4,40);
%     end
%     datum = cat(2,datumt,padding);
%     savepath = ['E:\BCI2018\DataNeuroscanInfo\S',num2str(i),'\'];
%     Spectrum Analysis£º 
%     sub_SpectrumAnalysis(datum,freqV,savepath,i,'neuroscan')
%     Topographic map of spectrum
%     sub_TopograhicAnalysis(datum,freqV,savepath,i,'neuroscan')
%     3 SNR histogram
%     sub_SNRAnalysis(datum,freqV,savepath,i,'neuroscan')
%     FBCCA¡¢TRCA¡¢TRCA acc\ITR mat
%     sub_BCIAnalysis(datum,freqV,savepath,i,'neuroscan')
%     % 4 band topographic map
%     sub_RhythmAnalysis(datum,freqV,savepath,i,'neuroscan')
%     % save info txt
%     sub_info(data,savepath)
% end
%%
error_data = [107,128,129]
for i = 1 : length(error_data)
    i
    load(['DataNeuracleRaw\S',num2str(error_data(i)),'_neuracle.mat']);
    data_EEG = data.EEG;
    datum_notch = notch_filt_neuracle(data_EEG,fs);
    datum0 = datum_notch(:,500+1+140:500+stimTime*fs+140,:,:);
    padding = zeros(64,2000,4,40);
    datum = cat(2,datum0,padding);
    savepath = ['E:\BCI2018\DataNeuracleInfo\S',num2str(error_data(i)),'\'];
    % Spectrum Analysis£º 1.Spectrum plot  
    sub_SpectrumAnalysis(datum,freqV,savepath,i,'neuracle')
%     % Topographic map of spectrum
    sub_TopograhicAnalysis(datum,freqV,savepath,i,'neuracle')
    % 3 SNR histogram
    sub_SNRAnalysis(datum,freqV,savepath,i,'neuracle')
%     % FBCCA¡¢TRCA¡¢TRCA acc\ITR mat
    sub_BCIAnalysis(datum,freqV,savepath,error_data(i),'neuracle')
% %     % 4 band topographic map
    sub_RhythmAnalysis(datum,freqV,savepath,i,'neuracle')
    % save info txt
    sub_info(data,savepath)
end