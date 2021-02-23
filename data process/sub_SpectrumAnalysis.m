function sub_SpectrumAnalysis(datum,freqV,savepath,sub,type)
    freqs = [8:0.2:15.8];
    neuracle_chan = [1:5,8:59];
    chan5 = [41,48,55:57];
    chan9 = [41,48:52,55:57];
    neuroscan_chan9 = [48,54,55,56,57,58,61,62,63];
    if strcmp(type,'neuracle12')
        datum1 = datum(neuracle_chan(chan5(3)),:,:,:);
    elseif strcmp(type,'neuracle')
        datum1 = datum(neuracle_chan(chan9(7)),:,:,:);
    elseif strcmp(type,'neuroscan')
        datum1 = datum(neuroscan_chan9(8),:,:,:);
    end
    datumb = squeeze(mean(datum1,3));
    h = figure;
    for i = 1 : 40
        subplot(5,8,find(abs(freqs-freqV(i))<1e-3));
        plotspectrumc(datumb(:,i),freqV(i),'r');
        if mod(find(abs(freqs-freqV(i))<1e-3)-1,8)==0
           ylabel('\mu V^2');
        end
        if find(abs(freqs-freqV(i))<1e-3) > 32
            xlabel('f/Hz');
        else
            set(gca, 'XTickLabel',[]);
        end
        title([num2str(freqV(i)),' Hz']);
%        set(gca, 'TitleFontSizeMultiplier', 1);
        grid on;
        grid minor;
        set(gca,'Box','off');
        set(gca,'LineWidth',1);
        set(gca,'TickDir','out');
        set(gca,'Fontname','Arial');
        set(gca,'Fontsize',12);
        set(gca,'FontWeight','normal');
    end
    set(h,'PaperUnits','points');
    set(h,'Position',[0,0,1920,1080], 'color','w');
    if ~exist(savepath)
        mkdir(savepath)
    end
    %savefig(h,[savepath,'S',num2str(sub),'-Spectrum.fig'])
    saveas(h,[savepath,'S',num2str(sub),'-1-Spectrum.bmp'])
    close all
end