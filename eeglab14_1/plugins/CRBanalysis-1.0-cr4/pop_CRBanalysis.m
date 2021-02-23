% pop_CRBanalysis() - performs the channel reactivity based (CRB) analysis of either EEG scalp channels or
%                     ICA independent components (ICs) for localizing alpha responsiveness frequency intervals 
%                     and estimating individual alpha frequencies (IAFs) and channel/components alpha frequencies (CAFs). 
%
% Usage:
%   >>  OUTEEG = pop_CRBanalysis( INEEG, typeproc, par );
%
%                Launched without any argument displays this help; launched with one or two arguments
%                pops up an interactive window for inserting initial parameters values; launched with 
%                three arguments may display graphical interfaces depending on the input parameters values. %
%
% Inputs:
%   INEEG    -  input EEGLAB EEG struct
%
%   typeproc -  scalar (0/1) - optional - if set to 1 executes the CRB analysis on scalp channels, if set to 0 executes CRB analysis on ICA independent components(ICs) 
%                              - default: 1
%
%   par      -  parameters struct - if not included in the arguments, an interactive window for inserting parameters values is diplayed
%               .chanlocs  -  struct - optional - EEG chanlocs structure - default: empty %
%               .labels    -  cell vector of strings - optional - data channels/ICs labels  - default:  {'1';…, 'Number of channels/ICs'}
%               .CRB_dataindexes - numerical vector - optional - indexes of channels on which the CRB analysis will be carried out - default: 1:Number of data channels
%               .executeandsave  - scalar (0/1) - optional - if set to 1 results are saved without being shown in the GUIs for results inspection 
%                                               - default: 1; if par.executeandsave==1 and par.savepar is not empty, data are saved without displaying any GUI, 
%                                                otherwise the GUI for saving results is displayed.  
%               .showresults     - scalar 0/1 - optional - flag (0/1) - optional – if set to 1 results are shown in the GUI for numerical values inspection - default: 0
%               .spectraplots    - 0/1 - optional - when par.showreults=1, if set to 1 data PSDs are plotted in the GUI for spectra plots inspection - default: 0
%               .plotspar        - struct – optional - settings for plotting spectra in the GUI for spectra plots inspection; ignored if par.showreults=0 or par.spectraplots=0;
%                                .indexes     - numerical vector - optional - indexes of data to plot; indexes are relative to the matrix submitted to CRB analysis 
%                                                                           – default: 1:Number of channels/ICs submitted to CRB analysis
%                                .freq_range  - 2-dimesional numerical vector - optional - frequency range to plot – default: equal to par.CRBpar.spectrapar.freq_lim %
%               .CRBpar          - struct - CRB algorithm parameters - see the CRBanalysis() help%
%               .savepar         - struct     - optional - settings for saving results - default: empty %
%                                .txt         - 0/1  - optional - set to 1 for saving results in a txt file - default: 0 %
%                                .txtpar      - struct - parameters for saving results in a txt file
%                                             .filename - string - NEEDED if par.savepar.txt==1 - name of the file for saving results%
%                                             .filepath - string - optional - path for placing the file - default: '.' (current directory)%
%                                .mat         scalar (0/1) - optional – if set to 1 results are saved in a .mat file; %
%                                .matpar      - struct            - parameters for saving results in a mat file %
%                                             .filename           - string - needed if par.savepar.mat==1 - mat file name
%                                             .filepath           - string - optional - .mat file path - default: '.' (current directory) %
%                                             .includeavespectra  - scalar (0/1) - optional – when par.savepar.mat==1, if set to 1 average spectra are included in the results
%                                                                                - default: 0
%                                             .includestspectra   - 0/1 - optional - set to 1 for including single trial spectra in the mat file - default: 0%
%                                .CRBfield    - scalar (0/1) - optional – if set to 1 results are saved in the CRB field of the EEG struct – default: 0
%                                .CRBfieldpar - struct - optional - parameters for saving results in 'CRB' field of EEG
%                                             .includeavespectra  - scalar (0/1) - optional –  when par.savepar.CRBfield==1, if set to 1 average spectra are included the CRB field 
%                                                                                - default: 0
%                                             .includestspectra   - scalar (0/1) - optional - when par.savepar.CRBfield==1, if set to 1 single-trial spectra  are included in the CRB field 
%                                                                               - default: 0
%
%
% Outputs:
%
%   OUTEEG  - EEGLAB struct with results in the new field 'CRB' if par.savepar.CRBfield==1
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

function [EEG, com] = pop_CRBanalysis( EEG, typeproc, par)

com = ''; 

% displaying help if no arguments are passed to the function

if nargin ==0
    help  pop_CRBanalysis;
    return;
end;

try
    EEG=eeg_checkset(EEG);
catch
    
end

if isempty(EEG.times),
    
    Ts=1/EEG.srate;
    t=EEG.xmin:Ts:EEG.xmin+(EEG.pnts-1)*Ts;
    EEG.times=t*1000; % in ms
    
