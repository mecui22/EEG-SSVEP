clear;clc
%%
% age 
% load('age.mat')
% figure
% histogram(age_list,'FaceAlpha',0.4,'FaceColor','r')
% % set(gca,'xlim',[-50,10])
% xlabel('Age')
% ylabel('Number')
% set(gca,'Box','off')
% set(gca,'LineWidth',1)
% set(gca,'TickDir','out')
% set(gca,'Fontname','Times New Roman');
% set(gca,'Fontsize',14);
% set(gca,'FontWeight','bold');
% set(gcf,'PaperUnits','points');
% set(gcf,'Position',[230,230,580,380], 'color','w')
% hold on
% plot([mean(age_list),mean(age_list)],[0,80],'b','LineWidth',2)
%%
% ACC & ITR
acc_ccam = [];
acc_fbccam = [];
acc_trcam = [];
for i = 1 : 146
    filename1 = ['E:/BCI2018/DataNeuracleInfo/S',num2str(i),'/S',num2str(i),'-bci.mat'];
    load(filename1)
    acc_ccam(i,:) = mean(bci.acc_cca,2)';
    acc_fbccam(i,:) = mean(bci.acc_fbcca,2)';
    acc_trcam(i,:) = mean(bci.acc_trca,2)';
    itr_ccam(i,:) = mean(bci.itr_cca,2)';
    itr_fbccam(i,:) = mean(bci.itr_fbcca,2)';
    itr_trcam(i,:) = mean(bci.itr_trca,2)';
end

for i = 1 : 70
    filename2 = ['E:/BCI2018/DataNeuroscanInfo/S',num2str(i),'/S',num2str(i),'-bci.mat'];
    load(filename2)
    acc_ccam(i+146,:) = mean(bci.acc_cca,2)';
    acc_fbccam(i+146,:) = mean(bci.acc_fbcca,2)';
    acc_trcam(i+146,:) = mean(bci.acc_trca,2)';
    itr_ccam(i+146,:) = mean(bci.itr_cca,2)';
    itr_fbccam(i+146,:) = mean(bci.itr_fbcca,2)';
    itr_trcam(i+146,:) = mean(bci.itr_trca,2)';
end

