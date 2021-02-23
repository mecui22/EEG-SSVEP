function [  ] = plotspectrum( x,a)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
   fs =1000;
   x = squeeze(x);
   N = length(x);
   y = abs(fftshift(fft(x)))/N;
   plot(-fs/2:fs/N:fs/2-fs/N,y,a);
   grid
   set(gca,'Xlim',[5,70])
   ylabel('|H(e^j^\omega)|');
   xlabel('f/Hz');
end

