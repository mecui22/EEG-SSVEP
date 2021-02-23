load('freqV_second.mat')
files2 = dir('DataNeuroscanRaw');
num_sub2 = size(files2,1)-2;
for i = 1 : num_sub2 
    i
    load(['DataNeuroscanRaw\S',num2str(i),'_neuroscan.mat']);
    datum0 = data.EEG;
    if size(datum0,2) < 4000
       stimTime = 2;
       datumt = datum0(:,500+1+140:500+stimTime*fs+140,:,:);
       padding = zeros(64,3000,4,40);
    else
       stimTime = 3;
       datumt = datum0(:,500+1+140:500+stimTime*fs+140,:,:);
       padding = zeros(64,2000,4,40);
    end
    datum = cat(2,datumt,padding);
    savepath = ['E:\BCI2018\DataNeuroscanInfo\S',num2str(i),'\'];
    % Spectrum Analysis£º 
%     sub_SpectrumAnalysis(datum,freqV,savepath,i,'neuroscan')
    % Topographic map of spectrum
%     sub_TopograhicAnalysis(datum,freqV,savepath,i,'neuroscan')
    % 3 SNR histogram
    sub_SNRAnalysis(datum,freqV,savepath,i,'neuroscan')
    % FBCCA¡¢TRCA¡¢TRCA acc\ITR mat
%     sub_BCIAnalysis(datum,freqV,savepath,i,'neuroscan')
%     % 4 band topographic map
%     sub_RhythmAnalysis(datum,freqV,savepath,i,'neuroscan')
%     % save info txt
%     sub_info(data,savepath)
end