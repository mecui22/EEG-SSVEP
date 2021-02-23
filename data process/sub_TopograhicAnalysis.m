function sub_TopograhicAnalysis(datum,freqV,savepath,sub,type)
     freqs = [8:0.2:15.8];
     neuracle_chan = [1:5,8:59];
     chan12 = [2,3,6,15,24,31,32,41,48,55:57];
     neuroscan_chan =[1:32 34:42 44:59 61:63];
     if strcmp(type,'neuracle12')
         datumb = squeeze(mean(datum(neuracle_chan(chan12),:,:,:),3));
     elseif strcmp(type,'neuracle')
         datumb = squeeze(mean(datum(neuracle_chan,:,:,:),3));
     elseif strcmp(type,'neuroscan')
         datumb = squeeze(mean(datum(neuroscan_chan,:,:,:),3));
     end
     for i = 1 : size(datumb,1)
         for j = 1 : 40
             [ampval(i,j),~] = calculateFC3(squeeze(datumb(i,:,j))', freqV(j),5);
         end
     end
     
     topo.ampval = ampval;
     
%      [lo,hi] = findlohi(ampval,ampval);
     h = figure;
     for i = 1 : 40
         subplot(5,8,find(abs(freqs-freqV(i))<1e-3));
         if strcmp(type, 'neuracle12')
             topoplot(ampval(:,i),'neuracle_lead12.loc','maplimits','maxmin','gridscale',513,'style','map');
         elseif strcmp(type,'neuracle')
             topoplot(ampval(:,i),'neuracle_lead57.loc','maplimits','maxmin','gridscale',513,'style','map');
         elseif strcmp(type,'neuroscan')
             topoplot(ampval(:,i),'neuros_lead60.loc','maplimits','maxmin','gridscale',513,'style','map');
         end
         orisize = get(gca, 'Position');
         title([num2str(freqV(i)),' Hz']);
         c = colorbar;
         if mod(find(abs(freqs-freqV(i))<1e-3),8)==0
            c.Label.String = '\mu V^2';
         end
         set(gca, 'Position', orisize);
     end
     colormap('jet');     
     set(h,'PaperUnits','points');
     set(h,'Position',[0,0,1920,1080], 'color','w');
     if ~exist(savepath)
         mkdir(savepath)
     end
      %savefig(h,[savepath,'S',num2str(sub),'-Topography-SSVEP.fig'])
      saveas(h,[savepath,'S',num2str(sub),'-3-Topography-SSVEP.bmp'])
      save([savepath,'S',num2str(sub),'-topo.mat'],'topo')
      close all
end
