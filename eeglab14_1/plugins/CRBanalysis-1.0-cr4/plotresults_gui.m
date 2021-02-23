% plotresults_gui() - displays an interactive window, the 'GUI for spectra plost inspection', with results plotted over data PSDs   
%
% Usage:
%   >>  h_fig=plotresults_gui(spectra,results,h_table,f_handle)
%
% Inputs:   
%    
%       spectra -  struct  - needed -   second output of CRBanalysis() 
%       results -  struct  - needed -   'results' field of the first output of CRBanalysis()
%       h_table -  handle  - handle to the table in the GUI for numerical values inspection
%       f_handle - handle  - handle to the callback of the 'recompute with new table values' button in the GUI for numerical values inspection%
%
% Outputs:
%     
%       h_fig - handle - handle to the 'GUI for spectra plots inspection'
%   
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





function h_fig=plotresults_gui(spectra,results,h_table,f_handle)

results_ini=results;

dataplot_indexes=spectra.par.indexes;
plot_labels=results(dataplot_indexes+1,1);
chanlocs=spectra.par.chanlocs;

selected_plots=cell2mat(results(dataplot_indexes+1,3));
CAF_plots=cell2mat(results(dataplot_indexes+1,4));
rho_plots=cell2mat(results(dataplot_indexes+1,5));
alphaint_plots=cell2mat(results(dataplot_indexes+1,[6 7]));


selected=cell2mat(results(2:end,3));
CAFs=cell2mat(results(2:end,4));

if ~isempty(find(selected==1,1)),
    
   IAF=median(CAFs(selected==1));

else
    
    IAF=NaN;
    
end

if ~isempty(find(selected_plots==1,1)),
    
    local_IAF=median(CAF_plots(selected_plots==1));
    local_ave_f1=mean(alphaint_plots(selected_plots==1,1));
    local_ave_f2=mean(alphaint_plots(selected_plots==1,2));
    
else
    
   local_IAF=NaN;
   local_ave_f1=NaN;
   local_ave_f2=NaN;
   
end

button_down=0;
current_plot=0;
new_freq_positions=nan(1,2);



N_plots=length(dataplot_indexes)+1;

N_rows=floor(sqrt(N_plots));
N_col=ceil(N_plots/N_rows);

%%%% generating axes positions

delta_l=50;
delta_r=40;
delta_hor=30;

delta_u=40;
delta_b=120;
delta_vert=40;

fig_position=[0 0 900 750];

fig_width=fig_position(3);
fig_height=fig_position(4);

plot_width=(fig_width-delta_l-delta_r-(N_col-1)*delta_hor)/N_col;
plot_height=(fig_height-delta_u-delta_b-(N_rows-1)*delta_vert)/N_rows;

x_plot=delta_l:plot_width+delta_hor:delta_l+(N_col-1)*(plot_width+delta_hor);
y_plot=fig_height-delta_u-plot_height:-(plot_height+delta_vert):fig_height-delta_u-plot_height-(N_rows-1)*(plot_height+delta_vert);

f_plot=spectra.f;
freq_range=spectra.par.freq_range;
YMax=0;

patch_color=[0.85 0.85 0.85];
patch_scan_color=[ 0.7569    0.8667    0.7765];

axes_handles=zeros(1,N_plots);

tags={'patch_scan','patch','R','T','CAF','IAF','local_IAF'};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%  LAYOUT
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_fig=figure('name','GUI for spectra plots inspection - plotresults_gui()','numbertitle','off',...
    'position',fig_position,'units','normalized',...
    'toolbar','none');


movegui(h_fig,'center');


set(h_fig,'WindowButtonDownFcn',@WindowButtonDownFcn_cb);
set(h_fig,'WindowButtonUpFcn',@WindowButtonUpFcn_cb);
set(h_fig,'WindowButtonMotionFcn',@WindowButtonMotionFcn_cb);


YLims=zeros(N_plots-1,2);

