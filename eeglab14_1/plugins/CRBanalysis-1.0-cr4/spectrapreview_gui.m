% spectrapreview_gui() - 
%
% Usage:
%   >>  h_fig=spectrapreview_gui(spectra)
%
% Inputs:   
%    
%       spectra -  struct  - needed  
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





function h_fig=spectrapreview_gui(spectra)

dataplot_indexes=spectra.par.indexes;
plot_labels=spectra.par.labels;
chanlocs=spectra.par.chanlocs;

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

axes_handles=zeros(1,N_plots);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%  LAYOUT
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_fig=figure('name','spectrapreview_gui()','numbertitle','off',...
    'position',fig_position,'units','normalized',...
    'toolbar','none');

movegui(h_fig,'center');

YLims=zeros(N_plots-1,2);

for i_plot=1:N_plots-1,
    
    R=spectra.ave_refspectra(i_plot,:);
    T=spectra.ave_testspectra(i_plot,:);
    
    YMaxplot=max(max(R),max(T));
    YMax=max(YMax,YMaxplot);
    
    i_ax=floor((i_plot-1)/N_col)+1;
    j_ax=mod(i_plot-1,N_col)+1;
    
    axes_handles(i_plot)=axes('units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height],...
        'tag',num2str(i_plot),'nextplot','add');
    set(axes_handles(i_plot),'units','normalized')
        
    h_R=plot(f_plot,R,'r','tag','R');
    h_T=plot(f_plot,T,'b','tag','T');
    
    set(h_R,'ZData',ones(1,length(get(h_R,'XData'))));
    set(h_T,'ZData',ones(1,length(get(h_T,'XData'))));    
    xlim(spectra.par.freq_range);
    YLims(i_plot,:)=get(gca,'YLim');
    
    h_title=title(spectra.par.labels(i_plot));
                 
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
    
    
end

if YMax==0,
    
   YMax=1;
   
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
        
                
h_legend=legend([h_R h_T],{'Ref. PSD','Test PSD'});
set(h_legend,'tag','legend','visible','on','fontsize',10,'units','normalized','fontunits','normalized');    
 

               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%
%%%%%%%%%% CHECKBOX: TOPOGRAPHIC PLOT
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                 
                 
