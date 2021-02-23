function sub_RhythmAnalysis(datum,freqV,savepath,sub,type)
    theta = [4 , 7];
    alpha = [8 , 13];
    beta = [14 , 25];
    gamma = [26 , 100];
    fs = 1000;
    chan12 = [2,3,6,15,24,31,32,41,48,55:57];
    neuracle_chan = [1:5,8:59];
    chan_all = neuracle_chan(chan12);
    loc_file = 'neuracle_lead12.loc';
    datumnc = datum(chan_all,:,:);
    for block = 1:size(datumnc,3)
        for sample = 1:size(datumnc,4)
            for chan = 1 : size(datumnc,1)
                power_theta(chan,sample,block) = calculateSpectralSum(datumnc(chan,:,block,sample), theta, freqV(1),fs);
                power_alpha(chan,sample,block) = calculateSpectralSum(datumnc(chan,:,block,sample), alpha, freqV(1),fs);
                power_beta(chan,sample,block) = calculateSpectralSum(datumnc(chan,:,block,sample), beta, freqV(1),fs);
                power_gamma(chan,sample,block) = calculateSpectralSum(datumnc(chan,:,block,sample), gamma, freqV(1),fs);                 
            end
        end
    end
    
    mpower_theta_rest = mean3(power_theta);
    mpower_alpha_rest = mean3(power_alpha);
    mpower_beta_rest = mean3(power_beta);
    mpower_gamma_rest = mean3(power_gamma);
    mpower = rhythm.mpower;
    
    diff_theta = mpower(1) - mpower_theta_rest;
    diff_alpha = mpower(2) - mpower_alpha_rest;
    diff_beta = mpower(3) - mpower_beta_rest;
    diff_gamma = mpower(4) - mpower_gamma_rest;
    
    maxc = max(max([diff_theta, diff_alpha, diff_beta, diff_gamma]));
    minc = min(min([diff_theta, diff_alpha, diff_beta, diff_gamma]));
    
    h = figure;
    %
    subplot(2,3,1)
    topoplot(diff_theta,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Theta']);
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,2)
    topoplot(diff_alpha,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Alpha']);
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,4)
    topoplot(diff_beta,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
    title(['Beta']);
    set(gca,'Fontname','Arial');
    set(gca,'Fontsize',14);
    set(gca,'FontWeight','normal');
    %
    subplot(2,3,5)
    topoplot(diff_gamma,loc_file,'maplimits',[minc,maxc],'gridscale',513,'style','map');
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
    %savefig(h,[savepath,'S',num2str(sub),'-Topography-Rhythms-rest.fig'])
    saveas(h,[savepath,'S',num2str(sub),'-2-Topography-Rhythms-rest.bmp'])
    close all

end