for i_plot=1:N_plots-1,
    
    userdata.tags=tags;    
    userdata.patch_color=patch_color;
    userdata.patch_scan_color=patch_scan_color;
    
    userdata.index=i_plot;    
    userdata.data_index=dataplot_indexes(i_plot);
    userdata.label=plot_labels{i_plot};


    userdata.selected=selected_plots(i_plot);    
    userdata.CAF=CAF_plots(i_plot);
    userdata.rho=rho_plots(i_plot);
    userdata.alphaint=alphaint_plots(i_plot,:);
    userdata.IAF=IAF;   
    userdata.local_IAF=local_IAF;
    
    
    userdata.initial.selected=selected_plots(i_plot);    
    userdata.initial.CAF=CAF_plots(i_plot);
    userdata.initial.rho=rho_plots(i_plot);
    userdata.initial.alphaint=alphaint_plots(i_plot,:);
    userdata.initial.IAF=IAF;   
    userdata.initial.local_IAF=local_IAF;       
    userdata.initial.xlim=freq_range;
    
    R=spectra.ave_refspectra(i_plot,:);
    T=spectra.ave_testspectra(i_plot,:);
    
    YMaxplot=max(max(R),max(T));
    YMax=max(YMax,YMaxplot);
    
    i_ax=floor((i_plot-1)/N_col)+1;
    j_ax=mod(i_plot-1,N_col)+1;
    
    axes_handles(i_plot)=axes('units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height],...
        'tag',num2str(i_plot),'nextplot','add');
    set(axes_handles(i_plot),'units','normalized')
    
    h_selcheckboxes = uicontrol('style','checkbox','units','pixel',...
                                      'position',[x_plot(j_ax)+plot_width-15 y_plot(i_ax)+plot_height-15   15  15],...
                                      'value',userdata.selected,'backgroundcolor',get(gca,'color'),...
                                      'callback',@selcheckboxes_cb);
                                  
    userdata.h_selcheckboxes = h_selcheckboxes;    
    
    if(isnan(userdata.CAF)),
        
        set(userdata.h_selcheckboxes,'enable','off')
        
    end
    
    checkboxuserdata.index=i_plot;
    checkboxuserdata.data_index=dataplot_indexes(i_plot);
    checkboxuserdata.label=plot_labels{i_plot};
    checkboxuserdata.axes_handle=axes_handles(i_plot);
    set( userdata.h_selcheckboxes,'userdata',checkboxuserdata,'units','normalized');
    
    
    h_R=plot(f_plot,R,'r','tag',userdata.tags{3});
    h_T=plot(f_plot,T,'b','tag',userdata.tags{4});
    
    set(h_R,'ZData',ones(1,length(get(h_R,'XData'))));
    set(h_T,'ZData',ones(1,length(get(h_T,'XData'))));    
    
    if isnan(userdata.alphaint(1)) || isnan(userdata.alphaint(2)),
        
        userdata.alphaint(1)=NaN;
        userdata.alphaint(2)=NaN;
            
    end
    
    h_patch=patch([userdata.alphaint(1) userdata.alphaint(1) userdata.alphaint(2) userdata.alphaint(2)],...
            [0 YMaxplot YMaxplot 0],patch_color,'tag',userdata.tags{2});        
    set(h_patch,'edgecolor',patch_color);

    
    userdata.h_patch=h_patch;

    h_CAF=plot_lines(userdata.CAF,[],'k');
    set(h_CAF,'tag',userdata.tags{5});

    userdata.h_CAF=h_CAF;

    h_IAF=plot_lines(IAF,[],'k');
    set(h_IAF,'tag',userdata.tags{6},'linewidth',1.5);
    
    userdata.h_IAF=h_IAF;
    
    h_localIAF=plot_lines(local_IAF,[],'k--');
    set(h_localIAF,'tag',userdata.tags{7},'visible','on');
    
    userdata.h_localIAF=h_localIAF;
    
    set(axes_handles(i_plot),'YLim',[0 YMaxplot]);
    set(axes_handles(i_plot),'XLim',[freq_range(1) freq_range(end)]);
    
    userdata.YLim=get(gca,'YLim');
    userdata.initial.YLim=userdata.YLim;
    
    YLims(i_plot,:)=userdata.YLim;
            
    if userdata.selected==1 || userdata.rho>0,        
                
        h_title=title([userdata.label... 
            ' CAF=' sprintf('%.1f',userdata.CAF) ' Hz']);        
        set(h_title,'fontsize',8,'fontunits','normalized')
        userdata.title=get(h_title,'string');
       
        if userdata.selected==1,
           set(h_title,'color','r')
        end
        
        userdata.initial.title=get(h_title,'string');
        userdata.initial.title_color=get(h_title,'color');
        userdata.initial.h_title=h_title;
        
    else
                
        h_title=title(userdata.label);
        userdata.title=get(h_title,'string');
        userdata.initial.title=get(h_title,'string');
        userdata.initial.title_color=get(h_title,'color');
        
    end
    
    userdata.h_title=h_title;
    
    if j_ax==1,
        
        if spectra.par.typeproc==0
           
            ylabel('PSD A^2/Hz','fontsize',8)
            
        else
            
           ylabel('PSD (\mu V^2/Hz)','fontsize',8)
           
        end
        
    end
    
    if i_ax==N_rows,
        
        xlabel('f (Hz)','fontsize',8)
        
    end
    
    set(axes_handles(i_plot),'userdata',userdata);
    clear userdata
    
