function data_filt = notch_filt_neuracle(data,fs)
   data_filt = zeros(size(data));
   for i = 1 : 64
       for j = 1 : 1
           for k = 1 : size(data,4)
               datum = data(i,:,j,k);
               data_filt(i,:,j,k) = notch_filt(datum,fs);
           end
       end
   end
end