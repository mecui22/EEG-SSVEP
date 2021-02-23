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

function eegplugin_CRBanalysis(fig,try_strings,catch_strings)
                              
         h_tools = findobj(fig, 'tag', 'tools');         
         h_CRBanalysismenu=uimenu( h_tools, 'label', 'Analyze alpha frequencies by CRB');                                     
         
         set(h_CRBanalysismenu,'callback', ... 
                 [  try_strings.no_check...
                   '[EEG LASTCOM]= pop_CRBanalysis(EEG);'...
                    catch_strings.add_to_hist  ...
                   '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']); 
               
end



