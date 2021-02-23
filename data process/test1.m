% freqs = [8:0.2:15.8];
% dirinfo = dir('Data')%146 subjects
% filename_2 = {'data.bdf','evt.bdf'};
% filename_3 = {'data.bdf','data.1.bdf','evt.bdf'};
stimTime = 3;
preTime = 0.5;
postTime = 0.5;
% epochLen = (stimTime + preTime + postTime)*fs;
% fs = 1000;
% for i = 107 :size(dirinfo,1)-2
%     i 
%     data = [];
%     sub = dirinfo(i+2).name;
%     date = dir(['Data\',sub])
%     blocklist = dir(['Data\',sub,'\',date(3).name])
%     epoch = zeros(64,epochLen,4,40);
%     for block = 1 :4
%         filepath = [pwd,'\Data\',sub,'\',date(3).name,'\',blocklist(block+7).name,'\'];
%         EEG = readbdfdata(filename_2, filepath);
%         event = EEG.event;
%         datum = EEG.data;
%         trigger = zeros(1,length(event));
%         k = 0;
%         for j = 1 : size(event,1)
%             if ~(isletter(event(j).type))
%                 k = k + 1;
%                 trigger(str2num(event(j).type)) = event(j).latency;
%             end
%         end
%         datap = zeros(size(datum));
%         for chan = 1 : size(datum,1)
%             datap(chan,:) = filterp1(EEG.data(chan,:)',3,100)';
%         end
%         for ii = 1 : 40
%             if trigger(ii) + stimTime*fs + postTime*fs < size(datap,2)
%                temp = datap(:,trigger(ii)+1-preTime*fs:trigger(ii) + stimTime*fs + postTime*fs);
%             else
%                temp = datap(:,trigger(ii)+1:end);
%             end
%             epoch(:,:,block,ii) = temp;
%         end
%     end
%     data.EEG = epoch;
%     [name, gender, age] = extractInfo(filepath);
%     data.name = name;
%     data.gender = gender;
%     data.age = age;
%     save(['DataNeuracleRaw\S',int2str(i),'_neuracle'],'data'); 
%     clear datum
% end
%%
% clear;clc
% freqs = [8:0.2:15.8];
fs = 1000;
dbstop if error
fileinfo = importdata('E:\1810\sub_info1.csv')
info_cell = cell(length(fileinfo),3);
for i = 1 : length(fileinfo)
    temp = strsplit(fileinfo{i,1},',');
    for j = 1 : 3
        info_cell{i,j} = temp{1,j};
    end
end
dirinfo = dir('BCI2nd/cnt文件/BCI2nd');%70 subjects
num_sub = size(dirinfo,1)-2;
sub_index = cell(1,num_sub);%注意，是按照姓名后面的数字读的数据
for i = 1 :num_sub
    sub = dirinfo(i+2).name;
    sub_id = str2num(sub(end-1:end));
    sub_index{sub_id} = sub;
end
stimTime1 = 2;
stimTime2 = 3;
epochLen = (stimTime + preTime + postTime)*fs;
fs = 1000;
chan9 =[48,54,55,56,57,58,61,62,63];
for i = 1 :num_sub
% for i = 56
    i
    data = [];
    sub = sub_index{i};
    if i <16 
        stimTime = stimTime1;
    else
        stimTime = stimTime2;
    end
    epochLen = (stimTime + preTime + postTime)*fs;
    load(['DataNeuroscanRaw\S',int2str(i),'_neuroscan.mat'])
    datum = data.data;
    name0 = sub_index{i};
    for k = 1 : length(fileinfo)
        sub_name = info_cell{k,1};
        if ~isempty(strfind(name0,sub_name))
            k
            data.EEG = datum;
            data.name = sub_name;
            birthday = info_cell{k,2};
            monthstr = strsplit(birthday,'.');
            month = str2num(cell2mat(monthstr(2)))/12;
            data.age = 2018.5 - floor(str2num(birthday)) - month + 1/12;
            data.gender = info_cell{k,3};
        end
    end
    save(['DataNeuroscanRaw\S',int2str(i),'_neuroscan'],'data'); 
    clear datum
end