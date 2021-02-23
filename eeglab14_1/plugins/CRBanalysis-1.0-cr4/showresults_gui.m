% showresults_gui() - displays an interactive window for inspecting results and re-launching the CRB analysis
%                      with either new parameters values or custom settings  
%
% Usage:
%   >>  CRB_new=showresults_gui(CRB,par) 
%
% Inputs:   
%    
%       CRB - struct - needed -  first output of CRBanalysis() with the second ouput of CRBanalysis() as its field 'spectra'
%       par - struct - needed -  see pop_CRBanalysis() help
%    
% Outputs:
%
%   CRB_new  - struct - same as first output with 'spectra' and 'par' integrated as its fields
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



function CRB_new=showresults_gui(CRB,par)
  
 CRB_new=CRB;        
 par_ini=par;
 IAF=CRB.results_num(1,1);
 
 ave_alpha_int=[mean(CRB.results_num(CRB.results_num(:,2)==1,5)) mean(CRB.results_num(CRB.results_num(:,2)==1,6))];
 
 datamatrix=CRB.results_num(:,2:end);
 columnnames=CRB.colnames(2:end);
 rownames=CRB.rownames;
 IAFtext=['IAF = ' sprintf('%.1f',IAF) ' Hz'];
 ave_alpha_int_text=['ave alpha interval=' sprintf('[%.1f %.1f]',ave_alpha_int) 'Hz'];
 
 if par.typeproc == 1,
     
     rho_unit_str = ' microV^2/Hz';
     
 else
     
     rho_unit_str = ' A^2/Hz';
     
 end
 
 if isfield(CRB,'L') && isfield(CRB.L,'rho_sub'),
     
     rhosubtext=['rho_sub = ' sprintf('%.3f',CRB.L.rho_sub) rho_unit_str];
     
 else
     
     rhosubtext=['rho_sub = NaN'  rho_unit_str];
     
 end
 
 par=pop_CRBanalysis_parcheck(par);
 par.CRBpar.labels=rownames;

 columneditable=[true false false true true false false false];
 columnformat={'numeric','numeric','numeric','numeric','numeric','numeric','numeric','numeric'};
 
 close_flag=0;
 cancel_flag=0;
 spectra_fig_handles={};

 h_fig=figure('name','GUI for numerical values inspection - showresults_gui()','numbertitle','off',...
              'position',[ 0 0  1070 699],'units','normalized',...
             'menubar','none','toolbar','none','CloseRequestFcn', @CloseRequestFcn);

 movegui(h_fig,'center');


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%
 %%%%%%%%%%%%%%   TABLE: CRB results
 %%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 h_table=uitable('parent',h_fig,'data',datamatrix,'fontsize',10,'units','normalized','position',[0.01 0.07 0.7 0.92]);

 set(h_table,'columnname',columnnames,'rowname',rownames,'columnformat',columnformat,'columneditable',columneditable)
 set(h_table,'columnwidth','auto')                   

 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%   IAF text
 %%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 h_IAFtext=uicontrol('parent',h_fig,'style','text',...
                    'string',IAFtext,'fontsize',10,'FontWeight','bold','horizontalalignment','left',...
                    'fontunits','normalized',...
                    'units','normalized','position',[0.0100    0.0400    0.09    0.0200],...
                    'backgroundcolor',get(h_fig,'color'));
                        

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%   average alpha interval text
 %%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 h_ave_alpha_int_text=uicontrol('parent',h_fig,'style','text',...
                    'string',ave_alpha_int_text,'horizontalalignment','left','fontsize',10,'FontWeight','bold',...
                    'fontunits','normalized',...
                    'units','normalized','position',[0.0100    0.012  0.22    0.0300],...
                    'backgroundcolor',get(h_fig,'color'));
                                                                                                      
                                                

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 
%%%%%%%%%%%   BUTTON: Plot channel locations
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_plotchanlocbutton=uicontrol('string','plot channel locations','TooltipString','Plot channel locations',...
                              'fontsize',10,'fontunits','normalized',...
                              'units','normalized','position',[0.22     0.01    0.13    0.05],'callback',@plotchanlocbutton_cb);
if  isempty(par.CRB_chanlocs),
    
    set(h_plotchanlocbutton,'enable','off');
   
end
                          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% 
%%%%%%%%%%%   BUTTON: topographic plot
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_ERDpanel=uipanel('position',[0.36 0.005 0.34 0.06],'units','normalized');

