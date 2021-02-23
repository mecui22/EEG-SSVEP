function data_filt = notch_filt(data, fs)
    wo = 50/(fs/2);  
    bw = wo/60;
    [b,a] = iirnotch(wo,bw);
%     fvtool(b,a);
    data_filt = filtfilt(b,a,data);
%     plotspectrum(data_filt,'r')
end