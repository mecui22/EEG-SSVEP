function SNR = spectrumSNR(x)
f = 0.2:0.2:500;
   for i = 1 : 2500
       if i < 7 || i > 2492
           SNR(i) = 0;
       else
           SNR(i) = calculateSNR(x,1000,f(i),3);
       end
   end
       
end