close all
time = [200:200:3000];
figure
plot(time/1000,mean(acc_ccam,1),'b','LineWidth',2)
hold on
plot(time/1000,mean(acc_fbccam,1),'m','LineWidth',2)
hold on
plot(time/1000,mean(acc_trcam,1),'r','LineWidth',2)
hold on
errorbar(time/1000,mean(acc_ccam,1),sem(acc_ccam,1),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(acc_fbccam,1),sem(acc_fbccam,1),'m','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(acc_trcam,1),sem(acc_trcam,1),'r','LineStyle','none','LineWidth',2)
set(gca,'xlim',[0,3.2])
legend('CCA','FBCCA','TRCA','Location','northeastoutside')
legend('boxoff')
% set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('Accuracy')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
% ITR
time = [200:200:3000];
figure
plot(time/1000,mean(itr_ccam,1),'b','LineWidth',2)
hold on
plot(time/1000,mean(itr_fbccam,1),'m','LineWidth',2)
hold on
plot(time/1000,mean(itr_trcam,1),'r','LineWidth',2)
hold on
errorbar(time/1000,mean(itr_ccam,1),sem(itr_ccam,1),'b','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(itr_fbccam,1),sem(itr_fbccam,1),'m','LineStyle','none','LineWidth',2)
hold on
errorbar(time/1000,mean(itr_trcam,1),sem(itr_trcam,1),'r','LineStyle','none','LineWidth',2)
set(gca,'xlim',[0,3.2])
legend('CCA','FBCCA','TRCA','Location','northeastoutside')
legend('boxoff')
% set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
xlabel('Time (s)')
ylabel('ITR (bpm)')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
%% sub-ACC
time = [200:200:3000];
for i = 1 : 146
    filename1 = ['E:/BCI2018/DataNeuracleInfo/S',num2str(i),'/S',num2str(i),'-bci.mat'];
    load(filename1)
    filename1text = ['E:/BCI2018/DataNeuracleInfo/S',num2str(i),'/sub_info.txt'];
    text = importdata(filename1text);
    gender = text.colheaders;
    sex_all(i) = strcmp(gender,'female');
    acc_cca(i,:,:) = bci.acc_cca;
    acc_fbcca(i,:,:) = bci.acc_fbcca;
    acc_trca(i,:,:) = bci.acc_trca;
    itr_cca(i,:,:) = bci.itr_cca;
    itr_fbcca(i,:,:) = bci.itr_fbcca;
    itr_trca(i,:,:) = bci.itr_trca;
    rho_cca(i) = mean(mean(bci.rho_cca(8,:,:)));
    itrf_cca(i) = mean(bci.itr_cca(8,:,:));
    rho_fbcca(i) = mean(mean(bci.rho_fbcca(8,:,:)));
    itrf_fbcca(i) = mean(bci.itr_fbcca(8,:,:));
end
for i = 1 : 70
    filename2 = ['E:/BCI2018/DataNeuroscanInfo/S',num2str(i),'/S',num2str(i),'-bci.mat'];
    load(filename2)
    filename1text = ['E:/BCI2018/DataNeuracleInfo/S',num2str(i),'/sub_info.txt'];
    text = importdata(filename1text);
    gender = text.colheaders;
    sex_all(i) = strcmp(gender,'female');
    acc_cca(i+146,:,:) = bci.acc_cca;
    acc_fbcca(i+146,:,:) = bci.acc_fbcca;
    acc_trca(i+146,:,:) = bci.acc_trca;
    itr_cca(i+146,:,:) = bci.itr_cca;
    itr_fbcca(i+146,:,:) = bci.itr_fbcca;
    itr_trca(i+146,:,:) = bci.itr_trca;
    rho_cca(i+146) = mean(mean(bci.rho_cca(8,:,:)));
    itrf_cca(i+146) = mean(bci.itr_cca(8,:,:));
    rho_fbcca(i+146) = mean(mean(bci.rho_fbcca(8,:,:)));
    itrf_fbcca(i+146) = mean(bci.itr_fbcca(8,:,:));
end
close all
figure
for i =1 : 110
    subplot(10,11,i)
    plot(time/1000,squeeze(mean(acc_cca(i,:,:),3)),'b','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(acc_fbcca(i,:,:),3)),'m','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(acc_trca(i,:,:),3)),'r','LineWidth',2)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_ccam(i,:,:),3)),sem(squeeze(acc_cca(i,:,:)),2),'b','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_fbccam(i,:,:),3)),sem(squeeze(acc_fbcca(i,:,:)),2),'m','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_trcam(i,:,:),3)),sem(squeeze(acc_trca(i,:,:)),2),'r','LineStyle','none','LineWidth',1)
    grid on
    set(gca,'xlim',[0,3.2])
%     legend('CCA','FBCCA','TRCA','Location','northeastoutside')
    legend('off')
    % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
    xlabel('Time (s)')
    ylabel('Accuracy')
    set(gca,'Box','off')
    set(gca,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'Fontname','Times New Roman');
    title(['S',num2str(i)])
%     set(gca,'Fontsize',14);
%     set(gca,'FontWeight','bold');
end
figure
for i =111 : 216
    subplot(10,11,i-110)
    plot(time/1000,squeeze(mean(acc_cca(i,:,:),3)),'b','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(acc_fbcca(i,:,:),3)),'m','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(acc_trca(i,:,:),3)),'r','LineWidth',2)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_ccam(i,:,:),3)),sem(squeeze(acc_cca(i,:,:)),2),'b','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_fbccam(i,:,:),3)),sem(squeeze(acc_fbcca(i,:,:)),2),'m','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_trcam(i,:,:),3)),sem(squeeze(acc_trca(i,:,:)),2),'r','LineStyle','none','LineWidth',1)
    grid on
    set(gca,'xlim',[0,3.2])
%     legend('CCA','FBCCA','TRCA','Location','northeastoutside')
    legend('off')
    % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
    xlabel('Time (s)')
    ylabel('Accuracy')
    set(gca,'Box','off')
    set(gca,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'Fontname','Times New Roman');
    title(['S',num2str(i)])
