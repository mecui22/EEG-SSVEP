% saveresults_parcheck() - performs a check on the input parameters struct for executing saveresults() and sets default values
%
% Usage:
%   >>  parout=saveresults_parcheck(parin) 
%
% Inputs:   
%   
%   parin - input parameters struct
%    
% Outputs:
%   parout  - output parameters struct
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


function parout=saveresults_parcheck(parin)    

    if ~isfield(parin,'txt') || isempty(parin.txt),

            parin.txt=0;

    end

    if parin.txt==1
        
        if (~isfield(parin,'txtpar'))
       
        error('For saving results in a txt file, par.savepar.txtpar.filename is required')
        
        else
           
            if ~isfield(parin.txtpar,'filepath') || isempty(parin.txtpar.filepath),
                
                parin.txtpar.filepath='.';                
                
            end
            
            if ~isfield(parin.txtpar,'filename') || isempty(parin.txtpar.filename),
                
                error('For saving results in a txt file, par.savepar.txtpar.filename is required')                
                
            end
            
        end
        
    end
            
    if ~isfield(parin,'mat')|| isempty(parin.mat),

        parin.mat=0;

    end
    
    if parin.mat==1
        
        if (~isfield(parin,'matpar'))
       
            error('For saving results in a mat file, the field ''matpar'' is required')
        
        else
           
            if ~isfield(parin.matpar,'filepath') || isempty(parin.matpar.filepath),
                
                parin.matpar.filepath='.';                
                
            end
            
            if ~isfield(parin.matpar,'filename') || isempty(parin.matpar.filename),
                
                error('''filename'' field of ''matpar'' needed for saving results in a mat file')                
                
            end
            
             if ~isfield(parin.matpar,'includeavespectra') || isempty(parin.matpar.includeavespectra),
                
                parin.matpar.includeavespectra=0;                
                
             end
            
             if ~isfield(parin.matpar,'includestspectra') || isempty(parin.matpar.includestspectra),
                
                parin.matpar.includestspectra=0;                
                
             end
            
        end
        
    end    
    

    if ~isfield(parin,'CRBfield')|| isempty(parin.CRBfield),

        parin.CRBfield=0;

    end
    
    if parin.CRBfield==1
        
        if (~isfield(parin,'CRBfieldpar'))
       
            parin.CRBfieldpar=[];
        
        end
                       
        if ~isfield(parin.CRBfieldpar,'includeavespectra') || isempty(parin.CRBfieldpar.includeavespectra),

            parin.CRBfieldpar.includeavespectra=0;                

        end

        if ~isfield(parin.CRBfieldpar,'includestspectra') || isempty(parin.CRBfieldpar.includestspectra),

            parin.CRBfieldpar.includestspectra=0;                

        end
            
        
    end  
    
    parout=parin;
    
end
