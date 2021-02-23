fsfunction [  ] = plotspectrumc( x,f0,a)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
   fs =1000;
   x = squeeze(x);
   N = length(x);
   fp = N / fs;
   y = abs(fftshift(fft(x)))/N;
   plot(-fs/2:fs/N:fs/2-fs/N,y,a);
   for i = 1 : 5
        fpower = y(1+N/2+fp*f0*i);
        hold on
        scatter(f0*i,fpower,'o');
   end
   grid
   set(gca,'Xlim',[5,60]); 
%    ylabel('|H(e^j^\omega)|');
%    xlabel('f/Hz');
end



