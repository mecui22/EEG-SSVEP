% pop_CRBanalysis_parcheck() - performs a check on the input parameters struct for executing pop_CRBanalysis() and sets default values
%
% Usage:
%   >>  parout=pop_CRBanalysis_parcheck(parin) 
%
% Inputs:   
%   
%   parin -   input parameters struct
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


function parout=pop_CRBanalysis_parcheck(parin)

if ~isfield(parin,'typeproc') || isempty(parin.typeproc),
   parin.typeproc=1; 
end

if ~isfield(parin,'CRBpar') || isempty(parin.CRBpar),
    
    error('''CRBpar'' field needed');    
    
else
    
    parin.CRBpar=CRBanalysis_parcheck(parin.CRBpar);
    
end

if ~isfield(parin,'labels'),
    
    parin.labels=[];
    
end


if ~isfield(parin,'CRB_dataindexes'),
    
    parin.CRB_dataindexes=[];
    
end

if ~isfield(parin.CRBpar,'labels'),
    
    parin.CRBpar.labels=[];
    
end

if isempty(parin.CRBpar.labels),
    
    if ~isempty(parin.CRB_dataindexes) && ~isempty(parin.labels),

       parin.CRBpar.labels=parin.labels(parin.CRB_dataindexes);

    end
    
end

if ~isfield(parin,'chanlocs') || parin.typeproc==0,
    
    parin.chanlocs=[];
    
end

if ~isfield(parin,'CRB_chanlocs'),
    parin.CRB_chanlocs=[];
end

if isempty(parin.CRB_chanlocs) && parin.typeproc==1,
    
    if ~isempty(parin.chanlocs) && ~isempty(parin.CRB_dataindexes),

       parin.CRB_chanlocs=parin.chanlocs(parin.CRB_dataindexes);

    end
    
end

if (~isfield(parin,'executeandsave') || isempty(parin.executeandsave)) &&...
    (~isfield(parin,'showresults') || isempty(parin.showresults))
    
    parin.executeandsave=1;
    parin.showresults=0;
   
end
    
if isfield(parin,'executeandsave') && ~isempty(parin.executeandsave),
   
    if parin.executeandsave==1,
        
        parin.showresults=0;
        
    else
        
        parin.showresults=1;
        
    end
    
end
    
if isfield(parin,'showresults') && ~isempty(parin.showresults),
   
    if parin.showresults==1,
        
        parin.executeandsave=0;
        
    else
        
        parin.executeandsave=1;
        
    end
    
end
    
if ~isfield(parin,'spectraplots') || isempty(parin.spectraplots) || parin.showresults==0,
    
   parin.spectraplots=0; 
   
end
    
    
if ~isfield(parin,'plotspar'),
    parin.plotspar=[];
end

if ~isfield(parin.plotspar, 'indexes') || isempty(parin.plotspar.indexes),

    if ~isempty(parin.CRB_dataindexes),
        parin.plotspar.indexes=1:length(parin.CRB_dataindexes);        
    else
        parin.plotspar.indexes=[];
    end

end

if ~isfield(parin.plotspar, 'freq_range') || isempty(parin.plotspar.freq_range),

   parin.plotspar.freq_range=parin.CRBpar.spectrapar.freq_lim;

end

if ~isfield(parin.plotspar, 'labels')
    parin.plotspar.labels=[];    
end

if isempty(parin.plotspar.labels),

    if ~isempty(parin.CRBpar.labels) && ~isempty(parin.plotspar.indexes),

        parin.plotspar.labels=parin.CRBpar.labels(parin.plotspar.indexes);

    end

end

if ~isfield(parin.plotspar, 'chanlocs'),

    parin.plotspar.chanlocs=[];

end

if  isempty(parin.plotspar.chanlocs),

    if ~isempty(parin.CRB_chanlocs) && ~isempty(parin.plotspar.indexes),
        parin.plotspar.chanlocs=parin.CRB_chanlocs(parin.plotspar.indexes);
    end

end    



if ~isfield(parin,'savepar') || isempty(parin.savepar),
    
    parin.savepar=[];    

end

parout=parin;

end







     