h_topoplotcheckbox=uicontrol('style','checkbox','fontsize',10,'string','topographic distribution','fontunits','normalized',...
                                         'units','normalized','position',[0.26 0.05 0.17 0.026],...
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

h_ylimpanel=uipanel('units','normalized','position',[0.44    0.0013    0.26    0.0693]);


h_ylimcheckbox=uicontrol(h_ylimpanel,'style','checkbox','fontsize',10,'string','Equalize YLim',...
                                        'fontunits','normalized','units','normalized',...
                                        'position',[0.0200    0.7000    0.5    0.2900],'callback',@ylimcheckbox_cb,'value',1);
                                                                              
                                    
h_ylimedit=uicontrol(h_ylimpanel,'style','edit','fontsize',10,...
                                      'string',sprintf('%d, %.2f',[0 YMax]),'fontunits','normalized',...
                                      'units','normalized','position',[0.56    0.5833    0.4000    0.4167],...
                                      'callback',@ylimedit_cb, 'TooltipString','Insert values separated by comma');
                                  
ylimcheckbox_cb(h_ylimcheckbox);
                                  
h_xlimtext=uicontrol(h_ylimpanel,'style','text','fontsize',10,'horizontalalignment','left','string','XLim','fontunits','normalized',...
                        'units','normalized','position',[0.1   0.2   0.3   0.3],...
                        'backgroundcolor',get(h_ylimpanel,'backgroundcolor'));     
                    
h_xlimedit=uicontrol(h_ylimpanel,'style','edit','fontsize',10,...
                                    'string',sprintf('%.2f, %.2f',get(axes_handles(1),'XLim')),'fontunits','normalized',...
                                    'units','normalized','position',[0.56   0.1    0.4   0.4167],...
                                    'callback',@xlimedit_cb, 'TooltipString','Insert values separated by comma');                                                                                                                   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              
%%%%%%%%%%
%%%%%%%%%%  CALLBACKS
%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% 'topographic plot' checkbox 

function topoplotcheckbox_cb(hObject,eventdata)
    
         if get(hObject,'value')==1 && length(chanlocs)>1,
             
             topoplot_width=0.88;
             pos=get(hObject,'position');
             topoplot_height=[0.9-pos(2)];
             
             x_shift=(1-topoplot_width)/2;
             y_shift=pos(2)+(1-topoplot_height-pos(2))/2;
                          
             [x_topoplot y_topoplot ax_width_topoplot ax_height_topoplot]=getaxespositions(chanlocs,topoplot_width,topoplot_height);
             
             x_topoplot=x_shift+x_topoplot;
             y_topoplot=y_shift+y_topoplot;
             
             for i_topoplot=1:length(x_topoplot),
                 
                 h_ax=axes_handles(i_topoplot);

                 h_title=get(h_ax,'title');
                 set(h_title,'fontunits','pixel');
                 %set(ud.h_title,'string',ud.label)
                 
                 set(get(axes_handles(i_topoplot),'xlabel'),'fontunits','pixel','visible','off');
                 set(get(axes_handles(i_topoplot),'ylabel'),'fontunits','pixel','visible','off');
                 
                 set(axes_handles(i_topoplot),'position',[x_topoplot(i_topoplot) y_topoplot(i_topoplot) ax_width_topoplot ax_height_topoplot]);
                 
                 set( h_title,'fontunits','normalized');
                 set(get(axes_handles(i_topoplot),'xlabel'),'fontunits','normalized');
                 set(get(axes_handles(i_topoplot),'ylabel'),'fontunits','normalized');
                 

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
                
                h_ax=axes_handles(i_plot);
                h_title=get(h_ax,'title');    
                 
                i_ax=floor((i_plot-1)/N_col)+1;
                j_ax=mod(i_plot-1,N_col)+1;          
                
                set(h_title,'fontunits','pixel');
                set(get(axes_handles(i_plot),'xlabel'),'fontunits','pixel','visible','off');
                set(get(axes_handles(i_plot),'ylabel'),'fontunits','pixel','visible','off');
                
                set(axes_handles(i_plot),'units','pixel','position',[x_plot(j_ax),y_plot(i_ax) plot_width plot_height]);                
                set(axes_handles(i_plot),'units','normalized')
                
                set(h_title,'fontunits','normalized');
                set(get(axes_handles(i_plot),'xlabel'),'fontunits','normalized');
                set(get(axes_handles(i_plot),'ylabel'),'fontunits','normalized');
                                

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
                    
             end
             
        else
             
            for i_plot=1:length(axes_handles)-1,
                 
                 y_range=YLims(i_plot,:);
                 
                 set(axes_handles(i_plot),'YLim',y_range);
                  
             end             
                                       
         end

end



%%%% ylim edit callback

function ylimedit_cb(hObject,eventdata),
    
         if get(h_ylimcheckbox,'value'),

                   y_range=get(h_ylimedit,'string');
                   y_range=sscanf(y_range,'%f, %f');
                   
                   if y_range(2)==y_range(1),
                       
                      y_range(2)=y_range(1)+1; 
                      
                   end
                   
                   set(h_ylimedit,'string',sprintf('%.2f,%.2f',y_range));
                   
                   ylimcheckbox_cb(h_ylimcheckbox);      
             
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
         
         set(h_ylimcheckbox,'value',0);
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


function [rho CAF powers_struct]=compute_rho_CAF(R,T,f,freq_int)

    i1=find(f>=freq_int(1),1,'first');
    i2=find(f<=freq_int(2),1,'last');
    D=R-T;
    D=D(:);
    f=f(:);
    
    rho=sum( D(i1:i2)*(f(2)-f(1)) )/(freq_int(2)-freq_int(1));

    R=R(:);

    CAF=sum( R(i1:i2).*f(i1:i2) )/sum( R(i1:i2) );
        
    powers_struct.ref_power=sum(R(i1:i2))*(f(2)-f(1));
    powers_struct.test_power=sum(T(i1:i2))*(f(2)-f(1));
    powers_struct.power_var_perc=(powers_struct.test_power-powers_struct.ref_power)/powers_struct.ref_power*100;
    
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