end

if YMax==0,
   YMax=YMax+1; 
end

i_ax=floor((N_plots-1)/N_col)+1;
j_ax=mod(N_plots-1,N_col)+1;

axes_handles(N_plots)=axes('units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height],...
'tag',num2str(N_plots),'nextplot','add');
set(axes_handles(N_plots),'units','normalized','visible','off')

h_R=plot(f_plot,R,'r');
set(h_R,'visible','off');

h_T=plot(f_plot,T,'b');
set(h_T,'visible','off');
        
h_IAF=plot_lines(IAF,[],'k');
set(h_IAF,'linewidth',1.5);
set(h_IAF,'visible','off');        

h_CAF=plot_lines(NaN,[],'k');
set(h_IAF,'visible','off');        

h_local_IAF=plot_lines(local_IAF,[],'k--');
set(h_local_IAF,'visible','off');
                
h_legend=legend([h_R h_T h_IAF h_CAF h_local_IAF],{'ref. PSD','test PSD','overall IAF','CAF','local IAF'});
set(h_legend,'tag','legend','visible','on','fontsize',10,'units','normalized','fontunits','normalized');    
 
 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%
%%%%%%%%  TEXT: IAF value
%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
h_IAFtext=uicontrol('style','text','fontsize',10,'fontweight','bold','horizontalalignment','left',...
                     'string',['overall IAF=' sprintf('%.1f',IAF) ' Hz'],'fontunits','normalized',...
                     'units','normalized','position',[0.005    0.07    0.17    0.0200],...
                     'backgroundcolor',get(h_fig,'color'));
                 

h_localIAFtext=uicontrol('style','text','fontsize',10,'fontweight','bold','horizontalalignment','left',...
                     'string',['local IAF=' sprintf('%.1f',local_IAF) ' Hz'],'fontunits','normalized',...
                     'units','normalized','position',[0.005    0.04   0.1500    0.0200],...
                     'backgroundcolor',get(h_fig,'color'));
                 
h_averagealpha_text=uicontrol('style','text','fontsize',10,'fontweight','bold','horizontalalignment','left',...
                     'string',['local ave alpha int.=' sprintf('[%.1f %.1f]',[local_ave_f1 local_ave_f2]) ' Hz'],'fontunits','normalized',...
                     'units','normalized','position',[0.005    0.01   0.300    0.0200],...
                     'backgroundcolor',get(h_fig,'color'));
                 
                 
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% CHECKBOX: TOPOGRAPHIC PLOT
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 
                 
h_topoplotcheckbox=uicontrol('style','checkbox','fontsize',10,'string','topographic distribution','fontunits','normalized',...
                                         'units','normalized','position',[0.24 0.05 0.17 0.026],...
                                         'backgroundcolor',get(h_fig,'color'),'callback',@topoplotcheckbox_cb);

try

   [tmp lab th rd]=readlocs(chanlocs);
   
   if sum(isnan(th))>0 || sum(isnan(rd))>0,
      set(h_topoplotcheckbox,'enable','off');                              
   end
   
catch

    set(h_topoplotcheckbox,'enable','off');

end
                                     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% PANEL: YLim and XLim SETTINGS
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_ylimpanel=uipanel('units','normalized','position',[0.41    0.0013    0.31    0.0693]);


h_ylimcheckbox=uicontrol(h_ylimpanel,'style','checkbox','fontsize',9,'string','uniform y ranges (microV^2/Hz)',...
                                        'fontunits','normalized','units','normalized',...
                                        'position',[0.01   0.6000    0.7    0.3300],'callback',@ylimcheckbox_cb,'value',1);

                                                                                                                  
h_ylimedit=uicontrol(h_ylimpanel,'style','edit','fontsize',9,...
                                      'string',sprintf('%d, %.2f',[0 YMax]),'fontunits','normalized',...
                                      'units','normalized','position',[0.72 0.5833    0.27     0.4167],...
                                      'callback',@ylimedit_cb, 'TooltipString','Insert values separated by comma');
ylimcheckbox_cb(h_ylimcheckbox);
 
h_xlimtext=uicontrol(h_ylimpanel,'style','text','fontsize',9,'horizontalalignment','left','string','x axes range (Hz)','fontunits','normalized',...
                        'units','normalized','position',[0.1   0.2   0.54   0.33],...
                        'backgroundcolor',get(h_ylimpanel,'backgroundcolor'));     
                    
