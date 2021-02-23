% snr() - calculate signal to noise ratio (snr)b
%
% Usage:
%  >> [snrdata] = snr(data,srate,freq);
%
% Inputs:
%     data        = single channel data
%     srate       = data sampling rate (Hz)
%     freq        = The analysis of frequency (Hz)
%     n           = around points
%
% Outputs:
%     snrdata  = signal to noise ratio
%
% Copyright (C) 2012 Xiaogang Chen, chenxiaogang1986@163.com
% 
%
function [snrdata] = calculateSNR(data,srate,freq,n)

N = length(data);
fftdata = abs(fft(data,N));
f = srate*(0:N/2)/N;% value of frequency slot 
anadata = fftdata(1:N/2+1);%from zero to fs/2
% figure;
% plot(f,anadata);
indexfreq = find(abs(f-freq)<1e-3);%location of the interested frequency : 2n+1
Nf0 = 0;
for ii = 1:n
    Nf1 = anadata(indexfreq-ii) + anadata(indexfreq+ii); %add values of the left and the right
    Nf0 = Nf0 + Nf1;
end
Nf0 = Nf0/(2*n);% averaged
snrdata = anadata(indexfreq)/Nf0;
% snrdata = 20*log10(snrdata1);
end



