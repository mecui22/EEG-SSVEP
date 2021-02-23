% saveresults_gui() - displays an interactive window for defining saving settings 
%
% Usage:
%   >>  par=saveresults_gui();
%
% Inputs:   
%   
%    
% Outputs:
%   par  - parameters struct with saving settings
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

function par=saveresults_gui()

h_fig=figure('position',[0 0 700 400],'units','normalize','menubar','none','toolbar','none',...
            'numberTitle','off','name',[mfilename '()'],'units','normalized','CloseRequestFcn',@CloseRequestFcn);

movegui(h_fig,'center'); 

h_text=uicontrol('style','text','fontsize',12,'fontweight','bold','horizontalalignment','left',...
                'string','Saving options:','fontunits','normalized',...
                'units','normalized','position',[0.0317    0.9325    0.2000    0.0500],...
                 'backgroundcolor',get(h_fig,'color'));                                

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%   HELP  BUTTON
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_helpbut=uicontrol('fontsize',10,'string','Help','fontunits','normalized',...
                'units','normalized','position',[0.8000    0.9025    0.1500    0.0700],...
                'callback',@helpbut_cb,'visible','off');            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
%%%%%  TEXT OPTION
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_txtcheckbox=uicontrol('style','checkbox','fontsize',10,...
                       'string','save results in a .txt file','fontunits','normalized',...
                       'units','normalized','position',[0.0833    0.8425    0.2500    0.0500] ,...
                       'backgroundcolor',get(h_fig,'color'),'value',0,...
                       'callback',@txtcheckbox_cb);

h_txtfilenametext=uicontrol('style','text','fontsize',10,'horizontalalignment','left',...
                           'string','insert file name',...
                           'units','normalized','position',[0.1200    0.7525    0.1500    0.0525],...
                           'backgroundcolor',get(h_fig,'color'));

h_txtfilenameedit=uicontrol('style','edit','fontsize',10,...
                            'fontunits','normalized',...
                            'units','normalized','position',[ 0.2586    0.7575    0.2000    0.050]);                        

h_txtfilepathtext=uicontrol('style','text','fontsize',10,'horizontalalignment','left',...
                           'string','insert filepath',...
                           'units','normalized','position',[0.5088    0.7475    0.12    0.0525],...
                           'backgroundcolor',get(h_fig,'color'));

h_txtfilepathedit=uicontrol('style','edit','fontsize',10,...
                            'fontunits','normalized',...
                            'units','normalized','position',[0.6319    0.7500    0.2500    0.0500],...
                            'TooltipString','Leave empty in case of current directory');  

h_txtbrowsebut=uicontrol('fontsize',10,'string','browse','fontunits','normalized',...
                              'units','normalized','position',[ 0.9000    0.7475    0.0900    0.0500],...
                              'callback',@browsebut_cb,'userdata',h_txtfilepathedit);     

set([h_txtfilenametext h_txtfilenameedit h_txtfilepathtext h_txtfilepathedit h_txtbrowsebut],'enable','off'); 


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
%%%%%  MAT OPTION
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

h_matcheckbox=uicontrol('style','checkbox','fontsize',10,...
                       'string','save results as a CRB struct in a .mat file','fontunits','normalized',...
                       'units','normalized','position',[0.0833    0.6200    0.4    0.0500] ,...
                       'backgroundcolor',get(h_fig,'color'),'value',0,...
                       'callback',@matcheckbox_cb);

h_matfilenametext=uicontrol('style','text','fontsize',10,'horizontalalignment','left',...
                           'string','insert file name',...
                           'units','normalized','position',[0.1200    0.5400    0.1500    0.0525],...
                           'backgroundcolor',get(h_fig,'color'));

h_matfilenameedit=uicontrol('style','edit','fontsize',10,...
                            'fontunits','normalized',...
                            'units','normalized','position',[0.2586    0.5425    0.2000    0.0500]);                        

h_matfilepathtext=uicontrol('style','text','fontsize',10,'horizontalalignment','left',...
                           'string','insert filepath',...
                           'units','normalized','position',[0.5088    0.5400    0.1500    0.0525],...
                           'backgroundcolor',get(h_fig,'color'));

h_matfilepathedit=uicontrol('style','edit','fontsize',10,...
                            'fontunits','normalized',...
                            'units','normalized','position',[0.6319    0.5425    0.2500    0.0500],...
                            'TooltipString','Leave empty in case of current directory');  

h_matbrowsebutt=uicontrol('fontsize',10,'string','browse','fontunits','normalized',...
                              'units','normalized','position',[ 0.9000    0.5425    0.0900    0.0500],...
                              'callback',@browsebut_cb,'userdata',h_matfilepathedit);   

h_includeavespectramat=uicontrol('style','checkbox','fontsize',10,...
                       'string','include average spectra','fontunits','normalized',...
                       'units','normalized','position',[0.1819    0.4650    0.2500    0.0500] ,...
                       'backgroundcolor',get(h_fig,'color'),'value',0);                              

% h_includestspectramat=uicontrol('style','checkbox','fontsize',10,...
%                        'string','include single trial spectra','fontunits','normalized',...
%                        'units','normalized','position',[0.1819    0.3850    0.2500    0.0500] ,...
%                        'backgroundcolor',get(h_fig,'color'),'value',0,'enable','off');   

set([h_matfilenametext h_matfilenameedit h_matfilepathtext h_matfilepathedit h_matbrowsebutt],'enable','off'); 
set([h_includeavespectramat],'enable','off');


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
%%%%%  CRB FIELD OPTION
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