h_xlimedit=uicontrol(h_ylimpanel,'style','edit','fontsize',9,...
                                    'string',sprintf('%.2f, %.2f',get(axes_handles(1),'XLim')),'fontunits','normalized',...
                                    'units','normalized','position',[0.72   0.1    0.27   0.4167],...
                                    'callback',@xlimedit_cb, 'TooltipString','Insert values separated by comma');                    
                                  
                                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% BUTTON: RESTORE INITIAL VALUES
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_restoreinitialvaluesbut=uicontrol('fontsize',10,'string','restore initial values','fontunits','normalized',...
                                  'units','normalized','position',[0.7233    0.0021    0.1900    0.0350],...
                                  'callback',@restoreinitialvaluesbut_cb);
                              
                                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% BUTTON: SYNCHRONIZE WITH TABLE DATA
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_syncwithtabledatabut=uicontrol('fontsize',10,'string','synchronize with table data','fontunits','normalized',...
                                  'units','normalized','position',[0.7233    0.0370    0.1900    0.0350],...
                                  'callback',@syncwithtabledatabut_cb);                              

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% BUTTON: OK
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_okbut=uicontrol('fontsize',10,'string','ok','fontunits','normalized',...
                                  'units','normalized','position',[0.9143    0.0381    0.0800    0.0350],...
                                  'callback',@okbut_cb);

                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% BUTTON: CANCEL
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_cancelbut=uicontrol('fontsize',10,'string','cancel','fontunits','normalized',...
                                  'units','normalized','position',[0.9157    0.0010    0.0800    0.0350],...
                                  'callback',@cancelbut_cb);

                                                                                          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              
%%%%%%%%%%
%%%%%%%%%%  CALLBACKS
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function WindowButtonDownFcn_cb(hObject,eventdata)

    if ~strcmpi(get(gco,'tag'),'legend'),

        if ~isempty(ancestor(gco,'axes')),

            h=ancestor(gco,'axes');
            current_plot=str2double(get(h,'tag'));

            pt=get(h,'currentpoint');
            new_freq_positions(1)=pt(1,1);
            button_down=1;

        end

    end

end


function WindowButtonMotionFcn_cb(hObject,eventdata)

    if button_down==1,                                   

        h=ancestor(gco,'axes');
        i_plot=str2double(get(h,'tag'));

        x_lim=get(h,'XLim');
        

        h_patch=findobj(axes_handles(current_plot),'tag',tags{2});

        pt=get(h,'currentpoint');

        if pt(1,1)>=x_lim(1) && pt(1,1)<=x_lim(2),

                set(h_patch,'XData',[new_freq_positions(1) new_freq_positions(1) pt(1,1) pt(1,1)]);

        else

            if pt(1,1)<x_lim(1),
                
                set(h_patch,'XData',[new_freq_positions(1) new_freq_positions(1) x_lim(1) x_lim(1)]);
                
            end
            
            if pt(1,1)>x_lim(2),
                
                set(h_patch,'XData',[new_freq_positions(1) new_freq_positions(1) x_lim(2) x_lim(2)]);
                
            end

        end

    end

end


function WindowButtonUpFcn_cb(hObject,eventdata)

    if button_down==1,
                
                h=ancestor(gco,'axes'); 
                x_lim=get(h,'xlim');
                
                pt=get(h,'currentpoint');
                pt_x=pt(1,1);
                                
                ud=get(h,'userdata');                                           
                plot_index=ud.index;
                data_index=ud.data_index;
                
                if pt_x==new_freq_positions(1),
                    
                else
                 
                  if pt_x<x_lim(1),
                     pt_x=x_lim(1);
                  end
                  
                  if pt_x>x_lim(2),
                      pt_x=x_lim(2);
                  end
                  
                if pt_x<new_freq_positions(1),

                   new_freq_positions(2)=new_freq_positions(1);
                   new_freq_positions(1)=pt_x;

                else

                   new_freq_positions(2)=pt_x;

                end 

                    alphaint_plots(plot_index,:)=new_freq_positions;                     

                    [rho_new CAF_new powers] = compute_rho_CAF(spectra.ave_refspectra(plot_index,:),spectra.ave_testspectra(plot_index,:),...
                                                        spectra.f,new_freq_positions,spectra.par.CFcomp);
                                                    
                    ud.alphaint=new_freq_positions;
                    ud.CAF=CAF_new;
                    ud.rho=rho_new;
                    
                    CAF_plots(plot_index)=CAF_new;
                    CAFs(data_index)=CAF_new;
                    rho_plots(plot_index)=rho_new;
                    
                    results{data_index+1,4}=CAF_new;
                    results{data_index+1,5}=rho_new;
                    results(data_index+1,[6 7])=num2cell(new_freq_positions);
                    results{data_index+1,8} = powers.ref_power;
                    results{data_index+1,9} = powers.test_power;                    
                    results{data_index+1,10}= powers.power_var_perc;                    
 
                    h_CAF=ud.h_CAF;

                    set(h_CAF,'XData',[CAF_new CAF_new]);
                    
                    if get(h_topoplotcheckbox,'value')==0,
                        
                       %new_title=[ud.label  ' CF=' sprintf('%.2f',CAF_new) ' \rho=' sprintf('%.2f',rho_new)];     
                       new_title=[ud.label  ' CAF=' sprintf('%.1f',CAF_new) ' Hz'];
                       
                    else
                        
                       new_title=ud.label;
                       
                    end
                    
                    h_title=get(h,'title');
                    set(h_title,'string',new_title);

                    ud.title=new_title;
                    set(h,'userdata',ud);
                     
                    set(ud.h_selcheckboxes,'enable','on')
                    
                    if ud.selected==1, 
                        update_IAF();
                    end

                end                                 

                button_down=0;                                        
                current_plot=0;
                new_freq_positions=[NaN NaN];
                
    end

