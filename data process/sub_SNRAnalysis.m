function sub_SNRAnalysis(datum,freqV,savepath,sub,type)
 
    neuracle_chan = [1:5,8:59];
    chan5 = [41,48,55:57];
    chan9 = [41,48:52,55:57];
    neuroscan_chan9 = [48,54,55,56,57,58,61,62,63];  
    if strcmp(type,'neuracle12')
        datum9 = datum(neuracle_chan(chan5),:,:,:);
    elseif strcmp(type,'neuracle')
        datum9 = datum(neuracle_chan(chan9),:,:,:);
    elseif strcmp(type,'neuroscan')
        datum9 = datum(neuroscan_chan9,:,:,:);
    end
    fs = 1000;
    for block = 1 : 1
        for chan = 1 : size(datum9,1)
            for cond = 1 : 40
                narrow_snr(chan,cond,block) = calculateSNRnarrow(datum9(chan,:,block,cond),1000,freqV(cond),5,5);
                wide_snr(chan,cond,block) = calculateSNRwide(datum9(chan,:,block,cond),freqV(cond));
            end
        end
    end   
    datum9s = permute(datum9,[4,1,2,3]);
    for block = 1 : 1
        projection_snr(:,block) = calculateSNRprojection(datum9s(:,:,:,block),freqV,1000,5);
    end   
    narrow_snr = remove_nan(narrow_snr);
    wide_snr = remove_nan(wide_snr);
    projection_snr = remove_nan(projection_snr);
    snr.narrow_snr = narrow_snr;
    snr.wide_snr = wide_snr;
    snr.projection_snr = projection_snr;
    narrow_snr(find(isnan(narrow_snr)))=[];
    wide_snr(find(isnan(wide_snr)))=[];
    projection_snr(find(isnan(projection_snr)))=[];
    snr.mean_narrow_snr = mean(narrow_snr(:));
    snr.mean_wide_snr = mean(wide_snr(:));
    snr.mean_projection_snr = mean(projection_snr(:));
    if ~exist(savepath)
        mkdir(savepath)
    end
    save([savepath,'S',num2str(sub),'-snr.mat'],'snr')
end