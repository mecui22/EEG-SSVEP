clear;clc;
load('data_neuroscan.mat')
time = [200:200:3000];
freq = [8:0.2:15.8];
for k =  1 : length(time)
    for i = 1 : 70
        k,i
        for j = 1 : 4
            cnt = 0;
            for ii = 1 : 40
                epoch = data_ns(:,1:time(k),j,ii,i);
                epoch_down = downsample(epoch',4);
                prediction = fbcca(epoch_down,time(k)/1000,freq);
                cnt = cnt +(prediction==ii);
            end
            acc_ns(k,j,i) = cnt/40;
        end
    end
end
%%
dirinfo = dir('Result')%146 subjects
% for i = 1 :size(dirinfo,1)-2
for i = 1 :size(dirinfo,1)-2
    i
    load(['Result\',dirinfo(i+2).name]);
    acc_nc(:,:,i) = result.accFBCCA;
end
for i = 1 :size(dirinfo,1)-2
    i
    load(['Result\',dirinfo(i+2).name]);
    acc_trca_nc(:,:,i) = result.accTRCA
end
for i = 1 : 70
    i
    load(['E:\BCI2018\DataNeuroscanInfo\S',num2str(i),'\S',num2str(i),'-bci.mat']);
    acc_trca_ns(:,:,i) = bci.acc_trca;
end
%%
acc_all = cat(3,acc_nc,acc_ns);
save acc_fbcca.mat acc_all
%%
load('acc_fbcca.mat')
acc_nc = acc_all(:,:,1:146);
acc_ns = acc_all(:,:,147:end);
timestamp = [0.2:0.2:3];
% acc_trca_all = cat(3,acc_trca_nc,acc_trca_ns);
for i = 1 : size(acc_all,3)
    for j = 1 : size(acc_all,2)
        for k = 1 : size(acc_all,1)
            itr_all(k,j,i) = convert_itr(acc_all(k,j,i),timestamp(k));
        end
    end
end
%%
for i = 1 : size(acc_ns,3)
    for j = 1 : size(acc_ns,2)
        for k = 1 : size(acc_ns,1)
            itr_ns(k,j,i) = convert_itr(acc_ns(k,j,i),timestamp(k));
        end
    end
end
for i = 1 : size(acc_nc,3)
    for j = 1 : size(acc_nc,2)
        for k = 1 : size(acc_nc,1)
            itr_nc(k,j,i) = convert_itr(acc_nc(k,j,i),timestamp(k));
        end
    end
end
%%
close all
accm = squeeze(mean(acc_all,2));
accm_ns = squeeze(mean(acc_ns,2));
accm_nc = squeeze(mean(acc_nc,2));
figure
plot(time/1000,mean(accm_nc,2),'b','LineWidth',2)
hold on
plot(time/1000,mean(accm_ns,2),'g','LineWidth',2)
hold on
plot(time/1000,mean(accm,2),'r','LineWidth',2)
% legend('FBCCA','Location','northwest')
legend('boxoff')
hold on
errorbar(time/1000,mean(accm_nc,2),std(accm_nc,0,2),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(accm_ns,2),std(accm_ns,0,2),'g','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(accm,2),std(accm,0,2),'r','LineStyle','none','LineWidth',2)
set(gca,'xlim',[100,250*3.2]/250)
set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('Accuracy')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
%%
% close all
itrm = squeeze(mean(itr_all,2));
accm_ns = squeeze(mean(itr_ns,2));
accm_nc = squeeze(mean(itr_nc,2));
figure
plot(time/1000,mean(accm_nc,2),'b','LineWidth',2)
hold on
plot(time/1000,mean(accm_ns,2),'g','LineWidth',2)
hold on
plot(time/1000,mean(itrm,2),'r','LineWidth',2)
% legend('FBCCA','Location','northwest')

hold on
errorbar(time/1000,mean(accm_nc,2),std(accm_nc,0,2),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(accm_ns,2),std(accm_ns,0,2),'g','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(itrm,2),std(itrm,0,2),'r','LineStyle','none','LineWidth',2)
legend('off')
set(gca,'xlim',[100,250*3.2]/250)
% set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('ITR (bpm)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
%% gender accuracy
close all
male_acc = acc_all(:,:,find(sex_all==0));
female_acc = acc_all(:,:,find(sex_all==1));
male_accm = squeeze(mean(male_acc,2));
female_accm = squeeze(mean(female_acc,2));
figure
plot(time/1000,mean(male_accm,2),'b','LineWidth',2)
hold on
plot(time/1000,mean(female_accm,2),'r','LineWidth',2)
% legend('FBCCA','Location','northwest')
legend('boxoff')
hold on
errorbar(time/1000,mean(male_accm,2),std(male_accm,0,2),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(female_accm,2),std(female_accm,0,2),'r','LineStyle','none','LineWidth',2)
set(gca,'xlim',[100,250*3.2]/250)
set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('Accuracy')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
for i = 1 :size(male_accm,1)
    [a,pval_acc(i)] = ttest2(male_accm(i,:),female_accm(i,:));
end
%% gender ITR
close all
male_acc = itr_all(:,:,find(sex_all==0));
female_acc = itr_all(:,:,find(sex_all==1));
male_accm = squeeze(mean(male_acc,2));
female_accm = squeeze(mean(female_acc,2));
figure
plot(time/1000,mean(male_accm,2),'b','LineWidth',2)
hold on
plot(time/1000,mean(female_accm,2),'r','LineWidth',2)
% legend('FBCCA','Location','northwest')

hold on
errorbar(time/1000,mean(male_accm,2),std(male_accm,0,2),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(female_accm,2),std(female_accm,0,2),'r','LineStyle','none','LineWidth',2)
legend('off')
set(gca,'xlim',[100,250*3.2]/250)
% set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('ITR (bpm)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
for i = 1 :size(male_accm,1)
    [a,pval_itr(i)] = ttest2(male_accm(i,:),female_accm(i,:));
end
%%
% Age-accuracy
[ages_all_sort,sort_ind] = sort(ages_all);
acc_age_sort0 = accm(:,sort_ind);
acc_age_sort = acc_age_sort0(:,2:end)';
figure('Color',[1 1 1])
surf(ages_all_sort(2:end),0.2:0.2:3,acc_age_sort','lineStyle','none')
view([0 90])
colormap('jet')
c = colorbar
c.Label.String = 'Accuracy';
set(gca,'xlim',[ages_all_sort(2),ages_all_sort(end)])
set(gca,'ylim',[0.2,3])

xlabel('Age')
ylabel('Time (s)')
set(gca,'Box','off')
% set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
% age-ITR
[ages_all_sort,sort_ind] = sort(ages_all);
itr_age_sort0 = itrm(:,sort_ind);
itr_age_sort = itr_age_sort0(:,2:end)';
figure('Color',[1 1 1])
surf(ages_all_sort(2:end),0.2:0.2:3,itr_age_sort','lineStyle','none')
view([0 90])
colormap('jet')
c = colorbar
c.Label.String = 'ITR (bpm)';
set(gca,'xlim',[ages_all_sort(2),ages_all_sort(end)])
set(gca,'ylim',[0.2,3])
caxis([0,150])
xlabel('Age')
ylabel('Time (s)')
set(gca,'Box','off')
% set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%Age-maximum ITR
itrmax = max(itrm,[],1);
[ages_all_sort,sort_ind] = sort(ages_all);
itrmax_sorted = itrmax(sort_ind);
sex_sorted_by_age = sex_all(sort_ind);
male_index = find(sex_sorted_by_age==0);
female_index = find(sex_sorted_by_age==1);
male_itr_sorted_by_age = itrmax_sorted(male_index);
female_itr_sorted_by_age = itrmax_sorted(female_index);
male_sorted_age = ages_all_sort(male_index);
female_sorted_age = ages_all_sort(female_index);
%all
figure
scatter(ages_all_sort(2:end),itrmax_sorted(2:end),50,'r','filled')
xlabel('Age')
ylabel('ITR (bpm)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%
figure
scatter(male_sorted_age(2:end),male_itr_sorted_by_age(2:end),50,'b','filled')
hold on
scatter(female_sorted_age,female_itr_sorted_by_age,50,'r','filled')
xlabel('Age')
ylabel('ITR (bpm)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%ITR的相关因素
%ITR,SNR
%宽带
[itr_val_sorted,itr_ind] = sort(itrmax)%213
coeff_wide =  LinearModel.fit(itr_val_sorted,snr_2018cbf(itr_ind));
a_wide = coeff_wide.Coefficients{2,1}
b_wide = coeff_wide.Coefficients{1,1};
figure
scatter(itrmax(find(sex_all==0)),snr_2018cbf(find(sex_all==0)),50,'b','filled')
hold on
scatter(itrmax(find(sex_all==1)),snr_2018cbf(find(sex_all==1)),50,'r','filled')
hold on
plot(itr_val_sorted,a_wide*itr_val_sorted+b_wide,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('SNR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%窄带
coeff_narrow =  LinearModel.fit(itr_val_sorted,snr_2018_narrowcbf(itr_ind));
a_narrow = coeff_narrow.Coefficients{2,1}
b_narrow = coeff_narrow.Coefficients{1,1};
figure
scatter(itrmax(find(sex_all==0)),snr_2018_narrowcbf(find(sex_all==0)),50,'b','filled')
hold on
scatter(itrmax(find(sex_all==1)),snr_2018_narrowcbf(find(sex_all==1)),50,'r','filled')
hold on
plot(itr_val_sorted,a_narrow*itr_val_sorted+b_narrow,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('SNR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%投影
projection_snrf = squeeze(mean(projection_snr,1,'omitnan'));
projection_snrfb = squeeze(mean(projection_snrf,1,'omitnan'));
coeff_narrow =  LinearModel.fit(itr_val_sorted,projection_snrfb(itr_ind));
a_narrow = coeff_narrow.Coefficients{2,1}
b_narrow = coeff_narrow.Coefficients{1,1};
figure
scatter(itrmax(find(sex_all==0)),projection_snrfb(find(sex_all==0)),50,'b','filled')
hold on
scatter(itrmax(find(sex_all==1)),projection_snrfb(find(sex_all==1)),50,'r','filled')
hold on
plot(itr_val_sorted,a_narrow*itr_val_sorted+b_narrow,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('SNR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%ITR, alpha power
for i = 1 : size(data_nc,5)
    for j = 1 : size(data_nc,3)
    end
end
%%
names_all = cat(2,name_nc,name_ns);
[itr_val_sorted,itr_ind] = sort(itrmax)%213
names_best = names_all(itr_ind(end-10:end))
itr_val_sorted(end-10:end)
snr_2018cbf(itr_ind([end-10,end-8:end]))
sex_all(itr_ind([end-10,end-8:end]))
a = accm(:,itr_ind([end-10,end-8:end]))
accm1 = a([2:2:10],:)'
names_worst = names_all(itr_ind(1:10))
snr_2018cbf(itr_ind([1:10]))
sex_all(itr_ind([1:10]))
b = accm(:,itr_ind([1:10]))
accm1 = b([2:2:10],:)'
itr_val_sorted(end-10:end)
%%
close all
% spectrum of the best and worst
ind_max = itr_ind([end-10,end-8:end]);
datasumb = squeeze(mean(datasum(:,:,:,:,ind_max(end-3)),3));
datasumbs = squeeze(mean(datasumb,4));
figure
for i = 1 : 40
    subplot(5,8,i)
    plotspectrumc(datasumbs(8,:,i),freq(i),'r')
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
close all
% spectrum of the best and worst
ind_min = itr_ind([1:10]);
datasumb = squeeze(mean(datasum(:,:,:,:,ind_min(3)),3));
datasumbs = squeeze(mean(datasumb,4));
figure
for i = 1 : 40
    subplot(5,8,i)
    plotspectrumc(datasumbs(8,:,i),freq(i),'r')
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
%rhythms
alpha = [8,13];
for i = 1 : size(datasum,5)
    i
    for j = 1 :size(datasum,4)
        for k = 1 : size(datasum,3)
            for ii = 1 : size(datasum,1)
                ryhthms(ii,k,j,i) =  calculateSpectralSum(datasum(ii,:,k,j,i),alpha,freq(j),fs);
            end
        end
    end
end
%%
close all
ryhthmsc = squeeze(mean(ryhthms,1,'omitnan'));
ryhthmscb = squeeze(mean(ryhthmsc,1,'omitnan'));
ryhthmscbf = squeeze(mean(ryhthmscb,1,'omitnan'));   
figure
scatter(itrmax(find(sex_all==0)),ryhthmscbf(find(sex_all==0)),50,'FaceColor','b')
hold on
scatter(itrmax(find(sex_all==1)),ryhthmscbf(find(sex_all==1)),50,'FaceColor','r')
set(gca,'ylim',[0,30])
xlabel('ITR (bpm)')
ylabel('Rhythms (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
ryhthmsc = squeeze(mean(ryhthms,1,'omitnan'));
ryhthmscb = squeeze(mean(ryhthmsc,1,'omitnan'));
ryhthmscbf = squeeze(mean(ryhthmscb,1,'omitnan'));   
figure
scatter(snr_2018cbf(find(sex_all==0)),ryhthmscbf(find(sex_all==0)),50,'FaceColor','b')
hold on
scatter(snr_2018cbf(find(sex_all==1)),ryhthmscbf(find(sex_all==1)),50,'FaceColor','r')
xlabel('SNR (dB)')
ylabel('Rhythms (dB)')
set(gca,'ylim',[0,30])
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%pho值分析
for i = 1 : size(data_nc,5)
    i
    for j = 1 : 4
        cnt = 0;
        for ii = 1 : 40
            epoch = data_nc(:,1:3*fs,j,ii,i);
            epoch_down = downsample(epoch',4);
            if sum(sum(epoch_down))~= 0
                [prediction,rho] = fbcca(epoch_down,3,freq);
                cnt = cnt +(prediction==ii);
                rhom_nc(i,j,ii) = rho;
            else
                rhom_nc(i,j,ii) = NaN;
            end
        end
        acc_nc(j,i) = cnt/40
    end
end
for i = 1 : size(data_ns,5)
    i
    for j = 1 : 4
        cnt = 0;
        for ii = 1 : 40
            epoch = data_ns(:,1:3*fs,j,ii,i);
            epoch_down = downsample(epoch',4);
            if sum(sum(epoch_down))~= 0
                [prediction,rho] = fbcca(epoch_down,3,freq);
                cnt = cnt +(prediction==ii);
                rhom_ns(i,j,ii) = rho;
            else
                rhom_ns(i,j,ii) = NaN;
            end
        end
        acc_ns(j,i) = cnt/40
    end
end
%%
rhom = cat(1,rhom_nc,rhom_ns);
acc_cca = cat(2,acc_nc,acc_ns);
rhom_ccaf = squeeze(mean(rhom,3));
rhom_ccafb = squeeze(mean(rhom_ccaf,2));
for i = 1 : size(acc_cca,2)
    for j = 1 : size(acc_cca,1)
        itr_acc(j,i) = convert_itr(acc_cca(j,i),2);
    end
end
coeff_narrow =  LinearModel.fit(itr_val_sorted,rhom_ccafb(itr_ind));
a_narrow = coeff_narrow.Coefficients{2,1}
b_narrow = coeff_narrow.Coefficients{1,1};
figure
scatter(itrmax(find(sex_all==0)),rhom_ccafb(find(sex_all==0)),50,'FaceColor','b')
hold on
scatter(itrmax(find(sex_all==1)),rhom_ccafb(find(sex_all==1)),50,'FaceColor','r')
hold on
plot(itr_val_sorted,a_narrow*rhom_ccafb+b_narrow,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('SNR (dB)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
figure
histogram(projection_snrfb(1:146),'Normalization','probability','BinWidth',0.1,'FaceAlpha',0.4,'FaceColor','r')
[a,b] = normfit(projection_snrfb)

