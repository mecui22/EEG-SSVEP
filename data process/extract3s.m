% clear;clc
freqs = [8:0.2:15.8];
dirinfo = dir('Data')%146 subjects
stimTime = 3;
fs = 1000;
% for i = 1 :size(dirinfo,1)-2
for i = 1 :size(dirinfo,1)-2
    i 
    sub = dirinfo(i+2).name;
    date = dir(['Data\',sub])
%     filename = [pwd,'\Data\',sub,'\',date(3).name,'\modelData\3s_data.mat'];
%     if exist(filename)
%         load(filename);
%         freqlist = zeros(1,40);
%         for ii = 1 : 40
%             freqlist(ii) = data(ii).freq;
%         end
%         datum = zeros(9,3000,4,40);
%         for j = 1 :40
%             index = find(freqlist == freqs(j));
%             epoch = data(index).data;
%             if ndims(epoch)==3
%                 for k = 1 : size(epoch,3)
%                     for kk = 1 :9
%                         temp = filterp1(squeeze(epoch(kk,:,k))',3,100);
% %                         datum(kk,:,k,j) = downsample(temp(141:end),4);
%                         datum(kk,:,k,j) = temp(141:end);
%                     end
%                 end
%             else
%                 for kk = 1 :9
%                     temp = filterp1(epoch(kk,:)',3,100);
% %                     datum(kk,:,1,j) = downsample(temp(141:end),4);
%                     datum(kk,:,1,j) = temp(141:end);
%                 end
%             end
%         end
% %         save(['Datamat\S',int2str(i),'_neuracle'],'datum'); 
%     end
%     clear datum
    %
    blocklist = dir(['Data\',sub,'\',date(3).name])

    datum = zeros(9,3000,4,40);
    for block = 1 :4
        filename = [pwd,'\Data\',sub,'\',date(3).name,'\',blocklist(block+7).name,'\data.mat']
        if exist(filename) && (strfind(filename,'SSVEP-KB410-3'))
            load(filename);
            clear freqlist
            for ii = 1 : size(data,2)
                freqlist(ii) = data(ii).freq;
            end
            for ii = 1 : size(data,2)
                label = data(ii).label;
                freq = data(ii).freq;
                freqV(label) = freq;
            end
            freqVm((i-1)*4+block,:) = freqV;
%             for j = 1 :40
%                 ind = find(freqlist == freqs(j));
%                 if ~isempty(ind) 
%                     epoch = data(ind).data;
%                     onset = data(ind).startStim;
%                     for kk = 1 :9
%                         temp = filterp1(epoch(kk,:)',3,100)';
% %                          datum(kk,:,block,j) = downsample(temp(141:140+stimTime*fs),4);
%                         datum(kk,:,block,j) = temp(onset*fs+1:onset*fs+stimTime*fs);
%                     end
%                 end
%             end
        end
    end
%     if exist(filename) && (strfind(filename,'SSVEP-KB410-3'))
%        save(['DataNeuracle\S',int2str(i),'_neuracle'],'datum'); 
%     end
%     clear datum
end
%%
