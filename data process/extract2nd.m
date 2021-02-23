clear;clc
% freqs = [8:0.2:15.8];
dirinfo = dir('BCI2nd/cnt文件/BCI2nd')%70 subjects
num_sub = size(dirinfo,1)-2;
sub_index = cell(1,num_sub);%注意，是按照姓名后面的数字读的数据
for i = 1 :num_sub
    sub = dirinfo(i+2).name;
    sub_id = str2num(sub(end-1:end));
    sub_index{sub_id} = sub;
end
stimTime1 = 2;
stimTime2 = 3;
fs = 1000;
chan9 =[48,54,55,56,57,58,61,62,63];
for i = 1 :num_sub
    i
    sub = sub_index{i};
    if i <16
        datum = zeros(9,stimTime1*fs,4,40);
    else
        datum = zeros(9,stimTime2*fs,4,40);
    end
    for j = 1 : 4
        filename = [pwd,'\BCI2nd\cnt文件\BCI2nd\',sub,'\',num2str(j),'.cnt']
        data = loadcnt(filename,'dataformat','int32');
        type = [];
        typeoffset = [];
        for epoch = 1:length(data.event)
            if data.event(epoch).stimtype < 253
                type = [type;data.event(epoch).stimtype];
                typeoffset = [typeoffset;data.event(epoch).offset];
            end
        end
        data64 = double(data.data);
        data9 = data64(chan9,:);
        for chan = 1 : length(chan9)
            data9(chan,:) = filterp1(data9(chan,:)',3,100)';
        end
        for ii = 1 :40
            ind = find(type == ii);
            onset = typeoffset(ind);
            if i <16
               trial = data9(:,140 + onset + 1:140 + onset + stimTime1*fs);
            else
               trial = data9(:,140 + onset + 1:140 + onset + stimTime2*fs);
            end
            datum(:,:,j,ii) = trial;
        end
    end
    save(['DataNeuroscan\S',int2str(i),'_neuroscan'],'datum'); 
    clear datum
end
                
                