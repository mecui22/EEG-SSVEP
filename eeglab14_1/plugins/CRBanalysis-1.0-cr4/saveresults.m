% saveresults() - saves CRB results 
%
% Usage:
%   >>  EEG=saveresults(EEG,CRB,savepar)
%
% Inputs:   
%    EEG - struct - NEEDED  if savepar.CRBfield==1; otherwise empty - eeglab data struct
%    CRB - struct - NEEDED - first output of CRBanalysis() with the second output of CRBanalysis() as its field 'spectra'  %
%    savepar - struct - NEEDED - structure with saving settings; see pop_CRBanalysis() help
%    
% Outputs:
%   EEG  - eeglab struct with results in the new field 'CRB' if par.savepar.CRBfield==1
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

function EEG=saveresults(EEG,CRB,savepar)                                   
             
         if isfield(CRB,'spectra')
             
             spectraCRB=CRB.spectra;
             CRB=rmfield(CRB,'spectra');
             
         else
             spectra=[];
         end
         
         if isfield(CRB,'par')
             
             par=CRB.par;
             CRB=rmfield(CRB,'par');
         else
             
             par=[];
             
         end
         
         if nargin<3,         
             savepar=saveresults_gui();
         end
         
         savepar=saveresults_parcheck(savepar);
                
         %%%%%%%%%% TXT option
         
         if savepar.txt==1,
                          
                   filename=savepar.txtpar.filename;

                   if isempty(find(isstrprop(filename,'punct')==1,1)),

                       filename=[filename '.txt'];

                   end

                   filepath=savepar.txtpar.filepath;
                   fid=fopen(fullfile(filepath,filename),'w');
                   
                   if isfield(CRB,'results') && ~isempty(CRB.results)
                       
                       format_str_title='%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';
                       format_str_res ='%s\t %.1f\t %d\t %.1f\t %.3f\t %.1f\t %.1f\t %.2f\t %.2f\t %.1f\n';
                       fprintf(fid,format_str_title,CRB.results{1,:});

                       for i_results=2:size(CRB.results,1),

                           fprintf(fid,format_str_res,CRB.results{i_results,:});

                       end
                       pause(1);
                   
                   end
         
                   st=fclose(fid);
             
         end
         
         
         %%%%%% MAT option
         
         if savepar.mat==1,
             

             filepath=savepar.matpar.filepath;
             filename=savepar.matpar.filename;
             
             if isempty(find(isstrprop(filename,'punct')==1,1)),

                 filename=[filename '.mat'];

             end
                       
             if savepar.matpar.includeavespectra==1 || savepar.matpar.includestspectra==1,
                 
                 spectra=spectraCRB;
                 
                 if savepar.matpar.includeavespectra==0,
                    
                     if isfield(spectra,'ave_refspectra'),
                        spectra=rmfield(spectra,'ave_refspectra');
                     end
                     
                     if isfield(spectra,'ave_testspectra'),
                        spectra=rmfield(spectra,'ave_testspectra');
                     end
                     
                 end
                 
                 
                 if savepar.matpar.includestspectra==0,
                    
                     if isfield(spectra,'singletrial_refspectra'),
                        spectra=rmfield(spectra,'singletrial_refspectra');
                     end
                     
                     if isfield(spectra,'singletrial_testspectra'),
                        spectra=rmfield(spectra,'singletrial_testspectra');
                     end
                     
                 end                                                   
                 
                 if (~isfield(spectra,'singletrial_refspectra') || ~isfield(spectra,'singletrial_testspectra')) && savepar.matpar.includestspectra==1,
                    warning('Single trial spectra not saved in the mat file. Set ''singletrialspectra'' field of ''par.CRBpar'' to 1 for saving single trial spectra') 
                 end
                 
                 CRB.spectra=spectra;
                 CRB.par=par;
                 
                 save(fullfile(filepath,filename),'CRB')
                                    
             else 
                 
                 CRB.par=par;
                 save(fullfile(filepath,filename),'CRB')        
                                  
             end
                 
        end
                 
        %%%%%% CRB field option    
             
         if savepar.CRBfield==1,             
                       
             if savepar.CRBfieldpar.includeavespectra==1 || savepar.CRBfieldpar.includestspectra==1,
                 
                 spectra=spectraCRB;
                 
                 if savepar.CRBfieldpar.includeavespectra==0,
                    
                     if isfield(spectra,'ave_refspectra'),
                        spectra=rmfield(spectra,'ave_refspectra');
                     end
                     
                     if isfield(spectra,'ave_testspectra'),
                        spectra=rmfield(spectra,'ave_testspectra');
                     end
                     
                 end
                                  
                 if savepar.CRBfieldpar.includestspectra==0,
                    
                     if isfield(spectra,'singletrial_refspectra'),
                        spectra=rmfield(spectra,'singletrial_refspectra');
                     end
                     
                     if isfield(spectra,'singletrial_testspectra'),
                        spectra=rmfield(spectra,'singletrial_testspectra');
                     end
                     
                 end                                                   
                 
                 if (~isfield(spectra,'singletrial_refspectra') || ~isfield(spectra,'singletrial_testspectra')) && savepar.CRBfieldpar.includestspectra==1,
                    warning('Single trial spectra not saved in the CRB field. Set ''singletrialspectra'' field of ''CRBpar'' to 1 for saving single trial spectra') 
                 end
                  
                 CRB.spectra=spectra;
                 CRB.par=par;
                 EEG.CRB=CRB;
                                    
             else 
                 
                 CRB.par=par;
                 EEG.CRB=CRB;        
                                  
             end
                 
        end             
       
end