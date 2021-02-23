clear;clc;
load('data_neuracle.mat')
fs = 1000;
freq = [8:0.2:15.8];
for i = 1 : size(data_nc,5)
    i
    for j = 1 :size(data_nc,4)
        for k = 1 : size(data_nc,3)
            for ii = 1 : size(data_nc,1)
                narrow_snr_nc(ii,k,j,i) = calculateSNRnarrow(data_nc(ii,:,k,j,i),fs,freq(j),5,5);
                wide_snr_nc(ii,k,j,i) = calculateSNRwide(data_nc(ii,:,k,j,i),freq(j));
            end
        end
    end
end
for i = 1 : 40
    i
    for j = 1 : 4
        projection_snr_nc(:,j,i) = calculateSNRprojection(permute(squeeze(data_nc(:,:,j,:,i)),[3,1,2]),freq,1000,5);
    end
end
% clear data_nc
load('data_neuroscan.mat')
for i = 1 : size(data_ns,5)
    i
    for j = 1 :size(data_ns,4)
        for k = 1 : size(data_ns,3)
            for ii = 1 : size(data_ns,1)
                narrow_snr_ns(ii,k,j,i) = calculateSNRnarrow(data_ns(ii,:,k,j,i),fs,freq(j),5,5);
                wide_snr_ns(ii,k,j,i) = calculateSNRwide(data_ns(ii,:,k,j,i),freq(j));
            end
        end
    end
end
for i = 1 : 70
    i
    for j = 1 : 4
        projection_snr_ns(:,j,i) = calculateSNRprojection(permute(squeeze(data_ns(:,:,j,:,i)),[3,1,2]),freq,1000,5);
    end
