function SNR = calculateSNRprojection(data,freqs,fs,StimTime)
 
% 刺激频率（目标）个数
TargetNum = 40;
% 8目标刺激频率为8、9、10、11、12、13、14、15Hz
Phi=zeros(TargetNum,5*2,fs*StimTime);
% 脑电数据截段
% data=zeros(TargetNum,9,fs*StimTime);
for m=1:TargetNum
    % 5倍频
    for n=1:5
        Phi(m,2*n-1,:)=(exp(-1i*n*2*pi*freqs(m)*[1:fs*StimTime]/fs))/(sqrt(StimTime*fs));  
        Phi(m,2*n,:)=exp(1i*n*2*pi*freqs(m)*[1:fs*StimTime]/fs)/(sqrt(StimTime*fs));    
    end
end
%% 计算SNR
for m = 1:TargetNum
    SinTriEEG=reshape(data(m,:,:),9,fs*StimTime);    
    SinTriPhi=reshape(Phi(m,:,:),5*2,StimTime*fs);    
    SNR(m)=10*log10(trace(SinTriEEG*(SinTriPhi')*SinTriPhi*(SinTriEEG'))/trace(SinTriEEG*(eye(fs*StimTime)-(SinTriPhi')*SinTriPhi)*(SinTriEEG')));
end
SNR = real(SNR);
end