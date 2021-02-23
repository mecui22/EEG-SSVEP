runRest = false;
fs = 1000;
stimTime = 3;
freqs = [8:0.2:15.8];
preTime = 0.5;
postTime = 0.5;
block = 1;
epochLen = (stimTime + preTime + postTime)*fs;
currDir = pwd;
dataPath = [currDir,'\data\'];
resultsPath = [currDir,'\results ', datestr(now,'mm-dd-yyyy HH-MM'),'\'];
filename_2 = {'data.bdf','evt.bdf'};
filename_3 = {'data.bdf','data.1.bdf','evt.bdf'};
info=dir(dataPath);
info = info(3:end);

ns = size(info,1);
for sub=1:1:ns
    grps = dir([dataPath,info(sub).name]);
    grps = grps(3:end);
    ng = size(grps,1);
    for group=1:1:ng
        filepath = [dataPath,info(sub).name,'\',grps(group).name,'\'];
        a = size(dir(filepath),1)-2;
        if a==2 
            EEG = readbdfdata(filename_2, filepath);
        elseif a==3
            EEG = readbdfdata(filename_3, filepath);
        elseif a==0
            warning(sprintf('Folder %s is empty', grps(group).name))
            continue
        else
            warning(sprintf('Number of files in %s is not valid', grps(group).name))
            continue
        end
            
    event = EEG.event;
    datum = EEG.data;
    trigger = zeros(1,length(event));
    k = 0;
    for j = 1 : size(event,1)
        if ~(isletter(event(j).type))
            k = k+1;
            trigger(str2num(event(j).type)) = event(j).latency;
        end
    end
        
    datap = zeros(size(datum));
    for chan = 1 : size(datum,1)
        datap(chan,:) = filterp1(EEG.data(chan,:)',3,100)';
    end
        
    for ii = 1 : 40
        if trigger(ii) + stimTime*fs + postTime*fs < size(datap,2)
           temp = datap(:,trigger(ii)+1-preTime*fs:trigger(ii) + stimTime*fs + postTime*fs);
        else
           temp = datap(:,trigger(ii)+1:end);
        end
        epoch(:,:,block,ii) = temp;
    end
        
    data.EEG = epoch;
%     [name, gender, age] = extractInfo(filepath);
%     data.name = name;
%     data.gender = gender;
%     data.age = age;
%       save([filepath,'.mat'],'data'); 
%     clear datum
 %%%%%%%%%%%%%%%%%%%%%%%%%%Êý¾Ý·ÖÎö%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    load('freqV_first.mat');

    data_EEG = data.EEG;
    datum_notch = notch_filt_neuracle(data_EEG,fs);
    datum0 = datum_notch(:,500+1+140:500+stimTime*fs+140,:,:);
    padding = zeros(64,2000,1,40);
    datum = cat(2,datum0,padding);
    savepath = [resultsPath,info(sub).name,'\',grps(group).name,'\'];
    % Spectrum Analysis£º 1.Spectrum plot  
    sub_SpectrumAnalysis(datum,freqV,savepath,group,'neuracle12');
    % Topographic map of spectrum
    sub_TopograhicAnalysis(datum,freqV,savepath,group,'neuracle12');
    % 3 SNR histogram 
    sub_SNRAnalysis(datum,freqV,savepath,group,'neuracle12');
    % FBCCA¡¢TRCA¡¢TRCA acc\ITR mat
    sub_BCIAnalysis(datum,freqV,savepath,group,'neuracle12');
    % 4 band topographic map
    sub_RhythmAnalysis(datum,freqV,savepath,group,'neuracle12');
    
    if 
    end
end

% for i=1:1:26
%  duiying4(i,1)=node_p4(duiying(i,1))/(node_p4(duiying(i,1))+node_p4(duiying(i,2)));
% end
% 
% for i=1:1:26
%  duiying4(i,2)=node_p4(duiying(i,2))/(node_p4(duiying(i,1))+node_p4(duiying(i,2)));
% end