end

% if param argument is missing, GUI for initial settings pops-up

if nargin<2,
    
    par=initialsettings_gui(EEG);
    
    if isempty(par),
        
        return
        
    end
    
else
    
    if nargin < 3
        
        par=initialsettings_gui(EEG,typeproc);
        
        if isempty(par),
            
            return
            
        end
        
        
        
    else
        
        par.typeproc=typeproc;
        
        N_chan=size(EEG.data,1);
        
        if par.typeproc==0,
            
            N_comp=size(EEG.icaweights,1);
            
            if ~isfield(par,'labels')  || isempty(par.labels),
                
                par.labels=cell(N_comp,1);
                
                for i_comp=1:N_comp,
                    par.labels{i_comp}=num2str(i_comp);
                end
                
            end
            
            par.chanlocs=[];
            
        else
            
            if isfield(EEG,'chanlocs') && ~isempty(EEG.chanlocs),
                
                try
                    
                    [tmp lab th rd]=readlocs(EEG.chanlocs);
                    
                    if  sum(isnan(th))<N_chan,
                        
                        par.chanlocs=EEG.chanlocs;
                        
                    else
                        
                        par.chanlocs=[];
                        
                    end
                    
                catch err
                    
                    par.chanlocs=[];
                    lab=cell(1,N_chan);
                    
                end
                
            else
                
                par.chanlocs=[];
                lab=cell(1,N_chan);
                
            end
            
            if ~isfield(par,'labels') || isempty(par.labels),
                
                par.labels=cell(N_chan,1);
                
                for i_chan=1:N_chan,
                    
                    if isempty(lab{i_chan}),
                        
                        par.labels{i_chan}=num2str(i_chan);
                        
                    else
                        
                        par.labels{i_chan}=[num2str(i_chan) '-' lab{i_chan}];
                        
                    end
                    
                end
                
            end
            
        end
        
        par.CRBpar.timeintervals.t=EEG.times;
        par.CRBpar.spectrapar.srate=EEG.srate;
        
    end
    
end

com=['EEG=pop_CRBanalysis(EEG,' num2str(par.typeproc) ',par);'];

par = pop_CRBanalysis_parcheck(par);
par.CRBpar.typeproc = par.typeproc; 

if par.typeproc==1,
    
    par.CRBpar.colnames = {'IAF(Hz)','selected','CAF (Hz)','rho (microV^2/Hz)','f_1 (Hz)','f_2 (Hz)','P_R (microV^2)','P_T (microV^2)','rel. power var.(%)'};;
    
    if isempty(par.CRB_dataindexes),
        
        par.CRB_dataindexes=[1:size(EEG.data,1)];
        par=pop_CRBanalysis_parcheck(par);
        
        indexes=par.CRB_dataindexes;
        
    else
        
        indexes=par.CRB_dataindexes;
        
    end
    
    data=EEG.data(indexes,:,:);
    
else
    
par.CRBpar.colnames = {'IAF(Hz)','selected','CAF (Hz)','rho (A^2/Hz)','f_1 (Hz)','f_2 (Hz)','P_R (A^2)','P_T (A^2)','rel. power var.(%)'};;    
        
    if ~isfield(EEG,'icaact') || isempty(EEG.icaact),
        
        if ~isfield(EEG,'icaweights') || isempty(EEG.icaweights),
            
            error('ICA components not found')
        
        else
            
            data=EEG.icaweights*EEG.icasphere*reshape(EEG.data,size(EEG.data,1),[]);
            data=reshape(data,size(data,1),size(EEG.data,2),[]);
        
        end
        
    else
        
        data=EEG.icaact;
        
    end
    
    if isempty(par.CRB_dataindexes),
        
        par.CRB_dataindexes=[1:size(data,1)];
        par=pop_CRBanalysis_parcheck(par);
        indexes=par.CRB_dataindexes;
        
    else
        
        indexes=par.CRB_dataindexes;
        
    end
    
    data=data(indexes,:,:);
    
end

pause(0.5)

display('Executing CRB analysis... wait...  ')
[CRB spectra]=CRBanalysis(data,par.CRBpar);
display('Done.')


CRB.spectra=spectra;

if isfield(par,'executeandsave') && par.executeandsave==1,
    
    CRB.par=par;
    display('Saving results...wait...')
    
    if ~isfield(par, 'savepar') || isempty(par.savepar),
        
        EEG=saveresults(EEG,CRB);
        
    else
        
        EEG=saveresults(EEG,CRB,par.savepar);
        
    end
    
    display('Done.')
    
    return
    
end

if par.showresults==1,
    
    CRB=showresults_gui(CRB,par);
    
    if ~isempty(CRB),
        
        EEG=saveresults(EEG,CRB);
        
    else
        
        return
        
    end
    
end



end