h_ERDtopoplot=uicontrol('parent',h_ERDpanel,'string','rel. power var. topoplot',...
                              'fontsize',10,'fontunits','normalized',...
                              'units','normalized','position',[0.01  0.15    0.41    0.7],'callback',@ERDtopoplot_cb);


h_textrangeERDtopoplot=uicontrol('parent',h_ERDpanel,'style','text','string','colors scale:','fontsize',10,'fontunits','normalized',...
                                 'units','normalized','position',[0.43 0.3 0.25 0.4]); 

h_editrangeERDtopoplot=uicontrol('parent',h_ERDpanel,'style','edit','fontsize',10,'fontunits','normalized',...
                                 'units','normalized','position',[0.7 0.1 0.28 0.8],'tooltipstring','Insert values separated by comma',...
                                 'callback',@editrangeERDtopoplot_cb);                          

if sum(~isnan(CRB_new.results_num(:,end)))
   
   colorrange=sprintf('%.2f, %.2f',[min(CRB_new.results_num(:,end)) max(CRB_new.results_num(:,end))]); 
   set(h_editrangeERDtopoplot,'string',colorrange);
   
else
    
   set(h_editrangeERDtopoplot,'string','NaN NaN');   
   
end

if  ~isfield(par,'CRB_chanlocs') || isempty(par.CRB_chanlocs),
    
    set(h_ERDtopoplot,'enable','off');
    set(h_editrangeERDtopoplot,'enable','off')
   
end

handles_topoplot=[];

function ERDtopoplot_cb(hObject,eventdata)
    
        h=figure;
        handles_topoplot=[handles_topoplot h];
        
        if isempty(get(h_editrangeERDtopoplot,'string')),
        
            maplimits='absmax';
           
        else
            
            maplimits=textscan(get(h_editrangeERDtopoplot,'string'),'%.2f,%.2f');
            
            if sum(cellfun(@isempty,maplimits))
                
                maplimits='absmax';
                
            else
                
                maplimits=cell2mat(maplimits);
                
            end
            
        end
        
        try
            
            topoplot(CRB_new.results_num(:,end), par.CRB_chanlocs,'maplimits',maplimits); 
            colorbar;
            
        catch
            
            delete(h);
            set(h_ERDtopoplot,'enable','off');
            set(h_editrangeERDtopoplot,'enable','off');
            
        end

end

if ~isfield(par,'CRB_chanlocs') || isempty(par.CRB_chanlocs),
    
   set(h_plotchanlocbutton,'enable','off');
   
end

function editrangeERDtopoplot_cb(hObject,eventdata)
    
         if ~isempty(handles_topoplot) && ishandle(handles_topoplot(end)),
             
             delete(handles_topoplot(end));
             handles_topoplot(end)=[];
             
         end

end
              

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%   LEGEND
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_CFlegend= uicontrol('style','text','string','CAF = channel alpha frequency',...
                         'fontsize',10,'fontweight','bold','horizontalalignment','left','fontunits','normalized',...
                         'units','normalized','position',[0.7200    0.9557    0.2700    0.0300],'BackgroundColor',get(h_fig,'color'));

h_IFlegend= uicontrol('style','text','string','IAF = individual alpha frequency',...
                         'fontsize',10,'fontweight','bold','horizontalalignment','left','fontunits','normalized',...
                         'units','normalized','position',[0.7200    0.9171    0.2700    0.0300],'BackgroundColor',get(h_fig,'color'));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%
%%%%%%%%% reference interval
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 h_refinttext= uicontrol('style','text','string','reference interval (ms)',...
                         'fontsize',10,'fontweight','bold','horizontalalignment','left','fontunits','normalized',...
                         'units','normalized','position',[0.7200    0.8756    0.1600    0.0300],'BackgroundColor',get(h_fig,'color'));
                        
 h_refintedit=uicontrol('style','edit','fontsize',10,...
                        'fontunits','normalized','units','normalized','position',[0.8700    0.8770    0.1200    0.0300],'enable','off');
                    
 set(h_refintedit,'string',sprintf('%.1f, %.1f',par.CRBpar.timeintervals.ref_int));
 
 h_testinttext= uicontrol('style','text','string','test interval (ms)',...
                         'fontsize',10,'fontweight','bold','horizontalalignment','left','fontunits','normalized',...
                         'units','normalized','position',[0.7200    0.8299    0.1600    0.0300],'BackgroundColor',get(h_fig,'color'));

 h_testintedit=uicontrol('style','edit','fontsize',10,...
                        'fontunits','normalized','units','normalized','position',[0.8700    0.8299    0.1200    0.0300],'enable','off');
                    
 set(h_testintedit,'string',sprintf('%.1f, %.1f',par.CRBpar.timeintervals.test_int));

                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% CRB parameters
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h_CRBparpanel=uipanel(h_fig,'title','CRB analysis parameters: ','fontsize',11,...
                  'units','normalized','position',[0.7200    0.3800    0.2750    0.4300],'fontunits','normalized','fontweight','bold');
            
