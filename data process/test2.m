% clear;clc
% x = randn(1,1000000);
% figure
% plotspectrum(x,'r')
% y = notch_filt(x,1000);
% figure
% plotspectrum(y,'r')
% % 
datas = squeeze(mean(data_nc(8,501:4500,:,:,:),5));
datasb = squeeze(mean(datas,2));
x = datasb(:,1)
y = notch_filt(x,1000);
figure
plotspectrum(x,'r')
figure
plotspectrum(y,'r')