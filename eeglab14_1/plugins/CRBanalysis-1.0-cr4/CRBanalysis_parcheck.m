% CRBanalysis_parcheck() -  performs a check on the input parameters struct for
%                           assessing the presence of values needed for carrying out the CRB analysis
%                           and for setting possible empty fields to their
%                           default values. 
%
% Usage:
%   >>  CRBpar = CRBanalysis_parcheck( CRBpar );
%
% Inputs:
%   CRBpar   - struct of parameters
%    
% Outputs:
%   CRBpar  - output struct
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

function CRBpar=CRBanalysis_parcheck(CRBpar)


parcheck={'spectraldata'         , []                                   ,  0  ;...
          'onlyspectra'          , []                                   ,  0  ;...
          'onlystepone'          , []                                   ,  0  ;...
          'customanalysis'       , []                                   ,  0  ;...          
          'singletrialspectra'   , []                                   ,  0  ;...
          'labels'               , []                                   ,  [] ;...
          'timeintervals'        , {'t',[],[];...
                                    'ref_int',[],[];...
                                    'test_int',[],[]}                 ,  []  ;... 
          'spectrapar'           , {'srate', [],'inv(CRBpar.timeintervals.t(2)-CRBpar.timeintervals.t(1))*1000';
                                    'method',[],'''Welch''';...                          
                                    'win_type',[],'''Hanning''';...
                                    'ref_winlength',[], 'abs(CRBpar.timeintervals.ref_int(2)-CRBpar.timeintervals.ref_int(1))';...
                                    'ref_winoverlap', [], '0' ;...
                                    'test_winlength', [], 'abs(CRBpar.timeintervals.test_int(2)-CRBpar.timeintervals.test_int(1))';...
                                    'test_winoverlap',[],'0';...
                                    'freq_lim', [], '[0 CRBpar.spectrapar.srate/4]';
                                    'Nfft',[],'2^nextpow2(CRBpar.spectrapar.srate/0.1)'} , [];...      
          'algpar'               ,  {'w_size'        , []             , '2';...
                                     'w_shift'       , []             , '0.2';...
                                     'lambda'        , []             , '0.5';...
                                     'epsilon'       , []             , '0.5';...
                                     'rho_min'       , []             , '0';...
                                     'r'             , []             , '0.2';...
                                     'p'             , []             , '80';...
                                     'lambda_left'   , []             , '1';...
                                     'epsilon_left'  , []             , '0';...
                                     'scan_interval' , []             , 'CRBpar.spectrapar.freq_lim';...
                                     'alpha_interval', []             , '[8 13]';...
                                     'CFcomp'        , []             ,  '1'}, [];...
          'custom'               ,  {'bands',  [],  [];
                                     'selection_flags',[],[]} , NaN};  
                                 



for i_parcheck=1:size(parcheck,1),
   
    fieldname=parcheck{i_parcheck,1};
   
    
    if ~isfield(CRBpar,fieldname),
        
        eval(['CRBpar.' fieldname '=[];'])
        
    end
        
    eval(['fieldvalue=CRBpar.' fieldname ';']);    
        
    if ismember(fieldname,{'spectraldata','onlyspectra','onlystepone','customanalysis','singletrialspectra','labels'})
        
                    
            if isempty(fieldvalue),
                
                eval(['CRBpar.' fieldname '=parcheck{i_parcheck,3};']);
            
            end         
            
    else
      
        switch fieldname
            
            case 'timeintervals',
                                
                if CRBpar.spectraldata==0,
                    
                    if isempty(fieldvalue),

                        error('CRBpar.timeintervals.t, CRBpar.timeintervals.ref_int and CRBpar.timeintervals.ref_int needed for running CRB');

                    else

                        timeintervals=CRBpar.timeintervals;
                        timeintervals_check=parcheck{i_parcheck,2};

                        for i_timeintervals=1:size(timeintervals_check,1),

                            fieldname=timeintervals_check{i_timeintervals,1};

                            if isfield(timeintervals,fieldname),

                                eval(['fieldvalue=timeintervals.' fieldname ';']);

                            end

                            if ~isfield(timeintervals, fieldname) || isempty(fieldvalue),

                                error(['CRBpar.timeintervals.' fieldname ' needed for executing CRB analysis']);

                            end


                        end


                    end                                
                end
                
            case 'spectrapar',
                
                    spectrapar=CRBpar.spectrapar;
                    spectrapar_check=parcheck{i_parcheck,2};
                    
                    if CRBpar.spectraldata==1,
                        
                        for i_spectrapar=1:size(spectrapar_check,1),

                            fieldname=spectrapar_check{i_spectrapar,1};

                            if ~isfield(spectrapar, fieldname),

                                eval(['CRBpar.spectrapar.' fieldname '=[];']);

                            end

                            eval(['fieldvalue=CRBpar.spectrapar.' fieldname ';']);
                           
                            if strcmp(fieldname,'freq_lim') && isempty(fieldvalue),

                               error(['''' fieldname ''' field of ''spectrapar'' needed in case ''spectraldata'' is set to 1'])

                            end                                                
                        end
                        
                    else
                    
                        for i_spectrapar=1:size(spectrapar_check,1),

                            fieldname=spectrapar_check{i_spectrapar,1};

                            if ~isfield(spectrapar, fieldname),

                                eval(['CRBpar.spectrapar.' fieldname '=[];']);

                            end


                            eval(['fieldvalue=CRBpar.spectrapar.' fieldname ';']);


                            if isempty(fieldvalue),

                               eval(['CRBpar.spectrapar.' fieldname '=' spectrapar_check{i_spectrapar,3} ';']);

                            end                                                

                        end
                    
                    end
                    
            case 'algpar'
                   
                
                if ~isfield(CRBpar.algpar,'addparameters') || isempty(CRBpar.algpar.addparameters),
                    CRBpar.algpar.addparameters={'scan_interval','alpha_interval','lambda_left','epsilon_left'};
                end
                
                algpar=CRBpar.algpar;
                algpar_check=parcheck{i_parcheck,2};


                for i_algpar=1:size(algpar_check,1),

                    fieldname=algpar_check{i_algpar,1};

                    if ~isfield(algpar,fieldname),
                        eval(['CRBpar.algpar.' fieldname '=[];']);                            
                    end

                    eval(['fieldvalue=CRBpar.algpar.' fieldname ';']);

                    if isempty(fieldvalue),

                        eval(['CRBpar.algpar.' fieldname '=' algpar_check{i_algpar,3} ';']);

                    end
                    
                end
                                       
            case 'custom'  
                                  
                    
                    if isempty(CRBpar.custom),
                        
                        CRBpar.custom.bands=[];
                        CRBpar.custom.selection_flags=[];                        
                        
                    else
                        
                        if ~isfield(CRBpar.custom,'bands'),
                            CRBpar.custom.bands=[];
                        end
                        
                        if ~isfield(CRBpar.custom,'selection_flags'),
                            CRBpar.custom.selection_flags=[];
                        end
                        
                    end
                  
                    if CRBpar.customanalysis==1 && (isempty(CRBpar.custom.bands) || isempty(CRBpar.custom.selection_flags)),
                        
                        error('For carrying out custom analyses CRBpar.custom.bands and CRBpar.custom.selection_flags are required')
                        
                    end
 
                               
        end
      
    end
    

end