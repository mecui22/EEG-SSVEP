function [snrdata] = calculateSNRnarrow(data,srate,freq,n,nharmonic)

N = length(data);
fftdata = abs(fft(data,N));
f = srate*(0:N/2)/N;% value of frequency slot 
anadata = fftdata(1:N/2+1);%from zero to fs/2
% figure;
% plot(f,anadata);
indexbase = find(abs(f-freq)<1e-3);%location of the interested frequency : 2n+1
Nf0 = 0;
for ii = 1:n
    Nf1 = anadata(indexbase-ii) + anadata(indexbase+ii); %add values of the left and the right
    Nf0 = Nf0 + Nf1;
end
Nf0 = Nf0/(2*n);% averaged
indexfreq = zeros(1,nharmonic);
for i = 1 : nharmonic
    indexfreq(i) = find(abs(f-i*freq)<1e-3);
end
snrdata0 = sum(anadata(indexfreq))/Nf0;
snrdata = 20*log10(snrdata0);
end