set(h_CRBparpanel,'units','normalized');

%%%%%%%%%%
%%%%%%%%%%  STEP 1 PARAMETERS
%%%%%%%%%%
              
h_firststeptext=uicontrol(h_CRBparpanel,'style','text','string',{'step 1: localization of';'  modulation intervals'},...
                                        'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                        'units','normalized','position',[0.01 0.85 0.48 0.13]) ; 



h_wsizetext=uicontrol(h_CRBparpanel,'style','text','string','- w_{size} (Hz)',...
                      'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                      'units','normalized','position',[0.01 0.75 0.33 0.05]);  %da sostituire con annotation                     

h_wsizeedit=uicontrol(h_CRBparpanel,'style','edit',...
                                    'fontsize',8,'horizontalalignment','center','fontunits','normalized',...   
                                    'units','normalized','position',[0.35 0.74 0.12 0.07]);  %da sostituire con annotation                     


h_wshifttext=uicontrol(h_CRBparpanel,'style','text','string','- w_{shift} (Hz)',...
                                     'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                     'units','normalized','position',[0.01 0.6 0.33 0.05]);  %da sostituire con annotation                     

h_wshiftedit=uicontrol(h_CRBparpanel,'style','edit',...
                                     'fontsize',8,'horizontalalignment','center','fontunits','normalized',...
                                     'units','normalized','position',[0.35 0.59 0.12 0.07]);  %da sostituire con annotation                     


h_lambdatext=uicontrol(h_CRBparpanel,'style','text','string','- lambda ',...
                                     'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                     'units','normalized','position',[0.01 0.45 0.33 0.05]);  %da sostituire con annotation                     

h_lambdaedit=uicontrol(h_CRBparpanel,'style','edit',...
                                     'fontsize',8,'horizontalalignment','center','fontunits','normalized',... 
                                     'units','normalized','position',[0.35 0.44 0.12 0.07]);  %da sostituire con annotation                     


h_epstext=uicontrol(h_CRBparpanel,'style','text','string','- epsilon ',...
                                  'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                  'units','normalized','position',[0.01 0.3 0.33 0.05]);  %da sostituire con annotation                     

h_epsedit=uicontrol(h_CRBparpanel,'style','edit',...
                                  'fontsize',8,'horizontalalignment','center','fontunits','normalized',...
                                  'units','normalized','position',[0.35 0.29 0.12 0.07]);  %da sostituire con annotation                     


%%%%%%%%%%
%%%%%%%%%%  STEP 2 PARAMETERS
%%%%%%%%%%
               

h_secondsteptext=uicontrol(h_CRBparpanel,'style','text','string',{'step 2: selection of';'data for IAF computation'},...
                                         'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                         'units','normalized','position',[0.51 0.85 0.49 0.13]) ;


h_rhomintext=uicontrol(h_CRBparpanel,'style','text','string',{'- rho_{min}';['(' rho_unit_str ')']},...
                                     'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                     'units','normalized','position',[0.52 0.71 0.33 0.12]);   %da sostituire con annotation                     
                                 
h_rhominedit=uicontrol(h_CRBparpanel,'style','edit',...
                                     'fontsize',8,'horizontalalignment','center','fontunits','normalized',...
                                     'units','normalized','position',[0.86 0.74 0.12 0.07]); [0.35 0.79 0.1 0.07]  %da sostituire con annotation                     

             
h_rtext=uicontrol(h_CRBparpanel,'style','text','string','- r',...
                                'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                'units','normalized','position',[0.56 0.6 0.3 0.05]);  %da sostituire con annotation                     

h_redit=uicontrol(h_CRBparpanel,'style','edit',...
                                'fontsize',8,'horizontalalignment','center','fontunits','normalized',...
                                'units','normalized','position',[0.86 0.59 0.12 0.07]);  %da sostituire con annotation                     

             
h_ptext=uicontrol(h_CRBparpanel,'style','text','string',{'- p'},...
                                'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                'units','normalized','position',[0.56 0.45 0.3 0.06]);  %da sostituire con annotation     
                            
h_pedit=uicontrol(h_CRBparpanel,'style','edit',...
                                'fontsize',8,'horizontalalignment','center','fontunits','normalized',... 
                                'units','normalized','position',[0.86 0.44 0.12 0.07]);  %da sostituire con annotation      
                            
h_rhosubtext=uicontrol('parent',h_CRBparpanel,'style','text',...
            'string',rhosubtext,'fontsize',10,...
            'horizontalalignment','left','fontunits','normalized',...
            'units','normalized','position',[0.56   0.25   0.4   0.15]);
        

%%%%%%%%% additional parameters

h_addparamtext=uicontrol(h_CRBparpanel,'style','text','string','additional optional parameters (''keyName'',keyValue)',...
                                        'fontsize',10,'horizontalalignment','left','fontunits','normalized',...
                                         'units','normalized','position',[0.01 0.1 0.8 0.13]);
                                       

h_addparamedit=uicontrol(h_CRBparpanel,'style','edit',...
                                       'fontsize',8,'horizontalalignment','center','fontunits','normalized',...
                                       'units','normalized','position',[0.02    0.01    0.4500    0.08]);                               
                        

%%%%%%%%% CRB parameters initialization

set(h_wsizeedit,'string',sprintf('%.2f',par.CRBpar.algpar.w_size),'fontunits','normalized');
set(h_wshiftedit,'string',sprintf('%.2f',par.CRBpar.algpar.w_shift),'fontunits','normalized');
set(h_lambdaedit,'string',sprintf('%.2f',par.CRBpar.algpar.lambda),'fontunits','normalized');
set(h_epsedit,'string',sprintf('%.2f',par.CRBpar.algpar.epsilon),'fontunits','normalized');
set(h_rhominedit,'string',sprintf('%.2f',par.CRBpar.algpar.rho_min),'fontunits','normalized');
set(h_redit,'string',sprintf('%.2f',par.CRBpar.algpar.r),'fontunits','normalized');
set(h_pedit,'string',sprintf('%.2f',par.CRBpar.algpar.p),'fontunits','normalized');                                   
                                   
addparameters=par.CRBpar.algpar.addparameters;
addparameters_str_ini=[];
parvalue=[];

for i_par=1:length(addparameters),
    
    addparameter=addparameters{i_par};
    
    if isfield(par.CRBpar.algpar,addparameter),
       
       eval(['parvalue=par.CRBpar.algpar.' addparameter ';'])
       
       if ~isempty(parvalue),
           
          if ismember(addparameter,{'lambda_left','epsilon_left'}),
              
              addparameters_str_ini=[addparameters_str_ini '''' addparameter ''',''' num2str(parvalue) '''; '];
              
          end
          
          if ismember(addparameter,{'scan_interval','alpha_interval'}),
              
              addparameters_str_ini=[addparameters_str_ini '''' addparameter ''',''' sprintf('%.2f,%.2f',parvalue) '''; '];
              
          end
           
       end
       
    end
    
    
end

set(h_addparamedit,'string',addparameters_str_ini);    


                                   
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%
 %%%%%%%%%% BUTTON: Recompute with new parameters values
 %%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 h_recomputewithnewparvaluesbut=uicontrol('string','recompute with new parameter values',...
                              'fontsize',10,'fontunits','normalized',...
                              'units','normalized','position',[0.7200    0.3214    0.2700    0.0500],'callback',@recomputewithnewparvaluesbut_cb);
                          
 if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
    set(h_recomputewithnewparvaluesbut,'enable','off')
 end     
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%
 %%%%%%%%%% BUTTON: Recompute with new table values
 %%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 h_recomputewithnewtablevalues=uicontrol('string','recompute with new table values',...
                              'fontsize',10,'fontunits','normalized',...
                              'units','normalized','position',[0.7200    0.2656    0.2700    0.0500],...
                              'callback',@recomputewithnewtablevalues_cb);
                          
 f_handle=@recomputewithnewtablevalues_cb;
 
 if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
    set(h_recomputewithnewtablevalues,'enable','off')
 end                         
                          
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%
 %%%%%%%%%% PANEL: Spectra plot settings
 %%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
 h_plotspectrapanel=uipanel('position',[0.7200    0.0726    0.2700    0.1728],...
                            'fontsize',10,'title','Spectra plot settings','fontunits','normalized',...
                            'BackgroundColor',get(h_fig,'color'));
 
 if par.typeproc==1,
    
     str_plotspectra='select channels to plot';
     
 else
     
     str_plotspectra='select components to plot';
     
 end
 
 
h_selectspectratoplotbutton=uicontrol('parent',h_plotspectrapanel,'fontsize',10,'string',str_plotspectra,...
                                       'fontunits','normalized','units','normalized','position',[0.01 0.6 0.65 0.3],...
                                       'callback',@selectspectratoplotbutton_cb);

if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
    set(h_selectspectratoplotbutton,'enable','off')
end

data_list=rownames;


if ~isempty(par.plotspar.indexes),
    
    selected_indexes=par.plotspar.indexes;
    
else
    
    selected_indexes=1:length(data_list);
    par.plotspar.indexes=selected_indexes;
    
end

par.plotspar.labels=data_list(selected_indexes);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%  BUTTON: PLOT SPECTRA
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
h_plotspectrabutton=uicontrol('parent',h_plotspectrapanel,'fontsize',10,'fontunits','normalized',...
                           'string','plot spectra','units','normalized','position',[0.7 0.6 0.29 0.3],...
                           'callback',@plotspectrabutton_cb);
                       
if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
    set(h_plotspectrabutton,'enable','off')
end

h_plotfreqrangetext=uicontrol('parent',h_plotspectrapanel,'style','text',...
                           'fontsize',10,'string','frequency range to plot (Hz)','fontunits','normalized',...
                           'units','normalized','position',[0.05 0.16 0.5 0.3],...
                           'backgroundcolor',get(h_plotspectrapanel,'backgroundcolor'));                            

h_plotfreqrangeedit=uicontrol('parent',h_plotspectrapanel,'style','edit','fontsize',10,'units','normalized',...
                           'position',[0.61 0.15 0.33 0.3],'callback',@plotfreqrangeedit_cb);
 
if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
    set(h_plotfreqrangeedit,'enable','off')
end
%%%%%%%%%%%% "Frequency range to plot" initialization

set(h_plotfreqrangeedit,'string', sprintf('%.2f,%.2f',par.plotspar.freq_range));

 


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%  BUTTON:  RESTORE INITIAL VALUES
 %%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 h_restorevaluesbut=uicontrol('fontsize',10,'string','restore initial values',...
                              'fontunits','normalized','units','normalized',...
                              'position',[0.71 0.01 0.12 0.05],'callback',@restorevaluesbut_cb);       



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%
 %%%%%%%%%% BUTTON: Save results
 %%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 h_saveresultsbut=uicontrol('string','save results',...
                              'fontsize',10,'fontunits','normalized',...
                              'units','normalized','position',[0.835    0.01   0.08    0.0500],'callback',@saveresultsbut_cb);
                                     
                        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%  BUTTON: CANCEL
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
h_cancelbut=uicontrol('fontsize',10,'string','cancel',...
                   'fontunits','normalized','units','normalized','position',[0.92    0.01   0.07   0.05],'callback',@cancelbut_cb);              

               
%%% launching plotresults_gui() in case "include spectra plots" was checked in the GUI for initial settings %

if  par.spectraplots==1,   
    
         if ~isfield(CRB,'spectra') || isempty(CRB.spectra),
             
             error('''Spectra'' field of ''CRB'' needed for plotting results')
             
         end
         
         freq_range=par.plotspar.freq_range;
         f=CRB.spectra.f;
         
         if freq_range(1)<freq_range(2) && ~isempty( intersect( find(f>=freq_range(1)) , find(f<=freq_range(2)) ) ) 
             
            spectra_plot.f=f;
            spectra_plot.ave_refspectra=CRB.spectra.ave_refspectra(par.plotspar.indexes,:);
            spectra_plot.ave_testspectra=CRB.spectra.ave_testspectra(par.plotspar.indexes,:);  
            
            if ~isempty(par.CRB_chanlocs),
                
                par.plotspar.chanlocs=par.CRB_chanlocs(par.plotspar.indexes); 
                
            else
                
                par.plotspar.chanlocs=[];
                 
            end
            
            par.plotspar.typeproc=par.typeproc;
            
            spectra_plot.par=par.plotspar;
            spectra_plot.par.CFcomp=par.CRBpar.algpar.CFcomp;
            
            spectra_fig_handles=[spectra_fig_handles plotresults_gui(spectra_plot,CRB_new.results,h_table,f_handle)];

         else
             
             error('frequency range for plotting not well defined')
             
         end
    
end


%%%%%%%%% SPECTRA plot settings
%%%%%%%%%

uiwait(h_fig)

if cancel_flag==1 || close_flag==1,
     
    return;
    
else

   delete(h_fig)
     
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%     CALLBACKS    
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CloseRequestFcn(hObject,eventdata),

        close_flag=1;
        
        if ~isempty(spectra_fig_handles),

            for i_fig=1:length(spectra_fig_handles),

                if ishandle(spectra_fig_handles{i_fig}),

                    delete(spectra_fig_handles{i_fig});

                end

            end

        end   
        
        CRB_new=[];
        delete(h_fig);
       

end


%%%%%%%%% RESTORE INITIAL VALUES

function restorevaluesbut_cb(hObject,eventdata),
    
    
    if ~isempty(spectra_fig_handles),
        
        for i_fig=1:length(spectra_fig_handles),
            
            if ishandle(spectra_fig_handles{i_fig}),
                
                delete(spectra_fig_handles{i_fig});
                
            end
            
        end
        
    end
    
    spectra_fig_handles={};
    
    set(h_table,'data',datamatrix);
    set(h_IAFtext,'string',IAFtext);
    set(h_ave_alpha_int_text,'string',ave_alpha_int_text);
    
    set(h_wsizeedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.w_size),'fontunits','normalized');
    set(h_wshiftedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.w_shift),'fontunits','normalized');
    set(h_lambdaedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.lambda),'fontunits','normalized');
    set(h_epsedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.epsilon),'fontunits','normalized');
    set(h_rhominedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.rho_min),'fontunits','normalized');
    set(h_redit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.r),'fontunits','normalized');
    set(h_pedit,'string',sprintf('%.2f',par_ini.CRBpar.algpar.p),'fontunits','normalized');  
    
    set(h_addparamedit,'string',addparameters_str_ini);    
    set(h_rhosubtext,'string',rhosubtext);
    
    CRB_new=CRB;
    
    if sum(~isnan(CRB_new.results_num(:,end)))

           colorrange=sprintf('%.2f, %.2f',[min(CRB_new.results_num(:,end)) max(CRB_new.results_num(:,end))]); 
           set(h_editrangeERDtopoplot,'string',colorrange);

    else

           set(h_editrangeERDtopoplot,'string','NaN NaN');   

    end   

    if isfield(par, 'CRB_chanlocs') && ~isempty(par.CRB_chanlocs),

           set(h_editrangeERDtopoplot,'enable','on')
           set(h_ERDtopoplot,'enable','on')

    end
       
    
end


%%%%%%%%% PLOT CHANNEL LOCATIONS

function plotchanlocbutton_cb(hObject,eventdata),
    
        try
            
           h=figure;        
           topoplot([],par.CRB_chanlocs, 'style', 'blank',  'electrodes', 'labelpoint');
           
        catch err
            
            delete(h);
            set(hObject,'enable','off');
            
        end
        
end



%%%%%%%%  RECOMPUTE WITH NEW PARAMETERS VALUES BUTTON

function recomputewithnewparvaluesbut_cb(hObject,eventdata)  
    
    if ~isempty(spectra_fig_handles),
        
        for i_fig=1:length(spectra_fig_handles),
            
            if ishandle(spectra_fig_handles{i_fig}),
                
                delete(spectra_fig_handles{i_fig});
                
            end
            
        end
        
    end
    
    spectra_fig_handles={};    
    
    par.CRBpar.onlystepone=0;
    
    %%%%%%%%%% CRB parameters
     
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
        
   par.CRBpar.spectraldata=1;
   par.CRBpar.customanalysis=0;
   par.CRBpar.algpar.CFcomp=par_ini.CRBpar.algpar.CFcomp;
   par.CRBpar=CRBanalysis_parcheck(par.CRBpar);
   
   data{1}=CRB.spectra.ave_refspectra;
   data{2}=CRB.spectra.ave_testspectra;
   
   display(['Recomputing... wait... '])
   
   CRB_new=CRBanalysis(data,par.CRBpar);
   
   display('Done.')
   
   IAF_new=CRB_new.results_num(1,1);
   ave_alpha_int_new=[mean(CRB_new.results_num(CRB_new.results_num(:,2)==1,5)) mean(CRB_new.results_num(CRB_new.results_num(:,2)==1,6))];
   datamatrix_new=CRB_new.results_num(:,2:end);
   IAFtext_new=['IAF = ' sprintf('%.1f',IAF_new) ' Hz'];
   ave_alpha_int_text_new=['ave alpha interval=' sprintf('[%.1f %.1f]',ave_alpha_int_new) 'Hz']; 
   
   set(h_table,'data',datamatrix_new);
   set(h_IAFtext,'string',IAFtext_new);
   set(h_ave_alpha_int_text,'string',ave_alpha_int_text_new);
   
   set(h_wsizeedit,'string',sprintf('%.2f',par.CRBpar.algpar.w_size),'fontunits','normalized');
   set(h_wshiftedit,'string',sprintf('%.2f',par.CRBpar.algpar.w_shift),'fontunits','normalized');
   set(h_lambdaedit,'string',sprintf('%.2f',par.CRBpar.algpar.lambda),'fontunits','normalized');
   set(h_epsedit,'string',sprintf('%.2f',par.CRBpar.algpar.epsilon),'fontunits','normalized');
   set(h_rhominedit,'string',sprintf('%.2f',par.CRBpar.algpar.rho_min),'fontunits','normalized');
   set(h_redit,'string',sprintf('%.2f',par.CRBpar.algpar.r),'fontunits','normalized');
   set(h_pedit,'string',sprintf('%.2f',par.CRBpar.algpar.p),'fontunits','normalized');                                   

   addparameters=par.CRBpar.algpar.addparameters;
   addparameters_str=[];
   parvalue=[];

   for i_par=1:length(addparameters),

        addparameter=addparameters{i_par};

       if isfield(par.CRBpar.algpar,addparameter),

           eval(['parvalue=par.CRBpar.algpar.' addparameter ';'])

           if ~isempty(parvalue),

              if ismember(addparameter,{'lambda_left','epsilon_left'}),

                  addparameters_str=[addparameters_str '''' addparameter ''',''' num2str(parvalue) '''; '];

              end

              if ismember(addparameter,{'scan_interval','alpha_interval'}),

                  addparameters_str=[addparameters_str '''' addparameter ''',''' sprintf('%.2f,%.2f',parvalue) '''; '];

              end

           end

       end


   end

   set(h_addparamedit,'string',addparameters_str);    
   
   if isfield(CRB_new,'L') && isfield(CRB_new.L,'rho_sub'),

         rhosubtext_new=['rho_sub = ' sprintf('%.3f',CRB_new.L.rho_sub) rho_unit_str];

   else

         rhosubtext_new=['rho_sub = NaN' rho_unit_str];

   end
   
   set(h_rhosubtext,'string',rhosubtext_new);
   
   if sum(~isnan(CRB_new.results_num(:,end)))

       colorrange=sprintf('%.2f, %.2f',[min(CRB_new.results_num(:,end)) max(CRB_new.results_num(:,end))]); 
       set(h_editrangeERDtopoplot,'string',colorrange);

   else

       set(h_editrangeERDtopoplot,'string','NaN NaN');   

   end   
      
   if isfield(par, 'CRB_chanlocs') && ~isempty(par.CRB_chanlocs),
       
       set(h_editrangeERDtopoplot,'enable','on')
       set(h_ERDtopoplot,'enable','on')
       
   end
   
   
end



%%%%%%%% "RECOMPUTE WITH NEW TABLE VALUES" BUTTON

function recomputewithnewtablevalues_cb(~,~)
    
        if ~isempty(spectra_fig_handles),

            for i_fig=1:length(spectra_fig_handles),

                if ishandle(spectra_fig_handles{i_fig}),

                    delete(spectra_fig_handles{i_fig});

                end

            end

         end

         spectra_fig_handles={};    
             
         data{1}=CRB.spectra.ave_refspectra;
         data{2}=CRB.spectra.ave_testspectra;         

         datamatrix_new=get(h_table,'data');                     
              
         par.CRBpar.spectraldata=1;
         par.CRBpar.customanalysis=1;
         par.CRBpar.custom.selection_flags=datamatrix_new(:,1);
         par.CRBpar.custom.bands=datamatrix_new(:,[4 5]);         
         par.CRBpar=CRBanalysis_parcheck(par.CRBpar);
         
         try

            display(['Recomputing... wait... '])
            [CRB_new]=CRBanalysis(data,par.CRBpar);            
            display('Done.')   
            IAF_new=CRB_new.results_num(1,1);
            ave_alpha_int_new=[mean(CRB_new.results_num(CRB_new.results_num(:,2)==1,5)) mean(CRB_new.results_num(CRB_new.results_num(:,2)==1,6))];
            datamatrix_new=CRB_new.results_num(:,2:end);
            IAFtext_new=['IAF = ' sprintf('%.1f',IAF_new) ' Hz'];
            ave_alpha_int_text_new=['ave alpha interval=' sprintf('[%.1f %.1f]',ave_alpha_int_new) 'Hz']; 
            set(h_table,'data',datamatrix_new);
            set(h_IAFtext,'string',IAFtext_new)  
            set(h_ave_alpha_int_text,'string',ave_alpha_int_text_new);
            
           if sum(~isnan(CRB_new.results_num(:,end)))

               colorrange=sprintf('%.2f, %.2f',[min(CRB_new.results_num(:,end)) max(CRB_new.results_num(:,end))]); 
               set(h_editrangeERDtopoplot,'string',colorrange);

           else

               set(h_editrangeERDtopoplot,'string','NaN NaN');   

           end   

           if isfield(par, 'CRB_chanlocs') && ~isempty(par.CRB_chanlocs),

               set(h_editrangeERDtopoplot,'enable','on')
               set(h_ERDtopoplot,'enable','on')

           end
               
            
         catch err

            display('Error:')
            display(err.message)
            display('Restoring initial values...')
            restorevaluesbut_cb();
            display('Done')

         end
                                                
end



%%%%%%%% "SELECT SPECTRA TO PLOT" BUTTON

function selectspectratoplotbutton_cb(hObject,eventdata),
              
         [selected_indexes_new ok]=listdlg('ListString',data_list,'InitialValue',selected_indexes);
         
         if ok,
             
            selected_indexes=selected_indexes_new;
            par.plotspar.indexes=selected_indexes; 
            par.plotspar.labels=data_list(selected_indexes);
            
         end

end


%%%%%%%%%%%%%%% "FREQUENCY RANGE TO PLOT" EDIT

function plotfreqrangeedit_cb(hObject,eventdata)
    
         if ~isempty(get(hObject,'string'))
          
             freq_range=sscanf(get(hObject,'string'),'%f, %f');
             
         else
             
             freq_range=[];
             
         end
         
         if ~isempty(freq_range),
             
             par.plotspar.freq_range=freq_range;
                          
         else
             
             set(hObject,'string',sprintf('%.2f,%.2f',par.CRBpar.spectrapar.freq_lim));
             par.plotspar.freq_range=par.CRBpar.spectrapar.freq_lim;
             
         end

end


%%%%%%%%%% "PLOT SPECTRA" BUTTON

function plotspectrabutton_cb(hObject,eventdata) 
    
         par.spectraplots=1;         
         
         freq_range=par.plotspar.freq_range;
         f=CRB.spectra.f;
         
         if freq_range(1)<freq_range(2) && ~isempty( intersect( find(f>=freq_range(1)) , find(f<=freq_range(2)) ) ) 
             
            spectra_plot.f=f;
            spectra_plot.ave_refspectra=CRB.spectra.ave_refspectra(par.plotspar.indexes,:);
            spectra_plot.ave_testspectra=CRB.spectra.ave_testspectra(par.plotspar.indexes,:);  
            
            if ~isempty(par.CRB_chanlocs),
                
                par.plotspar.chanlocs=par.CRB_chanlocs(par.plotspar.indexes); 
                
            else
                
                par.plotspar.chanlocs=[];
                 
            end
            
            par.plotspar.typeproc=par.typeproc;
            
            spectra_plot.par=par.plotspar;
            spectra_plot.par.CFcomp=par.CRBpar.algpar.CFcomp;
            
            spectra_fig_handles=[spectra_fig_handles plotresults_gui(spectra_plot,CRB_new.results,h_table,f_handle)];

         else
             
             error('Frequency range for plotting not well defined')
             
         end           
         
      
end

%%%%%%%%%%%% "SAVE RESULTS" BUTTON

function saveresultsbut_cb(hObject,eventdata)
    
         if ~isempty(spectra_fig_handles),

            for i_fig=1:length(spectra_fig_handles),

                if ishandle(spectra_fig_handles{i_fig}),

                    delete(spectra_fig_handles{i_fig});

                end

            end

         end

         spectra_fig_handles={};    
 
         CRB_new.spectra=CRB.spectra;
         CRB_new.par=par;
          
         uiresume(h_fig)
        
end

%%%%%%%%%%%% "CANCEL" BUTTON

function cancelbut_cb(hObject,eventdata)
    
    cancel_flag=1;
        
    if ~isempty(spectra_fig_handles),
        
        for i_fig=1:length(spectra_fig_handles),
            
            if ishandle(spectra_fig_handles{i_fig}),
                
                delete(spectra_fig_handles{i_fig});
                
            end
            
        end
        
    end
    

    CRB_new=[];
    delete(h_fig);
 
end

end