h_fieldcheckbox=uicontrol('style','checkbox','fontsize',10,...
                       'string','save reults in the CRB field of the EEG struct','fontunits','normalized',...
                       'units','normalized','position',[0.0833    0.2725    0.4    0.0500] ,...
                       'backgroundcolor',get(h_fig,'color'),'value',1,...
                       'callback',@checkboxfield_cb);                         

h_includeavespectrafield=uicontrol('style','checkbox','fontsize',10,...
                       'string','include average spectra','fontunits','normalized',...
                       'units','normalized','position',[0.1819    0.1725    0.2500    0.0500] ,...
                       'backgroundcolor',get(h_fig,'color'),'value',0);                                                            

% h_includestspectrafield=uicontrol('style','checkbox','fontsize',10,...
%                        'string','include single trial spectra','fontunits','normalized',...
%                        'units','normalized','position',[0.1819    0.0800    0.2500    0.0500] ,...
%                        'backgroundcolor',get(h_fig,'color'),'value',0,'enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%% SAVE BUTTON
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_savebut=uicontrol('fontsize',10,'string','Save','fontunits','normalized',...
                    'units','normalized','position',[0.8000    0.1450    0.1500    0.0700],...
                    'callback',@savebut_cb);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%% CANCEL BUTTON
%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h_cancelbut=uicontrol('fontsize',10,'string','Cancel','fontunits','normalized',...
                    'units','normalized','position',[ 0.8000    0.0525    0.1500    0.0700],...
                    'callback',@cancelbut_cb);
                                                                                                                                  
close_flag=0;
cancel_flag=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uiwait(h_fig)


if cancel_flag==1 || close_flag==1;

   return;
    
end

%%%%%%%%%%%%%%%%   TXT

par.txt=get(h_txtcheckbox,'value');
par.txtpar.filename=get(h_txtfilenameedit,'string');

if ~isempty(get(h_txtfilepathedit,'string')),
   par.txtpar.filepath=get(h_txtfilepathedit,'string');
else
   par.txtpar.filepath='.';
end

%%%%%%%%%%%%%%%%   MAT

par.mat=get(h_matcheckbox,'value');
par.matpar.filename=get(h_matfilenameedit,'string');

if ~isempty(get(h_matfilepathedit,'string')),
   par.matpar.filepath=get(h_matfilepathedit,'string');
else
   par.matpar.filepath='.';
end

par.matpar.includeavespectra=get(h_includeavespectramat,'value');
par.matpar.includestspectra=0;


%%%%%%%%%%%%%%%%   FIELD

par.CRBfield=get(h_fieldcheckbox,'value');
par.CRBfieldpar.includeavespectra=get(h_includeavespectrafield,'value');
par.CRBfieldpar.includestspectra=0;

delete(h_fig)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%      CloseRequestFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
function CloseRequestFcn(hObject,eventdata)
         close_flag=1;
         par=[];
         delete(h_fig);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  CALLBACKS
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function helpbut_cb(hObject,eventdata)
    
         %%% work in progress

end
  
function txtcheckbox_cb(hObject,eventdata)

         if get(hObject,'value'),

            set(h_txtfilenametext,'enable','on'); 
            set(h_txtfilenameedit,'enable','on'); 

            set(h_txtfilepathtext,'enable','on'); 
            set(h_txtfilepathedit,'enable','on'); 

            set(h_txtbrowsebut,'enable','on');

         else

            set(h_txtfilenametext,'enable','off'); 
            set(h_txtfilenameedit,'enable','off'); 

            set(h_txtfilepathtext,'enable','off'); 
            set(h_txtfilepathedit,'enable','off'); 

            set(h_txtbrowsebut,'enable','off');


         end

end
                       
       
function browsebut_cb(hObject,eventdata)

          filepath=uigetdir();
          
          if ischar(filepath),
             edit_handle=get(hObject,'userdata');          
             set(edit_handle,'string',filepath);
          end

end


function matcheckbox_cb(hObject,eventdata)

         if get(hObject,'value'),

            set(h_matfilenametext,'enable','on'); 
            set(h_matfilenameedit,'enable','on'); 
            set(h_matfilepathtext,'enable','on'); 
            set(h_matfilepathedit,'enable','on');                 
            set(h_matbrowsebutt,'enable','on');

            set(h_includeavespectramat,'enable','on');
            %set(h_includestspectramat,'enable','on');

         else

            set(h_matfilenametext,'enable','off'); 
            set(h_matfilenameedit,'enable','off'); 
            set(h_matfilepathtext,'enable','off'); 
            set(h_matfilepathedit,'enable','off');                
            set(h_matbrowsebutt,'enable','off');

            set(h_includeavespectramat,'enable','off');
            %set(h_includestspectramat,'enable','off');

         end

end



function  checkboxfield_cb(hObject,eventdata)
    
             if get(hObject,'value'),
                 
                set(h_includeavespectrafield,'enable','on');
                %set(h_includestspectrafield,'enable','on');
                
             else
                 
                set(h_includeavespectrafield,'enable','off');
                %set(h_includestspectrafield,'enable','off');
                                  
             end         
            
end


function savebut_cb(hObject,eventdata),

          uiresume(h_fig);

end
   
function cancelbut_cb(hObject,eventdata),

          cancel_flag=1; 
          par=[];
          delete(h_fig);
          
end
   

end