% initialsettings_gui() - displays an interactive window for defining settings and parameters 
%                         needed for carrying out the CRB analysis 
%
% Usage:
%   >>  par=initialsettings_gui(EEG);
%
% Inputs:
%   EEG        - input EEG dataset
%   
%    
% Outputs:
%   par  - parameters struct - see the pop_CRBanalysis() help 
%


% Copyright (C) <2012>  <Anahita Goljahani>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function par=initialsettings_gui(EEG,typeproc)

par=[];

if nargin==0 || ~isfield(EEG,'data') || isempty(EEG.data),
    
    error('Empty dataset');
    
end

if nargin<2,
    typeproc=1;
end

N_chan=size(EEG.data,1);

    
try 

   [tmp lab th rd]=readlocs(EEG.chanlocs);

   if  sum(isnan(th))<N_chan;

        chanlocs=1;
        chanlocs_str='yes';
        par.chanlocs=EEG.chanlocs;

   else
       chanlocs=0;
       chanlocs_str='no';
       par.chanlocs=[];

   end

catch 

    chanlocs=0;
    chanlocs_str='no';
    par.chanlocs=[];
    lab=cell(1,N_chan); 

end
     

chan_labels=cell(N_chan,1);

for i_chan=1:N_chan,
    
    if isempty(lab{i_chan}),
        
       chan_labels{i_chan}=num2str(i_chan);    
              
    else
        
       chan_labels{i_chan}=[num2str(i_chan) '-' lab{i_chan}];
              
    end
    
    EEG.chanlocs(i_chan).labels=chan_labels{i_chan};
    
end


if isfield(EEG,'icaweights') && ~isempty(EEG.icaweights),
    
    N_comp=size(EEG.icaweights,1);
    
    ica=1;
    ica_str='yes';             
    
    comp_labels=cell(1,N_comp);
    
    for i_ic=1:N_comp,
        
        comp_labels{i_ic}=num2str(i_ic);
        
    end
    
    
else
    
    ica=0;
    ica_str='no';
    typeproc=1;
    
end


cancel_flag=0;
close_flag=0;


%%%  GUI LAYOUT


fig=figure('name','GUI for initial settings - initialsettings_gui()',...
    'numbertitle','off',...
    'toolbar','none',...
    'menubar','none',...
    'units','pixels',...
    'position',[0  0  1000  750],...
    'windowstyle','normal','CloseRequestFcn', @CloseRequestFcn);

set(fig,'units','normalized');

movegui(fig,'center');

h_title=uicontrol('style','text','string','Settings for CRB analysis','horizontalalignment','left',...
    'fontsize',14,'fontweight','bold','foregroundcolor', [ 0.6 0 0.2],'fontunits','normalized',...
    'units','normalized','position',[0.25 0.96 0.4 0.04],...
    'backgroundcolor',get(fig,'color'));


h_helpbutton=uicontrol('style','pushbutton','string','help',...
    'fontsize',12,'fontunits','normalized',...
    'units','normalized','position',[0.63 0.95 0.15 0.04],...
    'callback',@helpbutton_cb,'enable','off','visible','off');

h_cancelbutton=uicontrol('style','pushbutton','string','cancel',...
    'fontsize',12,'fontunits','normalized',...
    'units','normalized','position',[0.8 0.95 0.15 0.04],...
    'callback',@cancelbutton_cb);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%
%%%%%% PANEL: Dataset info
%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_infopanel = uipanel('title',' Dataset info: ',...
    'fontsize',11,'fontweight','bold','fontunits','normalized',...
    'units','normalized','position',[.02 .8 0.96 0.16]);


