function  [result,rho] = stdcca_rho(circBuff,fs,freq)
% circBuff1 = circBuff(141:end,1:9);
% temp = downsample(circBuff,4);
% circBuff2 = filterp3(temp);
condY = ccaReference(circBuff, fs, freq);
[result,rho] = ccaCalculate_rho(circBuff, condY, length(freq), freq);
% plotspectrum(circBuff2(:,8),250)
end