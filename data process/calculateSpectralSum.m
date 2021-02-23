function [ baseline ] = calculateSpectralSum( x,band,i,fs)
   N = length(x);
   fp = N / fs;
   y = (abs(fftshift(fft(x)))/N).^2;
%    y = (abs(fftshift(fft(x)))/N);
   fpoints = N/2+fp*band(1)+1 : N/2+fp*band(2)+1;
   if i >= band(1) && i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i+1);
   end
   if 2*i >= band(1) && 2*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*2+1);
   end
   if 3*i >= band(1) && 3*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*3+1);
   end
   if 4*i >= band(1) && 4*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*4+1);
   end
   if 5*i >= band(1) && 5*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*5+1);
   end
   if 6*i >= band(1) && 6*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*6+1);
   end
   if 7*i >= band(1) && 7*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*7+1);
   end   
   if 8*i >= band(1) && 8*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*8+1);
   end
   if 9*i >= band(1) && 9*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*9+1);
   end
   if 10*i >= band(1) && 10*i <= band(2)
     fpoints =  setdiff(fpoints,N/2+fp*i*10+1);
   end    
     power = sum(y(fpoints));
%      baseline = 10*log(power/(sum(y)-power));
     baseline = sum(y(fpoints)) ;
end
