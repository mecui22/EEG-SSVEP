function [snrdata] = calculateSNRwide(x, i)
   fs = 1000;
   N = length(x);
   fp = N / fs;
   y  = abs(fftshift(fft(x))/N).^2;
   fpower = y(1+N/2+fp*i) + y(1+N/2+fp*i*2) + y(1+N/2+fp*i*3)+ y(1+N/2+fp*i*4)+ y(1+N/2+fp*i*5);
%     fpower = y(1+N/2+fp*i);
    baseline = sum(y(1+N/2:end)) ;
   snrdata = fpower / (baseline - fpower) ;
   snrdata = 10*log10(snrdata);
end