end

%%%% axes checkboxes 

function selcheckboxes_cb(hObject,eventdata)
        
              ud         =  get(hObject,'userdata'); 
              index      =  ud.index;
              data_index =  ud.data_index;
              val        =  get(hObject,'value');
              ax_handle  =  ud.axes_handle;
              ud_ax      =  get(ax_handle,'userdata');

              ud_ax.selected=val;
              set(ax_handle,'userdata',ud_ax);

              results{data_index+1,3}=val;
              selected_plots(index)=val;
              selected(data_index)=val;
              h_title=get(ax_handle,'title');
                 
              if val==1,       
                  
                     set(h_title,'color','r');
                     
              else
                  
                     set(h_title,'color','k');
                     
              end
              
                     update_IAF();
 
end


%%%% 'topographic plot' checkbox 

function topoplotcheckbox_cb(hObject,eventdata)
    
         if get(hObject,'value')==1 && length(chanlocs)>1,
             
             topoplot_width=0.88;
             IAFtext_pos=get(h_IAFtext,'position');
             topoplot_height=[0.9-IAFtext_pos(2)];
             
             x_shift=(1-topoplot_width)/2;
             y_shift=IAFtext_pos(2)+(1-topoplot_height-IAFtext_pos(2))/2;
                          
             [x_topoplot y_topoplot ax_width_topoplot ax_height_topoplot]=getaxespositions(chanlocs,topoplot_width,topoplot_height);
             
             x_topoplot=x_shift+x_topoplot;
             y_topoplot=y_shift+y_topoplot;
             
             for i_topoplot=1:length(x_topoplot),
                 
                 h_ax=axes_handles(i_topoplot);
                 ud=get(h_ax,'userdata');
                 
                 set(ud.h_title,'fontunits','pixel');
                 %set(ud.h_title,'string',ud.label)
                 
                 set(get(axes_handles(i_topoplot),'xlabel'),'fontunits','pixel','visible','off');
                 set(get(axes_handles(i_topoplot),'ylabel'),'fontunits','pixel','visible','off');
                 
                 set(axes_handles(i_topoplot),'position',[x_topoplot(i_topoplot) y_topoplot(i_topoplot) ax_width_topoplot ax_height_topoplot]);
                 
                 set(ud.h_title,'fontunits','normalized');
                 set(get(axes_handles(i_topoplot),'xlabel'),'fontunits','normalized');
                 set(get(axes_handles(i_topoplot),'ylabel'),'fontunits','normalized');
                 
                 checkbox_pos=get(ud.h_selcheckboxes,'position');
                 set(ud.h_selcheckboxes,'position',[x_topoplot(i_topoplot)+ax_width_topoplot-checkbox_pos(3), y_topoplot(i_topoplot)+ax_height_topoplot-checkbox_pos(4),...
                                                             checkbox_pos(3), checkbox_pos(4)]);
                 
             end
             
             [m i_topoplot]=min(x_topoplot);
             set(get(axes_handles(i_topoplot),'ylabel'),'string','PSD(\muV^2/Hz)','visible','on')
             set(get(axes_handles(i_topoplot),'xlabel'),'string','f(Hz)','visible','on')
             
             set(findobj(h_fig,'tag','legend'),'visible','off');
                                                         
         else
                          
            set(h_fig,'units','pixel');
            fig_position=get(h_fig,'position');
            fig_width=fig_position(3);
            fig_height=fig_position(4);

            plot_width=(fig_width-delta_l-delta_r-(N_col-1)*delta_hor)/N_col;
            plot_height=(fig_height-delta_u-delta_b-(N_rows-1)*delta_vert)/N_rows;

            x_plot=delta_l:plot_width+delta_hor:delta_l+(N_col-1)*(plot_width+delta_hor);
            y_plot=fig_height-delta_u-plot_height:-(plot_height+delta_vert):fig_height-delta_u-plot_height-(N_rows-1)*(plot_height+delta_vert);


            for i_plot=1:N_plots-1,
                 
                userdata=get(axes_handles(i_plot),'userdata');
                
                i_ax=floor((i_plot-1)/N_col)+1;
                j_ax=mod(i_plot-1,N_col)+1;          
                
                set(userdata.h_title,'fontunits','pixel');
                set(get(axes_handles(i_plot),'xlabel'),'fontunits','pixel','visible','off');
                set(get(axes_handles(i_plot),'ylabel'),'fontunits','pixel','visible','off');
                
                set(axes_handles(i_plot),'units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height]);                
                set(axes_handles(i_plot),'units','normalized')
                
                set(userdata.h_title,'fontunits','normalized');
                set(get(axes_handles(i_plot),'xlabel'),'fontunits','normalized');
                set(get(axes_handles(i_plot),'ylabel'),'fontunits','normalized');
                
                
                
                set(userdata.h_selcheckboxes,'units','pixel','position',[x_plot(j_ax)+plot_width-15 y_plot(i_ax)+plot_height-15   15  15]);
                set(userdata.h_selcheckboxes,'units','normalized')
                                
                if userdata.selected==1 || userdata.rho>0,        
                   
                    set(userdata.h_title,'string',[userdata.label... 
                        ' CAF=' sprintf('%.1f',userdata.CAF) ' Hz']);
                    set(userdata.h_title,'fontunits','normalized')                                         
                    
                    if userdata.selected==1,
                       set(userdata.h_title,'color','r')
                    end

                else
                    
                     
                     set(userdata.h_title,'string',userdata.label);
                     set(userdata.h_title,'fontunits','normalized');
                     
                end

                if j_ax==1,

                     set(get(axes_handles(i_plot),'ylabel'),'fontunits','pixel','fontsize',10,'visible','on');
                     set(get(axes_handles(i_plot),'ylabel'),'fontunits','normalized');
                end

                if i_ax==N_rows,
                    
                   set(get(axes_handles(i_plot),'xlabel'),'fontunits','pixel','fontsize',10,'visible','on');                   
                   set(get(axes_handles(i_plot),'xlabel'),'fontunits','normalized');
                   
                end

            end


            i_ax=floor((N_plots-1)/N_col)+1;
            j_ax=mod(N_plots-1,N_col)+1;
            
            set(axes_handles(N_plots),'units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height]);
            set(axes_handles(N_plots),'units','normalized')
            set(findobj(h_fig,'tag','legend'),'visible','on');
             
            set(h_fig,'units','normalized');
            
         end

end


%%%% xlim setting


function xlimedit_cb(hObject,eventdata)
    
         XLim=sscanf(get(hObject,'string'),'%f, %f');
         
         if XLim(1)>spectra.f(end) && XLim(2)>spectra.f(end),
            
             XLim=[spectra.f(1) spectra.f(end)];
             
         end
         
         if XLim(1)<spectra.f(1) && XLim(2)<spectra.f(1),
            
             XLim=[spectra.f(1) spectra.f(end)];
                          
         end
         
         if XLim(2)>spectra.f(end),
            
             XLim=[XLim(1) spectra.f(end)];
             
         end
         
         if XLim(1)<spectra.f(1),
            
             XLim=[spectra.f(1) XLim(2)];
                          
         end
                               
         set(hObject,'string',sprintf('%.1f,%.1f',XLim));
                               
         
        for i_plot=1:length(axes_handles)-1,
                                  
                 set(axes_handles(i_plot),'XLim',XLim);
             
        end

end

         
%%%% ylim setting

function ylimcheckbox_cb(hObject,eventdata)  
    
         value=get(hObject,'value');
                  
         if value,
             
             y_range=get(h_ylimedit,'string');
             y_range=sscanf(y_range,'%f, %f');
             
             for i_plot=1:length(axes_handles)-1,
                 
                 set(axes_handles(i_plot),'YLim',y_range);
                 
                 ud=get(axes_handles(i_plot),'userdata');

                 h_patch=ud.h_patch;
                 h_CAF=ud.h_CAF;
                 h_IAF=ud.h_IAF;
                 h_localIAF=ud.h_localIAF;
                 
                 set(h_patch,'YData',[y_range(1) y_range(2) y_range(2) y_range(1)]);                                                                        
                 set(h_CAF,'YData',[y_range(1) y_range(2)]);                                                                        
                 set(h_IAF,'YData',[y_range(1) y_range(2)]);                                                   
                 set(h_localIAF,'YData',[y_range(1) y_range(2)]);
                    
             end
             
        else
             
            for i_plot=1:length(axes_handles)-1,
                 
                 y_range=YLims(i_plot,:);
                 
                 set(axes_handles(i_plot),'YLim',y_range);
                 
                 ud=get(axes_handles(i_plot),'userdata');
                 
                 h_patch=ud.h_patch;
                 h_CAF=ud.h_CAF;
                 h_IAF=ud.h_IAF;
                 h_localIAF=ud.h_localIAF;
                 
                 set(h_patch,'YData',[y_range(1) y_range(2) y_range(2) y_range(1)]);
                 set(h_CAF,'YData',[y_range(1) y_range(2)]);
                 set(h_IAF,'YData',[y_range(1) y_range(2)]);
                 set(h_localIAF,'YData',[y_range(1) y_range(2)]);     
                                                   
             end             
                                       
         end

end



%%%% ylim edit callback

function ylimedit_cb(hObject,eventdata),
    
         if get(h_ylimcheckbox,'value'),
             
                   y_range=get(hObject,'string');
                   y_range=sscanf(y_range,'%f, %f');
                   
                   if y_range(2)==y_range(1),
                       
                      y_range(2)=y_range(1)+1; 
                      
                   end
                   
                   set(hObject,'string',sprintf('%.2f,%.2f',y_range));             
             
                      ylimcheckbox_cb(h_ylimcheckbox)      
             
         end

end


%%%% 'Restore initial values' button callback

function restoreinitialvaluesbut_cb(hObject, eventdata)

        results=results_ini;
         
        selected_plots=cell2mat(results(dataplot_indexes+1,3));
        CAF_plots=cell2mat(results(dataplot_indexes+1,4));
        rho_plots=cell2mat(results(dataplot_indexes+1,5));
        alphaint_plots=cell2mat(results(dataplot_indexes+1,[6 7]));

        selected=cell2mat(results(2:end,3));
        CAFs=cell2mat(results(2:end,4));

        if ~isempty(find(selected==1,1)),

           IAF=median(CAFs(selected==1));

        else

            IAF=NaN;

        end

        if ~isempty(find(selected_plots==1,1)),

            local_IAF=median(CAF_plots(selected_plots==1));
            local_ave_f1=mean(alphaint_plots(selected_plots==1,1));
            local_ave_f2=mean(alphaint_plots(selected_plots==1,2));

        else

           local_IAF=NaN;
           local_ave_f1=NaN;
           local_ave_f2=NaN;

        end
         
         for i_plot=1:length(axes_handles)-1,
             
             h_ax=axes_handles(i_plot);
             userdata=get(h_ax,'userdata');
             
             userdata.selected=userdata.initial.selected;
             userdata.CAF=userdata.initial.CAF;
             userdata.rho=userdata.initial.rho;
             userdata.alphaint=userdata.initial.alphaint;
             userdata.IAF=userdata.initial.IAF;  
             userdata.local_IAF=userdata.initial.local_IAF;
             userdata.title=userdata.initial.title;
                          
             set(get(h_ax,'title'),'string',userdata.title);
             
             if(isnan(userdata.CAF)),

                set(userdata.h_selcheckboxes,'enable','off')

             end
             
             if userdata.selected==1,                 
                 set(userdata.h_selcheckboxes,'value',1); 
                 set(get(h_ax,'title'),'color','r');
             else
                 set(userdata.h_selcheckboxes,'value',0); 
                 set(get(h_ax,'title'),'color','k');                 
             end
            
             y_range=YLims(i_plot,:);
             x_range=userdata.initial.xlim;
             
             set(h_ax,'YLim',y_range);
             set(h_ax,'XLim',x_range);
             
             set(userdata.h_patch,'XData',[userdata.alphaint(1) userdata.alphaint(1) userdata.alphaint(2) userdata.alphaint(2)]);
             set(userdata.h_patch,'YData',[y_range(1) y_range(2) y_range(2) y_range(1)]);
             
             set(userdata.h_CAF,'XData',[userdata.CAF userdata.CAF]);
             set(userdata.h_CAF,'YData',[y_range(1) y_range(2)]);
             
             set(userdata.h_IAF,'XData',[userdata.CAF userdata.CAF]);
             set(userdata.h_IAF,'YData',[y_range(1) y_range(2)]);

             set(userdata.h_localIAF,'XData',[userdata.IAF userdata.IAF]);
             set(userdata.h_localIAF,'YData',[freq_range(1) freq_range(2)]);
             
         end         

         update_IAF();
         
         set(h_ylimcheckbox,'value',1);
         set(h_ylimedit,'string',sprintf('%.1f,%.1f',[0 YMax])); 
         ylimcheckbox_cb(h_ylimcheckbox);
         set(h_xlimedit,'string',sprintf('%.1f,%.1f',x_range));
         
         
end

%%%% 'synchronize with table data' button

function syncwithtabledatabut_cb(hObject,eventdata)
    
           set(h_table,'data',cell2mat(results(2:end,3:end)));
           f_handle();
%           delete(h_fig) 
    
end

%%%% 'ok' button 

function okbut_cb(hObject,eventdata)
    
           
           delete(h_fig)
      
    
end

%%%% 'cancel' button 

function cancelbut_cb(hObject,eventdata)

           delete(h_fig)
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%    HELPER FUNCTIONS
%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function update_IAF()
    
        if ~isempty(find(selected==1,1)),

           IAF=median(CAFs(selected==1));

        else

            IAF=NaN;

        end
        
        results(2:end,2)={IAF};
        
        if ~isempty(find(selected_plots==1,1)),

            local_IAF=median(CAF_plots(selected_plots==1));
            local_ave_f1=mean(alphaint_plots(selected_plots==1,1));
            local_ave_f2=mean(alphaint_plots(selected_plots==1,2));

        else

           local_IAF=NaN;
           local_ave_f1=NaN;
           local_ave_f2=NaN;

        end    
    
        set(h_IAFtext,'string',['overall IAF=' sprintf('%.1f',IAF) ' Hz'])
        set(h_localIAFtext,'string',['local IAF=' sprintf('%.1f',local_IAF) ' Hz']);        
        set(h_averagealpha_text,'string',['local ave alpha interval=' sprintf('[%.1f %.1f]',[local_ave_f1 local_ave_f2]) ' Hz']);        
                
        for i_handle=1:length(axes_handles)-1,

             h_ax=axes_handles(i_handle);
             ud=get(h_ax,'userdata');

             ud.IAF=IAF;
             ud.local_IAF=local_IAF;

             set(ud.h_IAF,'XData',[ud.IAF ud.IAF])                                  
             set(ud.h_localIAF,'XData',[ud.local_IAF ud.local_IAF])                                  

        end

end


function [rho CAF powers_struct]=compute_rho_CAF(R,T,f,freq_int,CFcomp)

    i1=find(f>=freq_int(1),1,'first');
    i2=find(f<=freq_int(2),1,'last');
    D=R-T;
    D=D(:);
    f=f(:);
    
    rho=round(trapz(f(i1:i2),D(i1:i2))/(freq_int(2)-freq_int(1))*1000)/1000;

    R=R(:);
    T=T(:);
    
    if CFcomp==1,
       CAF=round(trapz(f(i1:i2),R(i1:i2).*f(i1:i2))/trapz(f(i1:i2),R(i1:i2))*10)/10;
    elseif CFcomp==2,
       CAF=round(trapz(f(i1:i2),T(i1:i2).*f(i1:i2))/trapz(f(i1:i2),T(i1:i2))*10)/10;
    else
       CAF=round(trapz(f(i1:i2),abs(R(i1:i2)-T(i1:i2)).*f(i1:i2))/trapz(f(i1:i2),abs(R(i1:i2)-T(i1:i2)))*10)/10;
    end
    
    powers_struct.ref_power=round(trapz(f(i1:i2),R(i1:i2))*100)/100;
    powers_struct.test_power=round(trapz(f(i1:i2),T(i1:i2))*100)/100;
    powers_struct.power_var_perc=round((powers_struct.test_power-powers_struct.ref_power)/powers_struct.ref_power*100*10)/10;
    
end

function [x_plot y_plot ax_width ax_height]=getaxespositions(chanlocs,fig_width,fig_height)

    if nargin<3,

       fig_height=1;

       if nargin<2,

           fig_width=1;

       end

    end

    [tmp labels th rd]=readlocs(chanlocs);

    th = pi/180*th;                 % convert degrees to radians
    rd = rd; 

    [y,x] = pol2cart(th,rd);        % (x verso destra e y verso l'alto);

    x_plot=x*fig_width+fig_width/2;
    y_plot=y*fig_height+fig_width/2;
    
    min_dist=NaN;
        
    for i=1:length(x_plot),

        x_c=x_plot(i);
        y_c=y_plot(i);

        x_d=x_plot;
        y_d=y_plot;

        x_d(i)=[];
        y_d(i)=[];

        for j=1:length(x_d),

           dist=sqrt((x_d(j)-x_c)^2+(y_d(j)-y_c)^2);
           min_dist=min(min_dist,dist);           

        end

    end   
        
    fig_width=fig_width-min_dist/2;
    fig_height=fig_height-min_dist/2;    
    
    x_plot=x*fig_width+fig_width/2;
    y_plot=y*fig_height+fig_width/2;
    

    ax_width=0.8*min_dist;
    ax_height=0.6*min_dist;


end


end