h_info1=uicontrol(h_infopanel,'Style','text','string',{[ 'filepath ''' EEG.filepath ' '''];...
    ['filename ''' EEG.filename ' '''];...
    ['set name  ''' EEG.setname ''''];...
    [num2str(EEG.trials) ' epochs'];...
    [num2str(EEG.pnts) ' time points per epoch - t=('...
    sprintf('%.3f',sign(EEG.xmin)*floor(abs(EEG.xmin)*1000)/1000)  ':' sprintf('%.4f',1/EEG.srate) ':'...
    sprintf('%.3f',sign(EEG.xmax)*floor(abs(EEG.xmax)*1000)/1000) ')s  (sampling rate ' num2str(EEG.srate) ' Hz)' ]},...
    'horizontalalignment','left','fontsize',11,'fontunits','normalized',...
    'units','normalized','position',[0.02 0.01 0.9 0.95]);

h_info2=uicontrol(h_infopanel,'Style','text','string',{[ 'channel locations: ' chanlocs_str];...
    ['indepent components (ICs): '  ica_str]},...
    'horizontalalignment','left','fontsize',11,'fontunits','normalized',...
    'units','normalized','position',[0.75 0.07 0.23 0.38]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%% PANEL: CRB data selection
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_dataselectionpanel = uipanel('title',' CRB data selection:  ',...
    'fontsize',11,'fontweight','bold','fontunits','normalized',...
    'units','normalized','position',[.02 .62 0.96 0.16]);


%%%% buttons group for data selection

h_dataselectiongroup=uibuttongroup('parent',h_dataselectionpanel,'borderType','none',...
    'units','normalized','position',[0.02 0.01 0.25 0.9],'SelectionChangeFcn',@dataselectiongroup_cb);

h_chandatabut=uicontrol('parent',h_dataselectiongroup,'style','radiobutton',...
    'string','EEG data','fontsize',11,'fontunits','normalized',...
    'units','normalized','position',[0.02 0.8 1 0.2]);

h_compactbut=uicontrol('parent',h_dataselectiongroup,'style','radiobutton',...
    'string','IC activations','fontsize',11,'fontunits','normalized',...
    'units','normalized','position',[0.02 0.3 1 0.2]);

if typeproc==0,
    
    set(h_compactbut,'value',1);
    
end


%%%% channels selection

h_chanseltext = uicontrol(h_dataselectionpanel,'style','text',...
    'string',{'select EEG channels from the list';'(default: all channels selected)'},...
    'fontsize',11,'HorizontalAlignment','left','fontunits','normalized',...
    'backgroundcolor',get(h_dataselectionpanel,'backgroundcolor'),...
    'units','normalized','position',[0.34 0.64 0.28 0.35]);

h_chanlistbut= uicontrol(h_dataselectionpanel,'style','pushbutton','string','list channels',...
    'fontsize',10,'fontunits','normalized','units','normalized',...
    'TooltipString','push for displaying the list of channels',...
    'units','normalized','position',[0.63 0.63 0.17 0.3],...
    'callback',@chanlistbut_cb);

h_plotchanlocbut = uicontrol(h_dataselectionpanel,'style','pushbutton','string','plot channnel locations',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.81 0.63 0.18 0.3],...
    'callback',@plotchanlocbut_cb);

if chanlocs==0,
    
    set(h_plotchanlocbut,'enable','off');
    
end

%%%%%%%%%%% ICs selection

h_compseltext = uicontrol(h_dataselectionpanel,'Style','text','String',{'select ICs from the list ';...
    '(default: all components selected)'},...
    'fontsize',11,'HorizontalAlignment','left','fontunits','normalized',...
    'backgroundcolor',get(h_dataselectionpanel,'backgroundcolor'),...
    'units','normalized','position',[0.34 0.15 0.29 0.35]);

h_complistbut= uicontrol(h_dataselectionpanel,'style','pushbutton','string','list components',...
    'fontsize',10,'fontunits','normalized',...
    'tooltipstring','Push for displaying the list',...
    'units','normalized','position',[0.63 0.13 0.17 0.3],...
    'callback',@complistbut_cb);

h_compmapbut = uicontrol(h_dataselectionpanel,'style','pushbutton','string','plot component maps',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.81 0.13 0.18 0.3],...
    'callback',@compmapbut_cb);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%
%%%%%%%%%  PANEL:  Temporal intervals and parameters for the estimation of power spectrum densities (PSD) 
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_tempintpanel=uipanel(fig,'title','Temporal intervals and parameters for the estimation of power spectrum densities (PSDs): ',...
    'fontsize',11,'fontweight','bold','fontunits','normalized',...
    'units','normalized','position',[.02 .34 0.96 0.26]);

h_refinttext=uicontrol(h_tempintpanel,'style','text','string',{'reference interval (ms)';...
    '(insert values separeted by comma)'},...
    'fontsize',11,'fontunits','normalized','foregroundcolor','r','horizontalalignment','left',...
    'units','normalized','position',[0.02 0.75 0.32 0.2]);

h_refintedit=uicontrol(h_tempintpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.31 0.78 0.1 0.15],'callback',@refintedit_cb);

h_testinttext=uicontrol(h_tempintpanel,'style','text',...
    'string',{'test interval (ms)';'(insert values separeted by comma)'},...
    'fontsize',11,'foregroundcolor',[0 0.4 1],'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.02 0.47 0.32 0.2]);

h_testintedit=uicontrol(h_tempintpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.31 0.48 0.1 0.15],'callback',@testintedit_cb);

h_chanERPsbut = uicontrol(h_tempintpanel,'style','pushbutton','string','channel ERPs',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.05 0.23 0.25 0.15],...
    'callback',@chanERPsbut_cb);

h_compERPsbut = uicontrol(h_tempintpanel,'style','pushbutton','string','component ERPs',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.05 0.05 0.25 0.15],...
    'callback',@compERPsbut_cb);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%%% SUBPANEL: Parameters for PSDs estimation
%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_psdparpanel=uibuttongroup(h_tempintpanel,'title','Parameters for PSDs estimation','titleposition','righttop',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.415 0.02 0.58 0.98]);


h_refwinlengthoverlap_text=uicontrol('parent',h_psdparpanel,'style','text','fontsize',10,'horizontalalignment','left',...
    'string',{'reference PSDs estimation:'; 'windows length (ms), overlap(%)'},'fontunits','normalized',...
    'units','normalized','position',[0.01 0.75 0.35 0.22]);

h_refwinlengthoverlap_edit=uicontrol('parent',h_psdparpanel,'style','edit','fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.36 0.78 0.13 0.16]); 



h_testwinlengthoverlap_text=uicontrol('parent',h_psdparpanel,'style','text','fontsize',10,'horizontalalignment','left',...
    'string',{'test PSDs estimation:'; 'windows length (ms), overlap(%)'},'fontunits','normalized',...
    'units','normalized','position',[0.52 0.75 0.35 0.22]); 

h_testwinlengthoverlap_edit=uicontrol('parent',h_psdparpanel,'style','edit','fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.86 0.78 0.13 0.16]); 


h_wintext=uicontrol(h_psdparpanel,'style','text','string','window type',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.01 0.46 0.2 0.2]); 

psd_win_list={'none','Hanning','Hamming'};

h_winpopupmenu=uicontrol(h_psdparpanel,'style','popupmenu',...
    'fontsize',10,'string',psd_win_list,'fontunits','normalized',...
    'units','normalized','position',[0.19 0.51 0.13 0.16]); 


h_psd_freq_lim_text=uicontrol('parent',h_psdparpanel,'style','text','fontsize',10,'horizontalalignment','left',...
    'string',{'estimate PSDs only in the interval (Hz)';sprintf('(allowed in (0,%d) Hz)',floor(EEG.srate/2))},'fontunits','normalized',...
    'units','normalized','position',[0.43 0.48 0.41 0.22]); 

h_psd_freq_lim_edit=uicontrol('parent',h_psdparpanel,'style','edit','fontsize',10,...
    'units','normalized','position',[0.86 0.51 0.13 0.16],'callback',@psd_freq_lim_text_cb); 



h_Nffttext=uicontrol(h_psdparpanel,'style','text','string',{sprintf('number of PSD samples in (0,%d) Hz',EEG.srate);'(preferible a power of 2)'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.01 0.17 0.4 0.22]);

h_Nfftedit=uicontrol(h_psdparpanel,'style','edit',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.42 0.2 0.13 0.16],...
    'callback',@Nfftedit_cb);


h_restext=uicontrol(h_psdparpanel,'style','text','string','corresponding PSD frequency quantum: ... (Hz)',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.01 0.04 0.8 0.11]);



h_selectdatapreview_button=uicontrol(h_psdparpanel,'string','select data for preview',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.69 0.22 0.26 0.19],...
    'callback',@selectdatapreview_button_cb);


h_spectrapreview_button=uicontrol(h_psdparpanel,'string','spectra preview',...
    'fontsize',10,'fontunits','normalized',...
    'units','normalized','position',[0.72 0.01 0.2 0.19],...
    'callback',@spectrapreview_button_cb);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PANEL: CRB analysis patameters
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_CRBparpanel=uipanel(fig,'title','CRB analysis parameters: ','fontsize',11,'units','normalized',...
    'position',[0.02 0.01 0.46 0.31],'fontunits','normalized','fontweight','bold');


%%%%%%%%%%
%%%%%%%%%%  STEP 1 PARAMETERS
%%%%%%%%%%

h_firststeptext=uicontrol(h_CRBparpanel,'style','text','string',{'step 1'; 'localization of modulation intervals'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.01    0.85    0.49    0.14]) ;

h_wsizetext=uicontrol(h_CRBparpanel,'style','text','string','- w_{size} (Hz)',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.0400    0.6874    0.2200    0.1000]);

h_wsizeedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.3000    0.6974    0.1000    0.1000]);


h_wshifttext=uicontrol(h_CRBparpanel,'style','text','string','- w_{shift} (Hz)',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.0400    0.5495    0.22    0.1000]);  

h_wshiftedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.3    0.5595    0.1000    0.1000]); 


h_lambdatext=uicontrol(h_CRBparpanel,'style','text','string','- lambda ',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.04 0.4159    0.22   0.1000]);  

h_lambdaedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.3  0.4164    0.1000    0.1000]);  


h_epstext=uicontrol(h_CRBparpanel,'style','text','string','- epsilon ',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.04  0.2822    0.22    0.1000]);  

h_epsedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.3    0.2828     0.1000    0.1000]);  



h_onlystep1checkbox=uicontrol(h_CRBparpanel,'style','checkbox','string','perform only step 1','fontunits','normalized',...
    'units','normalized','position',[0.0179    0.1753    0.3500    0.0948],'value',0,...
    'callback',@onlystep1checkbox_cb);




%%%%%%%%%%
%%%%%%%%%%  STEP 2 PARAMETERS
%%%%%%%%%%


h_secondsteptext=uicontrol(h_CRBparpanel,'style','text','string',{'step 2:';'selection of data for IAF computation'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.5000    0.85    0.49000    0.14]) ;


h_rhomintext=uicontrol(h_CRBparpanel,'style','text','string',{'- rho_{min} (microV^2/Hz)'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.5300    0.7    0.35    0.1]);  

h_rhominedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.87    0.70    0.1000    0.1000]);  


h_rtext=uicontrol(h_CRBparpanel,'style','text','string','- r',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.53 0.6    0.1   0.1000]);  

h_redit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.87    0.585    0.1000    0.1000]);  


h_ptext=uicontrol(h_CRBparpanel,'style','text','string',{'- p'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.53    0.47    0.1000    0.1000]);  

h_pedit=uicontrol(h_CRBparpanel,'style','edit',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.87 0.47    0.1000    0.1000]);  


h_CAFcomp=uibuttongroup('parent',h_CRBparpanel,'borderType','none',...
    'units','normalized','position',[0.43 0.18 0.56 0.28],'SelectionChangeFcn',@CAFcomp_cb);

h_CAFbyrefPSD=uicontrol('parent',h_CAFcomp,'style','radiobutton',...
    'string','determine CAFs by using reference PSDs','fontsize',9,'fontunits','normalized',...
    'units','normalized','position',[0.01 0.7 1 0.22],'value',1);

h_CAFbytestPSD=uicontrol('parent',h_CAFcomp,'style','radiobutton',...
    'string','determine CAFs by using test PSDs','fontsize',9,'fontunits','normalized',...
    'units','normalized','position',[0.01 0.4 1 0.22],'value',0);

h_CAFbyPSDdiff=uicontrol('parent',h_CAFcomp,'style','radiobutton',...
    'string','determine CAFs by using PSDs differences','fontsize',9,'fontunits','normalized',...
    'units','normalized','position',[0.01 0.1 1 0.22],'value',0);


%%%% additional parameters


h_addparamtext=uicontrol(h_CRBparpanel,'style','text','fontsize',9,...
    'string',{'additional optional parameters,','(''keyname1'',''keyval1'';''keyname2'',''keyval2'')'},...
    'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.066    0.005    0.5300    0.1500]);

h_addparamedit=uicontrol(h_CRBparpanel,'style','edit','fontsize',8,...
    'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.57    0.016    0.35    0.1],...
    'SelectionHighlight','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%% EXECUTION BUTTONS
%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_exbut=uicontrol(fig,'style','pushbutton','string','run CRB analysis and save results',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.5000    0.2567    0.25    0.0500],'callback',@exbut_cb);

h_textexbut=uicontrol(fig,'style','text','string',{'(executes CRB analysis and pops up';'a window for saving results)'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.76    0.2580    0.2700    0.0500],'backgroundcolor',get(fig,'color'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%%  show results PANEL
%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_showresultspanel=uipanel(fig,'title','','backgroundcolor',get(fig,'color'),...
    'units','normalized','position',[0.5 0.01  0.48 0.23]);

h_showresbut=uicontrol(h_showresultspanel,'style','pushbutton','string','run CRB analsyis and show results',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.01 0.73 0.5 0.25],...
    'callback',@showresbut_cb);

h_showresbuttext=uicontrol(h_showresultspanel,'style','text','string',{'(executes CRB analysis and';...
    'shows results in an interactive window)'},...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.51 0.71 0.48 0.25],...
    'backgroundcolor',get(fig,'color'));

h_includeplotscheckbox=uicontrol(h_showresultspanel,'style','checkbox','string','include spectra plots',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.01 0.45 0.98 0.2],...
    'value',1,'backgroundcolor',get(fig,'color'),...
    'callback',@includeplotscheckbox_cb);

h_freqrangetext=uicontrol(h_showresultspanel,'style','text','string','frequency range in Hz (values separted by comma)',...
    'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
    'units','normalized','position',[0.06 0.3 0.75 0.15],...
    'backgroundcolor',get(fig,'color'));

h_freqrangeedit=uicontrol(h_showresultspanel,'style','edit','string','',...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.7    0.33    0.1800    0.1500]);

h_selchantoplotbut=uicontrol(h_showresultspanel,'style','pushbutton','string', {'select EEG channels to plot'},...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.05 0.05 0.4 0.2],...
    'callback',@selchantoplotbut_cb);

h_selcomptoplotbut=uicontrol(h_showresultspanel,'style','pushbutton','string', {'select ICs to plot'},...
    'fontsize',10,'horizontalalignment','center','fontunits','normalized',...
    'units','normalized','position',[0.5 0.05 0.48 0.2],...
    'callback',@selcomptoplotbut_cb);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%
%%%%%%%%  INITIALIZATION TASKS
%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close_flag=0;
cancel_flag=0;

chan_indexes=1:N_chan;
chan_indexes_to_plot=1:N_chan;
chan_labels_to_plot=chan_labels;

if ica==1,
    
    comp_indexes=1:N_comp;
    comp_indexes_to_plot=comp_indexes;
    comp_labels_to_plot=comp_labels;  
    
end


dataselectiongroup_cb(h_dataselectiongroup);

if ica==0,
    
    set(h_compactbut,'enable','off')
    
end
    

%%%% PSD window type set to Hanning

set(h_winpopupmenu,'value',2);


%%% Nfft set in order to have a frequency quantum not greater than 0.1 Hz;

freq_quantum=0.1;
Nfft=2^nextpow2(EEG.srate/freq_quantum);
set(h_Nfftedit,'string',num2str(Nfft));

%%% frequency quantum text 

freq_quantum=EEG.srate/Nfft;
set(h_restext,'string',sprintf('corresponding frequency quantum: %.2f  Hz',freq_quantum) );


%%% PSD frequency limits

psd_freq_lim=[0 floor(EEG.srate/4)];
psd_freq_lim_str=['0, ' sprintf('%d',psd_freq_lim(2))];
set(h_psd_freq_lim_edit,'string',psd_freq_lim_str,'fontunits','normalized');

set(h_selectdatapreview_button,'enable','off')
set(h_spectrapreview_button,'enable','off')

%%%%%%%%% data preview 

selected_data=get(get(h_dataselectiongroup,'SelectedObject'),'string');

if strcmpi(selected_data,'EEG data'),
    
    datapreview_labels=chan_labels(chan_indexes);
    datapreview_indexes=1:length(datapreview_labels);
    
else
    
    datapreview_labels=comp_labels(comp_indexes);
    datapreview_indexes=1:length(datapreview_labels);    
    
end


%%%% CRB parameters 

%%% STEP 1

w_size=2;
w_shift=0.2;
lambda=0.5;
eps=0.5;

set(h_wsizeedit,'string',sprintf('%.2f',w_size));
set(h_wshiftedit,'string',sprintf('%.2f',w_shift));
set(h_lambdaedit,'string',sprintf('%.2f',lambda));
set(h_epsedit,'string',sprintf('%.2f',eps));


%%% STEP 2

rhomin=0;
r=0.2;
p=80;

set(h_rhominedit,'string',sprintf('%.2f',rhomin));
set(h_redit,'string',sprintf('%.2f',r));
set(h_pedit,'string',num2str(round(p)));

if get(h_onlystep1checkbox,'value'),
    
    par.CRBpar.onlystepone=1;    
    
    set(h_secondsteptext,'enable','off');
    
    set(h_rhomintext,'enable','off');
    set(h_rhominedit,'enable','off');
    
    set(h_rtext,'enable','off');
    set(h_redit,'enable','off');
    
    set(h_ptext,'enable','off');
    set(h_pedit,'enable','off');
    
else
    
    par.CRBpar.onlystepone=0;
    

end

par.CRBpar.algpar.CFcomp=1;


%%%%%%%%%%%% plots frequency range

set(h_freqrangeedit,'string',psd_freq_lim_str);


spectrapreview_handles=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%%      UIWAIT
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uiwait(fig);

if ~isempty(spectrapreview_handles),
    
    for i_preview=1:length(spectrapreview_handles),
        
        if ishandle(spectrapreview_handles(i_preview)),
           delete(spectrapreview_handles(i_preview));    
        end
        
    end    
end


if cancel_flag==1 || close_flag==1,
       
   return
   
end

%%%% collect parameters 

if get(h_chandatabut,'value')==0,
    
    par.typeproc=0;
    par.labels=comp_labels;
    par.CRB_dataindexes=comp_indexes;
    par.CRBpar.labels=comp_labels(comp_indexes);
    par.plotspar.indexes=comp_indexes_to_plot;
    par.plotspar.labels=par.CRBpar.labels(comp_indexes_to_plot);
    
else
    
    par.typeproc=1;
    par.labels=chan_labels;
    par.CRB_dataindexes=chan_indexes;
    par.CRBpar.labels=chan_labels(chan_indexes);
    par.plotspar.indexes=chan_indexes_to_plot;
    par.plotspar.labels=par.CRBpar.labels(chan_indexes_to_plot);
    
    if isfield(par,'chanlocs') && ~isempty(par.chanlocs),
        
        par.CRBpar.chanlocs=par.chanlocs(chan_indexes);
        par.plotspar.chanlocs=par.CRBpar.chanlocs(chan_indexes_to_plot);
        
    end
    
end


par.CRBpar.timeintervals.t=EEG.times;

ref_int_str=get(h_refintedit,'string');
test_int_str=get(h_testintedit,'string');

if ~isempty(ref_int_str);
   par.CRBpar.timeintervals.ref_int=cell2mat(textscan(ref_int_str,'%f%f','delimiter',','));
else
   par.CRBpar.timeintervals.ref_int=[];
end

if ~isempty(test_int_str);
    par.CRBpar.timeintervals.test_int=cell2mat(textscan(test_int_str,'%f%f','delimiter',','));
else
    par.CRBpar.timeintervals.test_int=[];
end

%%% PSD parameters

par.CRBpar.spectrapar.srate=EEG.srate;
%par.CRBpar.spectrapar.method=psd_methods_list{get(h_psdmethodpopupmenu,'value')};
par.CRBpar.spectrapar.win_type=psd_win_list{get(h_winpopupmenu,'value')};


if ~isempty(get(h_refwinlengthoverlap_edit,'string')),
    
    refwin_lengthoverlap=cell2mat(textscan(get(h_refwinlengthoverlap_edit,'string'),'%f','delimiter',','));
    par.CRBpar.spectrapar.ref_winlength=refwin_lengthoverlap(1);
    par.CRBpar.spectrapar.ref_winoverlap=refwin_lengthoverlap(2);
    
else
    
    par.CRBpar.spectrapar.ref_winlength=[];
    par.CRBpar.spectrapar.ref_winoverlap=[];
    
end

if ~isempty(get(h_testwinlengthoverlap_edit,'string')),
    
    testwin_lengthoverlap=cell2mat(textscan(get(h_testwinlengthoverlap_edit,'string'),'%f','delimiter',','));
    par.CRBpar.spectrapar.test_winlength=testwin_lengthoverlap(1);
    par.CRBpar.spectrapar.test_winoverlap=testwin_lengthoverlap(2);
    
else
    
    par.CRBpar.spectrapar.test_winlength=[];
    par.CRBpar.spectrapar.test_winoverlap=[];
    
end

if  ~isempty(get(h_Nfftedit,'string')),    
    par.CRBpar.spectrapar.Nfft=round(str2double(get(h_Nfftedit,'string')));
else
    par.CRBpar.spectrapar.Nfft=[];
end

if ~isempty(get(h_psd_freq_lim_edit,'string')),
    par.CRBpar.spectrapar.freq_lim=cell2mat(textscan(get(h_psd_freq_lim_edit,'string'),'%f %f','delimiter',','));
else
    par.CRBpar.spectrapar.freq_lim=[];
end
    

%%%% CRB analysis parameters

if ~isempty(get(h_wsizeedit,'string')),    
    par.CRBpar.algpar.w_size=str2double(get(h_wsizeedit,'string'));
else
    par.CRBpar.algpar.w_size=[];
end

if ~isempty(get(h_wshiftedit,'string')),
    par.CRBpar.algpar.w_shift=str2double(get(h_wshiftedit,'string'));
else
    par.CRBpar.algpar.w_shift=[];
end

if ~isempty(get(h_lambdaedit,'string')),
    par.CRBpar.algpar.lambda=str2double(get(h_lambdaedit,'string'));
else
    par.CRBpar.algpar.lambda=[];
end

if ~isempty(get(h_epsedit,'string'))
    par.CRBpar.algpar.epsilon=str2double(get(h_epsedit,'string'));
else
    par.CRBpar.algpar.epsilon=[];
end

if~isempty(get(h_rhominedit,'string'))
    par.CRBpar.algpar.rho_min=str2double(get(h_rhominedit,'string'));
else
    par.CRBpar.algpar.rho_min=[];
end

if ~isempty(get(h_redit,'string')),
    par.CRBpar.algpar.r=str2double(get(h_redit,'string'));
else
    par.CRBpar.algpar.r=[];
end

if ~isempty(get(h_pedit,'string')),    
    par.CRBpar.algpar.p=str2double(get(h_pedit,'string'));
else
    par.CRBpar.algpar.p=[];
end

if ~isempty(get(h_addparamedit,'string')),
    
    addpars=get(h_addparamedit,'string');
    addpars=textscan(addpars,'%s','delimiter',';');
    addpars=addpars{1};
    
    for i_addpar=1:length(addpars)
        
        addpar=textscan(addpars{i_addpar},'%s','delimiter','''');
        addpar=addpar{1};
        addpar_name=addpar{2};
        addpar_val=addpar{4};                
        
        eval(['par.CRBpar.algpar.' addpar_name '=[' addpar_val '];']);        

    end
        
end

par.spectraplots=get(h_includeplotscheckbox,'value');

if ~isempty(get(h_freqrangeedit,'string')),
        freq_range=textscan(get(h_freqrangeedit,'string'),'%f %f','delimiter',',');
        par.plotspar.freq_range=[freq_range{1} freq_range{2}];
else
        par.plotspar.freq_range=[];
    
end
    

delete(fig)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%  CALLBACKS
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function CloseRequestFcn(hObject,eventdata)
        
             par=[];
             close_flag=1;
             delete(fig);
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%   HELP BUTTON (h_helpbutton)
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function helpbutton_cb(hObject, eventdata)        



end



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%   CANCEL BUTTON
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%


function cancelbutton_cb(hObject, eventdata)        

          par=[];
          cancel_flag=1;
          delete(fig);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%
%%%%%%    BUTTON GROUP
%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%


function dataselectiongroup_cb(hObject,eventdata)

selection=get(get(hObject,'SelectedObject'),'string');

    switch selection

        case 'IC activations'
            
            datapreview_labels=comp_labels(comp_indexes);
            datapreview_indexes=1:length(datapreview_labels);
            
            set([h_compseltext h_complistbut h_compmapbut h_compERPsbut],'enable','on');

            if get(h_includeplotscheckbox,'value')==1,
                set(h_freqrangetext,'enable','on');
                set(h_freqrangeedit,'enable','on');
                set(h_selcomptoplotbut,'enable','on')
            end

            set([h_chanseltext h_chanlistbut h_plotchanlocbut h_chanERPsbut h_selchantoplotbut],'enable','off')

        case 'EEG data'
            
            datapreview_labels=chan_labels(chan_indexes);
            datapreview_indexes=1:length(datapreview_labels);
            
            set([h_compseltext h_complistbut h_compmapbut h_compERPsbut h_selcomptoplotbut],'enable','off');

            set([h_chanseltext h_chanlistbut h_plotchanlocbut h_chanERPsbut],'enable','on')

            if get(h_includeplotscheckbox,'value')==1,
                set(h_freqrangetext,'enable','on');
                set(h_freqrangeedit,'enable','on');
                set(h_selchantoplotbut,'enable','on') ;
            end




    end
end



%%% PUSH BUTTON "list channels"

function chanlistbut_cb(hObject,eventdata)

    chan_indexes_old=chan_indexes;
    [chan_indexes ok]=listdlg('promptstring','Select channels (Ctrl+click)','liststring', chan_labels ,...
        'selectionmode','multiple','initialvalue',chan_indexes);
    if ~ok,

        chan_indexes=chan_indexes_old;

    else
        
        datapreview_labels=chan_labels(chan_indexes);
        datapreview_indexes=1:length(chan_indexes);
        chan_labels_to_plot=chan_labels(chan_indexes);
        chan_indexes_to_plot=1:length(chan_indexes);

    end

end

%%% PUSH BUTTON "plot chan. locations"

function plotchanlocbut_cb(hObject,eventdata)
    
        try
           h=figure;        
           topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint');
        catch
            delete(h);
            set(hObject,'enable','off');
        end
            
            
end



%%% PUSH BUTTON "list components"

function complistbut_cb(hObject,eventdata)

    comp_indexes_old=comp_indexes;
    
    [comp_indexes ok]=listdlg('PromptString','Select components (Ctrl+click)',...
        'liststring',comp_labels,'selectionmode','multiple','initialvalue',comp_indexes);
    if ~ok,
        
        comp_indexes=comp_indexes_old;
        
    else
        datapreview_labels=comp_labels(comp_indexes);
        datapreview_indexes=1:length(comp_indexes);
        comp_labels_to_plot=comp_labels(comp_indexes);
        comp_indexes_to_plot=1:length(comp_indexes);
        
    end
    
end


%%%% PUSH BUTTON "plot comp. maps"

function compmapbut_cb(hObject,eventdata)
       
        try             
           pop_topoplot(EEG,0, 1:N_comp ,EEG.setname);           
        catch
            
            delete(gcf);
            set(hObject,'enable','off');
            
        end         

end


%%%%% reference and test interval edit

function refintedit_cb(hObject,eventdata)
    
         ref_int_str=get(h_refintedit,'string');
         
         if ~isempty(ref_int_str)
             
             ref_int=cell2mat(textscan(ref_int_str,'%d','delimiter',','));
             
             
             for i_int=1:length(ref_int),
                 
                 if ref_int(i_int)<EEG.times(1),
                     ref_int(i_int)=EEG.times(1);
                 end
                 
                 if ref_int(i_int)>EEG.times(end);
                     
                     ref_int(i_int)=EEG.times(end);                                          
                 end
                 
                 set(h_refintedit,'string',sprintf('%d,%d',ref_int));
                 
             end
             
             
             
             set(h_refwinlengthoverlap_edit,'string',[num2str(abs(ref_int(2)-ref_int(1))) ', 0']);
             
             if ~isempty(get(h_testintedit,'string')),
                 
                 set(h_selectdatapreview_button,'enable','on');
                 set(h_spectrapreview_button,'enable','on');
                 
             end
             
         else
             
                 set(h_refwinlengthoverlap_edit,'string','');
                 
                 set(h_selectdatapreview_button,'enable','off');
                 set(h_spectrapreview_button,'enable','off');
                 
                 
         end
         
end

function testintedit_cb(hObject,eventdata)
    
         test_int_str=get(h_testintedit,'string');
         if ~isempty(test_int_str)
            test_int=cell2mat(textscan(test_int_str,'%d','delimiter',','));
            
             for i_int=1:length(test_int),
                 
                 if test_int(i_int)<EEG.times(1),
                     test_int(i_int)=EEG.times(1);
                 end
                 
                 if test_int(i_int)>EEG.times(end);
                     
                     test_int(i_int)=EEG.times(end);                                          
                     
                 end
                 
                 set(h_testintedit,'string',sprintf('%d,%d',test_int));
                 
             end            
            
            set(h_testwinlengthoverlap_edit,'string',[num2str(abs(test_int(2)-test_int(1))) ', 0']);
            
             if ~isempty(get(h_refintedit,'string')),
                 
                 set(h_selectdatapreview_button,'enable','on');
                 set(h_spectrapreview_button,'enable','on');
                 
             end
             
         else
             
             set(h_selectdatapreview_button,'enable','off');
             set(h_spectrapreview_button,'enable','off');
                 
             set(h_testwinlengthoverlap_edit,'string','');
             
         end

end


%%%% PUSH BUTTON "channel ERPs"

function chanERPsbut_cb(hObject,eventdata)
        
         h=figure;
         
         try 
             pop_plottopo(EEG, chan_indexes, 'sample dataset ', 0, 'ydir',1);         
         catch
             delete(h);
             set(hObject,'enable','off')
             
         end
end


%%%% PUSH BUTTON "component ERPs"

function compERPsbut_cb(hObject,eventdata)
         
         h=figure;
         
         try
            pop_plotdata(EEG, 0, comp_indexes , [1:size(EEG.data,3)], 'sample dataset', 0, 1, [0 0]);
         catch
             delete(h)
             set(hObject,'enable','off');
         end
         
end


%%%% EDIT Nfft

function Nfftedit_cb(hObject,eventdata)

    if ~isempty(get(hObject,'string')),
        Nfft=round(str2double(get(hObject,'string')));
        set(hObject,'string',num2str(Nfft));

        freq_quantum=EEG.srate/Nfft;
        set(h_restext,'string',sprintf(' corresponding frequency quantum: %.2f  Hz',freq_quantum) );
    else
        set(h_restext,'string',sprintf(' corresponding frequency quantum: ...  Hz') );
        
    end
end


function psd_freq_lim_text_cb(hObject,eventdata)
             
         set(h_freqrangeedit,'string',get(hObject,'string'));

end

% %%%%%%%%%%%% SPECTRA Preview

function selectdatapreview_button_cb(~,~)
   
          
          datapreview_indexes_old=datapreview_indexes;
          [datapreview_indexes ok]=listdlg('PromptString','Select data (Ctrl+click)','liststring',datapreview_labels,...
                                           'selectionmode','multiple','initialvalue',datapreview_indexes);
          
            if ~ok,

                datapreview_indexes=datapreview_indexes_old;

            end

          
end



function spectrapreview_button_cb(~,~),
    
        selected_data=get(get(h_dataselectiongroup,'SelectedObject'),'string');

        if strcmpi(selected_data,'EEG data'),
            
            plotspar.typeproc=1;
                        
            datapreview=EEG.data(chan_indexes,:,:);
            datapreview=datapreview(datapreview_indexes,:,:);
            
            if isfield(par,'chanlocs') && ~isempty(par.chanlocs),

                CRBpar.chanlocs=par.chanlocs(chan_indexes);
                CRBpar.chanlocs=CRBpar.chanlocs(datapreview_indexes);
                plotspar.chanlocs=CRBpar.chanlocs;

            else
                
                CRBpar.chanlocs=[];
                plotspar.chanlocs=[];
                
            end
            
            CRBpar.labels=chan_labels(chan_indexes);
            CRBpar.labels=CRBpar.labels(datapreview_indexes);            
            
        else
            
            plotspar.typeproc=0;
            
            CRBpar.chanlocs=[];
            plotspar.chanlocs=[];            
            
            CRBpar.labels=comp_labels(comp_indexes);
            CRBpar.labels=CRBpar.labels(datapreview_indexes);
            
            if ~isfield(EEG,'icaact') || isempty(EEG.icaact),
                
                datapreview= (EEG.icaweights*EEG.icasphere*reshape(EEG.data,size(EEG.data,1),[]));
                datapreview=reshape(datapreview,size(datapreview,1),size(EEG.data,2),[]);
                
            else
               
                datapreview=EEG.icaact;
                
            end
            
            datapreview=datapreview(comp_indexes,:,:);
            datapreview=datapreview(datapreview_indexes,:,:);               
                
        end
        
        
        CRBpar.timeintervals.t=EEG.times;

        ref_int_str=get(h_refintedit,'string');
        test_int_str=get(h_testintedit,'string');

        if ~isempty(ref_int_str);
           CRBpar.timeintervals.ref_int=cell2mat(textscan(ref_int_str,'%f%f','delimiter',','));
        else
           CRBpar.timeintervals.ref_int=[];
        end

        if ~isempty(test_int_str);
            CRBpar.timeintervals.test_int=cell2mat(textscan(test_int_str,'%f%f','delimiter',','));
        else
            CRBpar.timeintervals.test_int=[];
        end

        %%% PSD parameters

        CRBpar.spectrapar.srate=EEG.srate;
        %CRBpar.spectrapar.method=psd_methods_list{get(h_psdmethodpopupmenu,'value')};
        CRBpar.spectrapar.win_type=psd_win_list{get(h_winpopupmenu,'value')};


        if ~isempty(get(h_refwinlengthoverlap_edit,'string')),

            refwin_lengthoverlap=cell2mat(textscan(get(h_refwinlengthoverlap_edit,'string'),'%f','delimiter',','));
            CRBpar.spectrapar.ref_winlength=refwin_lengthoverlap(1);
            CRBpar.spectrapar.ref_winoverlap=refwin_lengthoverlap(2);

        else

            CRBpar.spectrapar.ref_winlength=[];
            CRBpar.spectrapar.ref_winoverlap=[];

        end

        if ~isempty(get(h_testwinlengthoverlap_edit,'string')),

            testwin_lengthoverlap=cell2mat(textscan(get(h_testwinlengthoverlap_edit,'string'),'%f','delimiter',','));
            CRBpar.spectrapar.test_winlength=testwin_lengthoverlap(1);
            CRBpar.spectrapar.test_winoverlap=testwin_lengthoverlap(2);

        else

            CRBpar.spectrapar.test_winlength=[];
            CRBpar.spectrapar.test_winoverlap=[];

        end

        if  ~isempty(get(h_Nfftedit,'string')),    
            CRBpar.spectrapar.Nfft=round(str2double(get(h_Nfftedit,'string')));
        else
            CRBpar.spectrapar.Nfft=[];
        end

        if ~isempty(get(h_psd_freq_lim_edit,'string')),
            CRBpar.spectrapar.freq_lim=cell2mat(textscan(get(h_psd_freq_lim_edit,'string'),'%f %f','delimiter',','));
        else
            CRBpar.spectrapar.freq_lim=[];
        end        
                
        CRBpar.onlyspectra=1;
        
        CRBpar=CRBanalysis_parcheck(CRBpar);
        display(['Computing spectra...wait...'])
        [CRB spectra]=CRBanalysis(datapreview,CRBpar);
        display('Done.')            
        freq_range=CRBpar.spectrapar.freq_lim;
        plotspar.freq_range=[freq_range(1) freq_range(2)];              

         plotspar.indexes=1:size(datapreview,1);
         plotspar.labels=CRBpar.labels;        
                 
         f=spectra.f;
         
         if freq_range(1)<freq_range(2) && ~isempty( intersect( find(f>=freq_range(1)) , find(f<=freq_range(2)) ) ) 
             
            spectra_plot.f=f;
            spectra_plot.ave_refspectra=spectra.ave_refspectra(plotspar.indexes,:);
            spectra_plot.ave_testspectra=spectra.ave_testspectra(plotspar.indexes,:);  
            
            spectra_plot.par=plotspar;                        
            spectrapreview_handles=[spectrapreview_handles spectrapreview_gui(spectra_plot)];
            
         else
             
             error('Frequency range for plotting not well defined')
             
         end
         
end

%%%% only step 1 checkbox

function onlystep1checkbox_cb(hObject,eventdata)

if   get(hObject,'value')
    
    par.CRBpar.onlystepone=1;
    
    set(h_rhominedit,'string',sprintf('%.2f',0));
    set(h_redit,'string',sprintf('%.2f',1));
    set(h_pedit,'string',num2str(round(100)));
    
    set(h_secondsteptext,'enable','off');
    
    set(h_rhomintext,'enable','off');
    set(h_rhominedit,'enable','off');
    
    set(h_rtext,'enable','off');
    set(h_redit,'enable','off');
    
    set(h_ptext,'enable','off');
    set(h_pedit,'enable','off');    
    
else
    
    par.CRBpar.onlystepone=0;
    
    set(h_rhominedit,'string',sprintf('%.2f',rhomin));
    set(h_redit,'string',sprintf('%.2f',r));
    set(h_pedit,'string',num2str(round(p)));
    
    
    set(h_secondsteptext,'enable','on');
    
    set(h_rhomintext,'enable','on');
    set(h_rhominedit,'enable','on');
    
    set(h_rtext,'enable','on');
    set(h_redit,'enable','on');
    
    set(h_ptext,'enable','on');
    set(h_pedit,'enable','on');
            
end

end


function CAFcomp_cb(hObject,eventdata)

selection=get(get(hObject,'SelectedObject'),'string');

    switch selection

        case 'determine CAFs by using reference PSDs'
            
             par.CRBpar.algpar.CFcomp=1;
             
        case 'determine CAFs by using test PSDs'
            
            par.CRBpar.algpar.CFcomp=2;

        case 'determine CAFs by using PSDs differences'

            par.CRBpar.algpar.CFcomp=3;
           
    end
    
end



%%%% PUSH BUTTON  Execute CRB analysis

function exbut_cb(h_exbut,event)

            par.executeandsave=1;
            par.showresults=0;
            set(fig,'visible','off')

            uiresume;

end

function showresbut_cb(hObject,eventdata)

        par.showresults=1;
        par.executeandsave=0;
        set(fig,'visible','off')

        uiresume;

end


%%%%% Include spectra plots checkbox

function includeplotscheckbox_cb(hObject,eventdata)

if get(hObject,'value'),
    selected_data=get(get(h_dataselectiongroup,'selectedobject'),'string');
    
    set(h_freqrangetext,'enable','on')
    set(h_freqrangeedit,'enable','on')
    
    if strcmpi(get(get(h_dataselectiongroup,'selectedobject'),'string'),'EEG data'),
        set(h_selchantoplotbut,'enable','on');
    else
        set(h_selcomptoplotbut,'enable','on');
    end
    
else
    
    set(h_freqrangetext,'enable','off')
    set(h_freqrangeedit,'enable','off')
    
    
    set(h_selchantoplotbut,'enable','off');
    set(h_selcomptoplotbut,'enable','off');
end


end

function  selchantoplotbut_cb(hObject,eventdata)


    chan_indexes_to_plot_old=chan_indexes_to_plot;
    [chan_indexes_to_plot ok]=listdlg('promptstring','Select multile channels by pressing Ctrl button','liststring', chan_labels_to_plot ,...
        'selectionmode','multiple','initialvalue',chan_indexes_to_plot);
    if ok==0,

        chan_indexes_to_plot=chan_indexes_to_plot_old;

    end

end

function selcomptoplotbut_cb(hObject,eventdata)

    comp_indexes_to_plot_old=comp_indexes_to_plot;

    [comp_indexes_to_plot ok]=listdlg('promptstring','Select components to plot','liststring',comp_labels_to_plot,...
        'initialvalue',comp_indexes_to_plot);

    if ok==0,

        comp_indexes_to_plot= comp_indexes_to_plot_old;

    end
end

end

