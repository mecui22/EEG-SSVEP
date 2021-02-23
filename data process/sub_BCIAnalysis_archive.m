function sub_BCIAnalysis(datum,freqV,savepath,sub,type)
freqs = [8:0.2:15.8];
neuracle_chan = [1:5,8:59];
chan9 = [41,48:52,55:57];
neuroscan_chan9 = [48,54,55,56,57,58,61,62,63];
if strcmp(type,'neuracle')
    datum9 = datum(neuracle_chan(chan9),:,:,:);
elseif strcmp(type,'neuroscan')
    datum9 = datum(neuroscan_chan9,:,:,:);
end
time = [200:200:3000];
rfs = 250;
fs = 1000;
datum9p = zeros(size(datum9,1),size(datum9,2)/4,size(datum9,3),size(datum9,4));
for chan = 1 : size(datum9,1)
    for block = 1 :size(datum9,3)
        for cond = 1 : size(datum9,4)
            datum9p(chan,:,block,cond) = downsample(datum9(chan,:,block,cond),4);
        end
    end
end
for k =  1 : length(time)
    for j = 1 :1
        cnt = 0;
        for ii = 1 : 40
            epoch = datum9p(:,:,j,ii);
            epoch_down = epoch';
            [prediction,rho] = fbcca(epoch_down,time(k)/fs,freqs);
            cnt = cnt +(abs(freqs(prediction)-freqV(ii))<1e-3);
            rho_fbcca(k,j,ii) = rho;
        end
        acc_fbcca(k,j) = cnt/40;
        itr_fbcca(k,j) = convert_itr(acc_fbcca(k,j),time(k)/fs);
    end
end
for k =  1 : length(time)
    for j = 1 :1
        cnt = 0;
        for ii = 1 : 40
            epoch = datum9p(:,:,j,ii);
            epoch_down = epoch';
            [prediction,rho] = stdcca_rho(epoch_down(1:time(k)/4,:),rfs,freqs);
            cnt = cnt +(abs(prediction-freqV(ii))<1e-3);
            rho_cca(k,j,ii) = rho;
        end
        acc_cca(k,j) = cnt/40;
        itr_cca(k,j) = convert_itr(acc_cca(k,j),time(k)/fs);
    end
end
time = [200:200:3000];
load('filters.mat');
% for k =  1 : length(time)
%     for cv = 1 : 1 %cross-validation
%         train_ind = setdiff([1:1],cv);
%         datatrain0 = datum9p(:,:,train_ind,:);%chan x time x block x cond
%         datatrain = permute(datatrain0,[2,1,4,3]);% time x chan x cond x block 
%         datatest0 = datum9p(:,:,cv,:);
%         datatest = permute(datatest0,[2,1,4,3]);
%         [traindata_Allh, trca_SFs_FBs_group_neighbours] = trcaTrain(datatrain(1:time(k)/4,:,:,:));
%         cnt = 0;
%         for ii = 1 : 40
%             epoch = squeeze(datatest(:,:,ii));
%             prediction = trca(epoch(1:time(k)/4,:),filters,40,traindata_Allh,trca_SFs_FBs_group_neighbours);
%             cnt = cnt + (abs(prediction-ii)<1e-3);
%         end
%         acc_trca(k,cv) = cnt/40;
%         itr_trca(k,cv) = convert_itr(acc_trca(k,cv),time(k)/fs);
%     end
% end
bci.acc_cca = acc_cca;
bci.acc_fbcca = acc_fbcca;
% bci.acc_trca = acc_trca;
bci.itr_cca = itr_cca;
bci.itr_fbcca = itr_fbcca;
% bci.itr_trca = itr_trca;
bci.rho_cca = rho_cca;
bci.rho_fbcca = rho_fbcca;
if ~exist(savepath)
    mkdir(savepath)
end
save([savepath,'S',num2str(sub),'-bci.mat'],'bci')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ACC
% h = figure;
% % plot(time/1000,mean(acc_trca,2),'r','LineWidth',2)
% % hold on
% plot(time/1000,mean(acc_fbcca,2),'m','LineWidth',2)
% hold on
% plot(time/1000,mean(acc_cca,2),'b','LineWidth',2)
% hold on
% % errorbar(time/1000,mean(acc_trca,2),std(acc_trca,1,2),'r','LineStyle','none','LineWidth',2)
% % hold on
% errorbar(time/1000,mean(acc_fbcca,2),std(acc_fbcca,1,2),'m','LineStyle','none','LineWidth',2)
% hold on
% errorbar(time/1000,mean(acc_cca,2),std(acc_cca,1,2),'b','LineStyle','none','LineWidth',2)
% legend('FBCCA','CCA','Location','northeastoutside')
% legend('boxoff')
% set(gca,'xlim',[0,3])
% % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
% % set(gca,'xticklabel',{'0.5','1','1.5','2','2.5','3','3.5','4','4.5','5'})
% set(gca,'ylim',[0,1])
% xlabel('Time (s)')
% ylabel('Accuracy')
% set(gca,'Box','off')
% set(gca,'LineWidth',1)
% set(gca,'TickDir','out')
% set(gca,'Fontname','Times New Roman');
% set(gca,'Fontsize',16);
% set(gca,'FontWeight','bold');
% set(h,'PaperUnits','points');
% set(h,'Position',[0,0,600,400], 'color','w')
% savefig(h,[savepath,'S',num2str(sub),'-ACC.fig'])
% saveas(h,[savepath,'S',num2str(sub),'-ACC.bmp'])
% close(h)
% % ITR
% h = figure;
% % plot(time/1000,mean(itr_trca,2),'r','LineWidth',2)
% % hold on
% plot(time/1000,mean(itr_fbcca,2),'m','LineWidth',2)
% hold on
% plot(time/1000,mean(itr_cca,2),'b','LineWidth',2)
% hold on
% % errorbar(time/1000,mean(itr_trca,2),std(itr_trca,1,2),'r','LineStyle','none','LineWidth',2)
% % hold on
% errorbar(time/1000,mean(itr_fbcca,2),std(itr_fbcca,1,2),'m','LineStyle','none','LineWidth',2)
% hold on
% errorbar(time/1000,mean(itr_cca,2),std(itr_cca,1,2),'b','LineStyle','none','LineWidth',2)
% legend('FBCCA','CCA','Location','northeastoutside')
% legend('boxoff')
% set(gca,'xlim',[0,3])
% % set(gca,'yticklabel',{'0','0.2','0.4','0.6','0.8','1',''})
% % set(gca,'xticklabel',{'0.5','1','1.5','2','2.5','3','3.5','4','4.5','5'})
% % set(gca,'ylim',[0,1])
% xlabel('Time (s)')
% ylabel('ITR (bpm)')
% set(gca,'Box','off')
% set(gca,'LineWidth',1)
% set(gca,'TickDir','out')
% set(gca,'Fontname','Times New Roman');
% set(gca,'Fontsize',16);
% set(gca,'FontWeight','bold');
% set(h,'PaperUnits','points');
% set(h,'Position',[0,0,600,400], 'color','w')
% savefig(h,[savepath,'S',num2str(sub),'-ITR.fig'])
% saveas(h,[savepath,'S',num2str(sub),'-ITR.bmp'])
% close(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end