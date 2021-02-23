function sub_RhythmAnalysis(datum,freqV,savepath,sub,type)
    theta = [4 , 7];
    alpha = [8 , 13];
    beta = [14 , 25];
    gamma = [26 , 100];
    fs = 1000;
    chan12 = [2,3,6,15,24,31,32,41,48,55:57];
    neuracle_chan = [1:5,8:59];
    neuroscan_chan =[1:32 34:42 44:59 61:63];
    if strcmp(type,'neuracle12')
        chan_all = neuracle_chan(chan12);
        loc_file = 'neuracle_lead12.loc';
    elseif strcmp(type,'neuracle')
        chan_all = neuracle_chan;
        loc_file = 'neuracle_lead57.loc';
    elseif strcmp(type,'neuroscan')
        chan_all = neuroscan_chan;
        loc_file = 'neuros_lead60.loc';
    end
    datumnc = datum(chan_all,:,:,:);
    for block = 1 : size(datumnc,3)
        for cond = 1 : 40
            for chan = 1 : size(datumnc,1)
                power_theta(chan,cond,block) = calculateSpectralSum(datumnc(chan,:,block,cond), theta, freqV(cond),fs);
                power_alpha(chan,cond,block) = calculateSpectralSum(datumnc(chan,:,block,cond), alpha, freqV(cond),fs);
                power_beta(chan,cond,block) = calculateSpectralSum(datumnc(chan,:,block,cond), beta, freqV(cond),fs);
                power_gamma(chan,cond,block) = calculateSpectralSum(datumnc(chan,:,block,cond), gamma, freqV(cond),fs);                 
            end
        end
    end
    mpower_theta = mean3(power_theta);
    mpower_alpha = mean3(power_alpha);
    mpower_beta = mean3(power_beta);
    mpower_gamma = mean3(power_gamma);
    maxc = max(max([mpower_theta, mpower_alpha, mpower_beta, mpower_gamma]));
    minc = 0;
    rhythm.mpower = [mpower_theta, mpower_alpha, mpower_beta, mpower_gamma];
    
    h = figure;
    %
    subplot(2,3,1)
    topoplot(mpower_theta,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Theta']);
%     c = colorbar;
%     c.Label.String = '\mu V^2';
%     colormap('jet')
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,2)
    topoplot(mpower_alpha,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Alpha']);
%     c = colorbar
%     c.Label.String = '\mu V^2';
%     colormap('jet')     
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,4)
    topoplot(mpower_beta,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Beta']);
%     c = colorbar
%     c.Label.String = '\mu V^2';
%     colormap('jet')     
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,5)
    topoplot(mpower_gamma,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Gamma']);
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    cpos = get(subplot(2,3,5),'Position');
    c = colorbar('Position', [cpos(1)+cpos(3)+0.05  cpos(2)*1.5  0.03  cpos(2)+cpos(3)*3.1]);
    caxis([minc,maxc]);
    c.Label.String = '\muV^2';
    colormap('jet');     
    set(h,'PaperUnits','points');
    set(h,'Position',[0,0,1920,1080], 'color','w');
    %
    if ~exist(savepath)
        mkdir(savepath)
    end
    %savefig(h,[savepath,'S',num2str(sub),'-Topography-Rhythms.fig'])
    saveas(h,[savepath,'S',num2str(sub),'-2-Topography-Rhythms.bmp'])
    save([savepath,'S',num2str(sub),'-rhythm.mat'],'rhythm')
    close all
end