end
%%
s_narrow_snr_nc = narrow_snr_nc(:);
s_narrow_snr_ns= narrow_snr_ns(:);
%%
%统计数据缺失率
num_miss_nc = length(find(s_narrow_snr_nc==-inf))/length(s_narrow_snr_nc);%0.0756%
num_miss_ns = length(find(s_narrow_snr_ns==-inf))/length(s_narrow_snr_ns);%0
%%
%窄带信噪比
s_narrow_snr_nc = remove_nan(s_narrow_snr_nc);
s_narrow_snr_ns = remove_nan(s_narrow_snr_ns);
close all
figure
histogram(s_narrow_snr_nc,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','r')
hold on 
histogram(s_narrow_snr_ns,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','b')
xlabel('SNR (dB)')
ylabel('Proportion')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
% set(gca,'xlim',[-50,10])
mean(s_narrow_snr_nc,'omitnan')%11.4121dB
mean(s_narrow_snr_ns,'omitnan')%11.8537dB
[a,b] = ttest2(s_narrow_snr_nc,s_narrow_snr_ns)%p=2.5148e-16
%%
%宽带信噪比
s_wide_snr_nc = wide_snr_nc(:);
s_wide_snr_ns= wide_snr_ns(:);
close all
figure
histogram(s_wide_snr_nc,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','r')
hold on 
histogram(s_wide_snr_ns,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','b')
set(gca,'xlim',[-50,10])
xlabel('SNR (dB)')
ylabel('Proportion')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
s_wide_snr_nc = remove_inf(s_wide_snr_nc);
s_wide_snr_ns = remove_inf(s_wide_snr_ns);
mean(s_wide_snr_nc,'omitnan')% -14.2497dB
mean(s_wide_snr_ns,'omitnan')% 	
[a,b] = ttest2(s_wide_snr_nc,s_wide_snr_ns)%p=6.7400e-203
%%
wide_snr_nc = remove_nan(wide_snr_nc);
wide_snr_ns = remove_nan(wide_snr_ns);
narrow_snr_nc = remove_nan(narrow_snr_nc);
narrow__snr_ns = remove_nan(narrow_snr_ns);
m_wide_snr_nc = squeeze(mean(wide_snr_nc,2,'omitnan'));
mc_wide_snr_nc = squeeze(mean(m_wide_snr_nc,1,'omitnan'));
mcf_wide_snr_nc = squeeze(mean(mc_wide_snr_nc,1,'omitnan'));
%
m_wide_snr_ns = squeeze(mean(wide_snr_ns,2,'omitnan'));
mc_wide_snr_ns = squeeze(mean(m_wide_snr_ns,1,'omitnan'));
mcf_wide_snr_ns = squeeze(mean(mc_wide_snr_ns,1,'omitnan'));
%
figure
histogram(mcf_wide_snr_nc,[-22:1:-6],'FaceAlpha',0.4,'FaceColor','r')
% hold on 
% histogram(mcf_wide_snr_ns,[-22:1:-6],'FaceAlpha',0.4,'FaceColor','b')
set(gca,'xlim',[-22,-6])
xlabel('SNR (dB)')
ylabel('Number of subjects')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
close all
%对比同一人的信噪比
dirinfo = dir('Data');
for i = 1 :size(dirinfo,1)-2
    name_nc{i} = dirinfo(i+2).name;
end
% save name_nc.mat name_nc
dirinfo = dir('BCI2nd/cnt文件/BCI2nd')%70 subjects
num_sub = size(dirinfo,1)-2;
name_ns = cell(1,num_sub);
for i = 1 :num_sub
    sub = dirinfo(i+2).name;
    sub_id = str2num(sub(end-1:end));
    name_ns{sub_id} = sub;
end
% save name_ns.mat name_ns
ns_index = 1 + [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17, 20, 21, 22, 23, 24, 25, 26, 27, 30, 31, 32, 33, 34, 35, 36, 37, 38, 40, 41, 42, 43, 44, 46, 47, 51, 52, 55, 56, 57, 59, 60, 61, 64, 65, 67]
nc_index = 1 + [116, 114, 112, 95, 19, 12, 99, 36, 134, 56, 42, 1, 16, 63, 57, 69, 110, 21, 78, 133, 3, 100, 49, 64, 55, 144, 130, 66, 17, 87, 59, 127, 48, 37, 32, 106, 39, 28, 119, 141, 7, 82, 70, 72, 138, 6, 120, 97, 125, 46]
ns_snr = wide_snr_ns(:,:,:,ns_index);
nc_snr = wide_snr_nc(:,:,:,nc_index);
cns_snr = squeeze(mean(ns_snr,1,'omitnan'));
cbns_snr = squeeze(mean(cns_snr,1,'omitnan'));
cbfns_snr = squeeze(mean(cbns_snr,1,'omitnan'));
%
cnc_snr = squeeze(mean(nc_snr,1,'omitnan'));
cbnc_snr = squeeze(mean(cnc_snr,1,'omitnan'));
cbfnc_snr = squeeze(mean(cbnc_snr,1,'omitnan'));
mean(cbfns_snr) - mean(cbfnc_snr)
%
figure
scatter(1:50,cbfns_snr,50,'FaceColor','b')
hold on
scatter(1:50,cbfnc_snr,50,'FaceColor','r')
hold on 
plot([0,50],[mean(cbfns_snr),mean(cbfns_snr)],'b','LineWidth',1.5)
hold on 
plot([0,50],[mean(cbfnc_snr),mean(cbfnc_snr)],'r','LineWidth',1.5)
hold on
set(gca,'xlim',[0,50])
ylabel('SNR (dB)')
xlabel('Subject number')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
[a,~] = ttest(cbfns_snr,cbfnc_snr)
%%
%叠加平均后的频谱图
datasum = cat(5,data_nc,data_ns);
datasumb = squeeze(mean(datasum,3));
datasumbs = squeeze(mean(datasumb,4));
figure
for i = 1 : 40
    subplot(5,8,i)
    plotspectrum(datasumbs(8,:,i),'r')
    if mod(i-1,8)==0
       ylabel('|H(e^j^\omega)|');
    end
    if i > 31
        xlabel('f/Hz');
    end
    set(gca,'Box','off')
    set(gca,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'Fontname','Times New Roman');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','bold');
end
%%
%与标准数据集的SNR对比
snr_2018 = cat(4,wide_snr_nc,wide_snr_ns);
snr_2018_narrow = cat(4,narrow_snr_nc,narrow_snr_ns);
load('D:\Dataset\Benchmark original data\benchmark.mat')
load('D:\Dataset\Benchmark mat data\BenchmarkDataset\Freq_Phase.mat')
for i = 1 : 35
    i
    for j = 1 : 6
        for k = 1 : 9
            for ii = 1 : 40
                epoch = dataclass(k,140+1+500:140+5000+500,ii,j,i);
                snr_2015(ii,k,j,i) = calculateSNRwide(epoch,freqs(ii));
            end
        end
    end
end
snr_2018m = snr_2018(:);
snr_2015m = snr_2015(:);
%%
figure
histogram(snr_2015m,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','b')
hold on
histogram(snr_2018m,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','r')
set(gca,'xlim',[-50,10])
xlabel('SNR (dB)')
ylabel('Proportion')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
mean(snr_2018m,'omitnan')% -14.0902dB
mean(snr_2015m,'omitnan')% -13.3719dB
[a,b] = ttest2(snr_2018m,snr_2015m)%p=0
%%
data2015 = dataclass(:,140+1+500:140+5000+500,:,:,:);
data2015m = squeeze(mean(data2015,5));
data2015ms = squeeze(mean(data2015m,4));
%%
%不同频率的信噪比
snr_2018 = remove_nan(snr_2018);
snr_2018c = squeeze(mean(snr_2018,1,'omitnan'));
snr_2018c1 = permute(snr_2018c,[2,1,3]);
snr_2018cf = reshape(snr_2018c1,[40,4*216]);
snr_2018cf_m = mean(snr_2018cf,2,'omitnan');
snr_2018cf_std = std(snr_2018cf,0,2,'omitnan');
%
snr_2018_narrow = remove_nan(snr_2018_narrow);
snr_2018_narrowc = squeeze(mean(snr_2018_narrow,1,'omitnan'));
snr_2018_narrowc1 = permute(snr_2018_narrowc,[2,1,3]);
snr_2018_narrowcf = reshape(snr_2018_narrowc1,[40,4*216]);
snr_2018_narrowcf_m = mean(snr_2018_narrowcf,2,'omitnan');
snr_2018_narrowcf_std = std(snr_2018_narrowcf,0,2,'omitnan');
%
close all
fig = figure
u = fig.Units;
fig.Units = 'points';
errorbar([8:0.2:15.8],snr_2018cf_m,snr_2018cf_std,'k','LineStyle','none')
hold on
b1 = bar([8:0.2:15.8],snr_2018cf_m)
b1.BaseValue = -30;
set(b1,'DisplayName','Anodal','FaceColor',[0.8 0.8 0.8],...
    'BarWidth',0.8,'LineWidth',1.5);
xlabel('Stimulus frequency (Hz)')
ylabel('SNR (dB)')
set(gca,'Xlim',[7.8,16])
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[30,100,820,330], 'color','w')
%%
%扫频信噪比图
close all
datasumbsc = squeeze(mean(datasumbs,1));
a = colormap('gray');
a = flipud(a);
close all
for i = 1 : 40
   dspectrum(i,:) = spectrum1(datasumbsc(:,i));
end
figure('Color',[1 1 1])
surf(freq,0:1/5:500-1/5,dspectrum','lineStyle','none')
view([0 90])
set(gca,'ylim',[8,90])
set(gca,'xlim',[8,15.8])
% set(gca,'XTick',[4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44])
colormap('jet')
colorbar
% caxis([0 0.1])
set(gca,'FontWeight','bold');
set(gca,'Fontname','Times New Roman');
xlabel('Stimulus Frequency (Hz)')
ylabel('Response Frequency (Hz)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%% 性别分析
% load('sex_index_nc.mat')
% load('sex_index_ns.mat')
load('name_ns.mat')
load('name_nc.mat')
dirinfo = dir('Data');
load('info_ns.mat')
ages_nc = zeros(1,size(dirinfo,1)-2);
sex_nc = zeros(1,size(dirinfo,1)-2);
for i = 1 :size(dirinfo,1)-2
    name = dirinfo(i+2).name;
    folder = dir(['Data\',name]);
    date = folder(3).name;
    folders = dir(['Data\',name,'\',date]);
    block = folders(8).name;
    filename = ['Data\',name,'\',date,'\',block,'\recordInformation.json'];
    if i == 107 || i == 128
        sex_nc(i) = 0; 
        ages_nc(i) = 2008-1990;
    elseif i == 129
        sex_nc(i) = 1; 
        ages_nc(i) = 2008-1990;   
    else
        file = loadjson(filename);
        gender = file.Gender;
        birthday = file.BirthDate;
        age = 2018 - (str2num(birthday(1:4))-double(str2num(birthday(6:7)))/12);
        ages_nc(i) = age;
        sex_nc(i) = gender;
    end
end
%
ages_ns = zeros(1,70);
sex_ns = zeros(1,70);
for i = 1 :70
    for j = 1 : size(info_ns,1)
        if strcmp(info_ns{j,1},name_ns{i}(1:end-2))
            ages_ns(i) = 2018-info_ns{j,2};
            sex_ns(i) = strcmp(info_ns{j,3},'female');
        end
    end
end
ages_all = [ages_nc,ages_ns];
sex_all = [sex_nc,sex_ns];
% save sex_all.mat sex_all
%%
sub = [1:size(snr_2018,4)];
male_snr = snr_2018(:,:,:,find(sex_all==0));
female_snr = snr_2018(:,:,:,find(sex_all==1));
male_snrb = squeeze(mean(male_snr,2,'omitnan'));
female_snrb = squeeze(mean(female_snr,2,'omitnan'));
male_snrbc = squeeze(mean(male_snrb,2,'omitnan'));
female_snrbc = squeeze(mean(female_snrb,2,'omitnan'));
male_snrbcf = squeeze(mean(male_snrbc,1,'omitnan'));
female_snrbcf = squeeze(mean(female_snrbc,1,'omitnan'));
male_snrt = male_snr(:);
female_snrt = female_snr(:);
% gender trial
figure
histogram(female_snrt,50,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','r')
hold on
histogram(male_snrt,50,'Normalization','probability','BinWidth',1,'FaceAlpha',0.4,'FaceColor','b')
set(gca,'xlim',[-50,10])
xlabel('SNR (dB)')
ylabel('Proportion')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
mean(male_snrt,'omitnan')% -14.4897dB
mean(female_snrt,'omitnan')% -13.4502dB
[a,b] = ttest2(male_snrt,female_snrt)%p=0
%%
% gender person
close all
fig = figure
u = fig.Units;
b1 = bar([1,2],[mean(male_snrbcf,'omitnan'),mean(female_snrbcf,'omitnan')])
hold on
errorbar([1,2],[mean(male_snrbcf,'omitnan'),mean(female_snrbcf,'omitnan')],[std(male_snrbcf,'omitnan'),std(female_snrbcf,'omitnan')],'k','LineStyle','none')
b1.BaseValue = -25;
set(b1,'DisplayName','Anodal','FaceColor',[0.8 0.8 0.8],...
    'BarWidth',0.5,'LineWidth',1.5);
xlabel('Gender')
ylabel('SNR (dB)')
set(gca,'XTicklabel',{'Male','Female'})
set(gca,'Xlim',[0,3])
set(gca,'Ylim',[-25,-5])
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
[a,b] = ttest2(male_snrbcf,female_snrbcf)%p=0.0213
% set(gcf,'Position',[30,100,820,330], 'color','w')
%%
%age person
snr_2018c = squeeze(mean(snr_2018,1,'omitnan'));
snr_2018cb = squeeze(mean(snr_2018c,1,'omitnan'));
snr_2018cbf = squeeze(mean(snr_2018cb,1,'omitnan'));
%
snr_2018_narrowc = squeeze(mean(snr_2018_narrow,1,'omitnan'));
snr_2018_narrowcb = squeeze(mean(snr_2018_narrowc,1,'omitnan'));
snr_2018_narrowcbf = squeeze(mean(snr_2018_narrowcb,1,'omitnan'));
%
[ages_all_sort,sort_ind] = sort(ages_all);
snr_2018cbf_sorted = snr_2018cbf(sort_ind);
sex_sorted_by_age = sex_all(sort_ind);
male_index = find(sex_sorted_by_age==0);
female_index = find(sex_sorted_by_age==1);
male_snr_sorted_by_age = snr_2018cbf_sorted(male_index);
female_snr_sorted_by_age = snr_2018cbf_sorted(female_index);
male_sorted_age = ages_all_sort(male_index);
female_sorted_age = ages_all_sort(female_index);
%male&female
figure
scatter(male_sorted_age(2:end),male_snr_sorted_by_age(2:end),50,'FaceColor','b')
hold on
scatter(female_sorted_age,female_snr_sorted_by_age,50,'FaceColor','r')
hold on
scatter(ages_all(91),snr_2018cbf(itr_ind(1)),50,'FaceColor','y')
xlabel('Age')
ylabel('ITR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
% all
figure
scatter(ages_all_sort(2:end),snr_2018cbf_sorted(2:end),50,'FaceColor','r')
xlabel('Age')
ylabel('SNR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')

%% gender age description
figure
histogram(ages_all_sort(2:end),'FaceAlpha',0.4,'FaceColor','r')
% set(gca,'xlim',[-50,10])
xlabel('Age')
ylabel('Proportion')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
mean(ages_all_sort(2:end))
length(male_snrbcf)
length(female_snrbcf)
%%
projection_snr_ncm = zeros(40,4,146);
projection_snr_ncm(:,:,121:146) =  projection_snr_nc(:,:,121:146);
save projection_snr_ncm 
%%
projection_snr_nsm = zeros(40,4,70);
projection_snr_nsm(:,:,31:70) =  projection_snr_ns(:,:,31:70);
projection_snr = cat(3,projection_snr_ncm,projection_snr_nsm);
save projection_snr.mat projection_snr