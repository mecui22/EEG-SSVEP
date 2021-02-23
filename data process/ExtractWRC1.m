freqs = [8:0.2:15.8];
dirinfo = dir('Data')%146 subjects
filename_2 = {'data.bdf','evt.bdf'};
filename_3 = {'data.bdf','data.1.bdf','evt.bdf'};
stimTime = 3;
preTime = 0.5;
postTime = 0.5;
epochLen = (stimTime + preTime + postTime)*fs;
fs = 1000;
for i = 25
    i 
    data = [];
    sub = dirinfo(i+2).name;
    date = dir(['Data\',sub])
    blocklist = dir(['Data\',sub,'\',date(3).name])
    matfile = ['D:\WRCdata\DataNeuracleRaw\S',num2str(i),'_neuracle.mat'];
    load(matfile)
%     epoch = zeros(64,epochLen,4,40);
    for block = 1 :4
        filepath = [pwd,'\Data\',sub,'\',date(3).name,'\',blocklist(block+7).name,'\'];
    end
    [name, gender, age] = extractInfo(filepath);
    data.name = name;
%     data.gender = gender;
%     data.age = age;
    save(['DataNeuracleRaw\S',int2str(i),'_neuracle'],'data'); 
%     clear datum
end
%%
% clear;clc
% freqs = [8:0.2:15.8];
% dbstop if error
% fileinfo = importdata('E:\1810\sub_info1.csv')
% info_cell = cell(length(fileinfo),3);
% for i = 1 : length(fileinfo)
%     temp = strsplit(fileinfo{i,1},',');
%     for j = 1 : 3
%         info_cell{i,j} = temp{1,j};
%     end
% end
% dirinfo = dir('BCI2nd/cnt文件/BCI2nd');%70 subjects
% num_sub = size(dirinfo,1)-2;
% sub_index = cell(1,num_sub);%注意，是按照姓名后面的数字读的数据
% for i = 1 :num_sub
%     sub = dirinfo(i+2).name;
%     sub_id = str2num(sub(end-1:end));
%     sub_index{sub_id} = sub;
% end
% stimTime1 = 2;
% stimTime2 = 3;
% epochLen = (stimTime + preTime + postTime)*fs;
% fs = 1000;
% chan9 =[48,54,55,56,57,58,61,62,63];
% % for i = 1 :num_sub
% for i = 56
%     i
%     data = [];
%     sub = sub_index{i};
%     if i <16 
%         stimTime = stimTime1;
%     else
%         stimTime = stimTime2;
%     end
%     epochLen = (stimTime + preTime + postTime)*fs;
%     datum = zeros(64,epochLen,4,40);
%     for j = 1 : 4
%         filename = [pwd,'\BCI2nd\cnt文件\BCI2nd\',sub,'\',num2str(j),'.cnt']
%         EEG = loadcnt(filename,'dataformat','int32');
%         type = [];
%         typeoffset = [];
%         for epoch = 1:length(EEG.event)
%             if EEG.event(epoch).stimtype < 253
%                 type = [type;EEG.event(epoch).stimtype];
%                 typeoffset = [typeoffset;EEG.event(epoch).offset];
%             end
%         end
%         data64 = double(EEG.data);
% %         data9 = data64(chan9,:);
%         datap = zeros(size(data64));
%         for chan = 1 : size(data64,1)
%             datap(chan,:) = filterp1(data64(chan,:)',3,100)';
%         end
%         for ii = 1 :40
%             ind = find(type == ii);
%             onset = typeoffset(ind);
%             if onset + stimTime*fs + postTime*fs > size(datap,2)
%                trial = datap(:, onset + 1 - preTime*fs: end);
%             else
%                trial = datap(:, onset + 1 - preTime*fs: onset + stimTime*fs + postTime*fs);
%             end
%             datum(:,:,j,ii) = trial;
%         end
%     end
%     name0 = sub_index{i};
%     for k = 1 : length(fileinfo)
%         sub_name = info_cell{k,1};
%         if ~isempty(strfind(name0,sub_name))
%             k
%             data.EEG = datum;
%             data.name = sub_name;
%             birthday = info_cell{k,2};
%             monthstr = strsplit(birthday,'.');
%             month = str2num(cell2mat(monthstr(2)))/12;
%             data.age = 2018.5 - floor(str2num(birthday)) - month + 1/12;
%             data.gender = info_cell{k,3};
%         end
%     end
%     save(['DataNeuroscanRaw\S',int2str(i),'_neuroscan'],'data'); 
%     clear datum
% end