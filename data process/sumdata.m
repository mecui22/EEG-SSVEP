clear;clc
files = dir('DataNeuracle');
num_sub = size(files,1)-2;
data_nc = zeros(9,5000,4,40,num_sub);
for i = 1 : size(files,1)-2
    i
    load(['DataNeuracle\S',num2str(i),'_neuracle.mat']);
    padding = zeros(9,2000,4,40);
    temp = cat(2,datum,padding);
    data_nc(:,:,:,:,i) = temp;
end
save data_neuracle.mat data_nc
%%
files = dir('DataNeuroscan');
num_sub = size(files,1)-2;
data_ns = zeros(9,5000,4,40,num_sub);
for i = 1 : size(files,1)-2
    i
    load(['DataNeuroscan\S',num2str(i),'_neuroscan.mat']);
    if i < 16
        padding = zeros(9,3000,4,40);
    else
        padding = zeros(9,2000,4,40);
    end
    temp = cat(2,datum,padding);
    data_ns(:,:,:,:,i) = temp;
end

%%
load('freqs_bci2018.mat')
freqs = [8:0.2:15.8];
for i = 1 : 40
    freqindex(i) = find(abs(eventType_FrequencyVector-freqs(i))<1e-3);
end
data_ns = data_ns(:,:,:,freqindex,:);

save data_neuroscan.mat data_ns
%%
mdata = squeeze(mean(data_ns,5));
adata = squeeze(mean(mdata,3));
figure
plotspectrum(adata(8,:,38),'r')