%     set(gca,'Fontsize',14);
%     set(gca,'FontWeight','bold');
end
%% sub-ITR
figure
for i =1 : 110
    subplot(10,11,i)
    plot(time/1000,squeeze(mean(itr_cca(i,:,:),3)),'b','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(itr_fbcca(i,:,:),3)),'m','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(itr_trca(i,:,:),3)),'r','LineWidth',2)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_ccam(i,:,:),3)),sem(squeeze(acc_cca(i,:,:)),2),'b','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_fbccam(i,:,:),3)),sem(squeeze(acc_fbcca(i,:,:)),2),'m','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_trcam(i,:,:),3)),sem(squeeze(acc_trca(i,:,:)),2),'r','LineStyle','none','LineWidth',1)
    grid on
    set(gca,'xlim',[0,3.2])
%     legend('CCA','FBCCA','TRCA','Location','northeastoutside')
    legend('off')
    % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
    xlabel('Time (s)')
    ylabel('ITR (bpm)')
    set(gca,'Box','off')
    set(gca,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'Fontname','Times New Roman');
    title(['S',num2str(i)])
%     set(gca,'Fontsize',14);
%     set(gca,'FontWeight','bold');
end
figure
for i =111 : 216
    subplot(10,11,i-110)
    plot(time/1000,squeeze(mean(itr_cca(i,:,:),3)),'b','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(itr_fbcca(i,:,:),3)),'m','LineWidth',2)
    hold on
    plot(time/1000,squeeze(mean(itr_trca(i,:,:),3)),'r','LineWidth',2)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_ccam(i,:,:),3)),sem(squeeze(acc_cca(i,:,:)),2),'b','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_fbccam(i,:,:),3)),sem(squeeze(acc_fbcca(i,:,:)),2),'m','LineStyle','none','LineWidth',1)
%     hold on
%     errorbar(time/1000,squeeze(mean(acc_trcam(i,:,:),3)),sem(squeeze(acc_trca(i,:,:)),2),'r','LineStyle','none','LineWidth',1)
    grid on
    set(gca,'xlim',[0,3.2])
%     legend('CCA','FBCCA','TRCA','Location','northeastoutside')
    legend('off')
    % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
    xlabel('Time (s)')
    ylabel('ITR (bpm)')
    set(gca,'Box','off')
    set(gca,'LineWidth',1)
    set(gca,'TickDir','out')
    set(gca,'Fontname','Times New Roman');
    title(['S',num2str(i)])
%     set(gca,'Fontsize',14);
%     set(gca,'FontWeight','bold');
end
%%
%rho vs ITR
[itr_val_sorted,itr_ind] = sort(itrf_cca)%213
coeff_wide =  LinearModel.fit(itr_val_sorted,rho_cca(itr_ind));
a_wide = coeff_wide.Coefficients{2,1}
b_wide = coeff_wide.Coefficients{1,1};
figure
scatter(itrf_cca(find(sex_all==0)),rho_cca(find(sex_all==0)),50,'b','filled')
hold on
scatter(itrf_cca(find(sex_all==1)),rho_cca(find(sex_all==1)),50,'r','filled')
hold on
plot(itr_val_sorted,a_wide*itr_val_sorted+b_wide,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('Rho')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
%rho vs ITR
[itr_val_sorted,itr_ind] = sort(itrf_fbcca)%213
coeff_wide =  LinearModel.fit(itr_val_sorted,rho_fbcca(itr_ind));
a_wide = coeff_wide.Coefficients{2,1}
b_wide = coeff_wide.Coefficients{1,1};
figure
scatter(itrf_fbcca(find(sex_all==0)),rho_fbcca(find(sex_all==0)),50,'b','filled')
hold on
scatter(itrf_fbcca(find(sex_all==1)),rho_fbcca(find(sex_all==1)),50,'r','filled')
hold on
plot(itr_val_sorted,a_wide*itr_val_sorted+b_wide,'--k','LineWidth',2)
xlabel('ITR (bpm)')
ylabel('Rho')
set(gca,'Box','off')
set(gca,'LineWidth',1)
set(gca,'TickDir','out')
set(gca,'Fontname','Times New Roman');
set(gca,'Fontsize',14);
set(gca,'FontWeight','bold');
set(gcf,'PaperUnits','points');
set(gcf,'Position',[230,230,580,380], 'color','w')
%%
