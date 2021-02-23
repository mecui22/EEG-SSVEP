function sub_TopograhicAnalysis(datum,freqV,savepath,sub,type)
     freqs = [8:0.2:15.8];
     neuracle_chan = [1:5,8:59];
     chan12 = [2,3,6,15,24,31,32,41,48,55:57];
     datumb = squeeze(mean(datum(neuracle_chan(chan12),:,:,:),3));
     for chan = 1 : size(datumb,1)
         for cond = 1 : 40
             for sample = 1:size(datumb,3)
                 temp(sample) = calculateFC3(squeeze(datumb(chan,:,sample))', freqV(cond),5);
             end    
            ampval_rest(chan,cond) = mean3(temp);
         end
     end
     ampval = topo.ampval;
     diff_ampval = ampval - ampval_rest;
%      [lo,hi] = findlohi(ampval,ampval);
     h = figure;
     for i = 1 : 40
         subplot(5,8,find(abs(freqs-freqV(i))<1e-3));
         minc=-1;
         maxc=1;
         topoplot(diff_ampval(:,i),'neuracle_lead12.loc','maplimits',[minc,maxc],'gridscale',513,'style','map');
         orisize = get(gca, 'Position');
         title([num2str(freqV(i)),' Hz']);
         c = colorbar;
         if mod(find(abs(freqs-freqV(i))<1e-3),8)==0
            c.Label.String = '\mu V^2';
         end
         set(gca, 'Position', orisize);
     end
     colormap('redblue');     
     set(h,'PaperUnits','points');
     set(h,'Position',[0,0,1920,1080], 'color','w');
     if ~exist(savepath)
         mkdir(savepath)
     end
      %savefig(h,[savepath,'S',num2str(sub),'-Topography-SSVEP-rest.fig'])
      saveas(h,[savepath,'S',num2str(sub),'-3-Topography-SSVEP-rest.bmp'])
      close all
end
