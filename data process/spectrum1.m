function y = spectrum1(x)
   N = length(x);
   y1 = abs(fftshift(fft(x)))/N;
   y = y1(1+N/2:end);
end