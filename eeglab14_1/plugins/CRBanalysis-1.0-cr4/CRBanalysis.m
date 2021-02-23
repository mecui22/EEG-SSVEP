% CRBanalysis() - performs the channel reactivity based (CRB) analysis of either EEG scalp channels or
%                     ICA independent components (ICs) for localizing  alpha responsiveness frequency intervals 
%                     and estimating individual alpha frequencies (IAFs) and channel/components alpha frequencies (CAFs). 
%
% Usage:
%   >>  [CRB spectra] = CRBanalysis( data, CRBpar );
%
% Inputs:
%   data    - numerical matrix (number of channels/ICs x number of time
%   points x number of epochs) 
%             or, in case par.spectraldata==1, cell vector containing average reference 
%             and test spectra matrices (number of channels/ICs x number of frequency time points) %
%   CRBpar     - parameters structure
%             structure fields:
%                 .spectraldata                  -  scalar (0/1) -  optional - if set to 0, input  data is a numerical matrix, if set to 1 data is a 2-dimensional cell vector 
%                                                                  containing the average reference and test spectra  matrices  - default: 0
%                 .onlyspectra                   -  scalar (0/1) -  optional - if set to 1 only spectra are computed and the output CRB is left empty - default: 0
%                 .onlystepone                   -  scalar (0/1) -  optional - if set to 1, only Step 1 of the CRB algorithm is performed - default: 0
%                 .customanalysis                -  scalar (0/1) -  optional - if set to 1 custom analysis is carried out – default: 0
%                 .singletrialspectra            -  scalar (0/1) -  optional - if set to 1 single-trial spectra are returned in the fields singletrial_refspectra and 
%                                                                  singletrial_testspectra of the spectra struct- default: 0  
%                 .labels                        -  cell of strings - optional - data labels - default: {'1',..., number of channels/ICs) 
%                 .timeintervals                 -  struct - 
%                              .t                  numerical vector - NEEDED if CRBpar.spectraldata==0 - data time vector (ms); 
%                                                                    note that pop_CRBanalysis() automatically set CRBpar.timeintervals.t equal to EEG.times
%                              .ref_int            -  2-dimensional vector- NEEDED if CRBpar.spectraldata==0 - reference interval (ms)%
%                              .test_int           -  2-dimensional  vector- NEEDED if CRBpar.spectraldata==0 - test interval (ms)% 
%                 .spectrapar                    -  struct - parameters for reference and test spectra computation%
%                            .srate                - scalar - optional – data sampling rate – default: derived from CRBpar.timeintervals.t if CRBpar.spectraldata==0 
%                            .method               - string - optional - method for estimating power spectral densities (PSDs) - default: 'Welch'
%                            .win_type             - string ('Hanning','Hamming','none') - optional - window type for PSDs estimation - default: 'Hanning'      
%                            .ref_win_length       - scalar - optional - length in ms of the windows for the estimation of the reference PSDs - default: length of the reference interval
%                            .ref_win_overlap      - scalar in (0,100)  - optional - percentage of windows overlap for the estimation of the reference PSDs - default: 0
%                            .test_win_length      - scalar - optional - scalar - optional – length in ms of the windows for the estimation of test PSDs estimation - default: length of the test interval
%                            .test_win_overlap     - scalar in (0,100)  - optional - percentage of windows overlap for the estimation of test PSDs- default: 0
%                            .freq_lim             - 2-dimensional numerical vector -  NEEDED if CRBpar.spectraldata==1 - spectra frequency range
%                            .Nfft                 - scalar- optional - number of PSD frequency samples to estimate -  default: number of samples yielding a frequency quantum not greater than 0.1 Hz
%                 .algpar                       -  struct - CRB algorithm parameters 
%                         .scan_interval           - 2-dimensional  numerical vector – optional – frequency interval swept during the scanning phase – default: CRBpar.spectrapar.freq_lim
%                         .alpha_interval          - 2-dimensional  numerical vector  – optional – reference frequency interval in Hz for computing regularization weights in the scanning phase – default:  [8 13] 
%                         .w_size                  - scalar – optional -  width in Hz of windows utilized in the scanning phase – default: 2
%                         .w_shift                 - scalar – optional – scanning phase windows shifts in Hz – default: 0.2 
%                         .lambda                  - scalar in (0,1) – optional – parameter utilized for computing the weights for the regularization of 
%                                                                      windows at frequencies higher than CRBpar.algpar.alpha_interval – default: 0.5%   
%                         .epsilon                 - scalar in (0,1)   - optional - scalar in (0,1) – optional – parameter utilized in the expansion phase for determining the upper boundary of 
%                                                                                   the responsiveness frequency interval – default:  0.5
%                         .rho_min                 - scalar – optional – parameter utilized for the selection of leads that will participate in the computation of the IAF and the average alpha interval; 
%                                                             channels/ICs with rho values lower than CRBpar.algpar.rho_min are discarded  – default: 0.15
%                         .r                       - scalar in (0,1) – optional – parameter utilized in the selection step of the algorithm for computing the subject’s activity dependent threshold rho_sub; 
%                                                                      channels/ICs with rho values smaller than the r-th fraction of the p-th  (see the next parameter) percentile of the set of 
%                                                                      reactivity indexes greater than rho_min are discarded – default : 0 
%                         .p                       - scalar in (0,100) – optional – see the explanation of the previous parameter – default: 80
%                         .lambda_left             - scalar in (0,1) – optional - parameter analogous to ‘lambda’, which allows the regularization of windows placed at frequencies smaller than the 'alpha_interval' interval
%                                                                    – default: 1 (equivalent  to not having any regularization for windows at frequencies below CRBpar.algpar.alpha_interval)
%                         .epsilon_left            - scalar in (0,1) - optional - parameter analogous to ‘epsilon’, which allows to select as lower boundary of the responsiveness interval (expansion phase of the algorithm) 
%                                                                                 a frequency at which reference and test PSDs are close without intersecting 
%                                                                    - default: 0 (equivalent to accepting only intersection points) 
%                         .CFcomp                  - scalar in (1,2,3) - default: 1 - if set to 1 CFs are computed using reference PSDs in the gravity center computation;
%                                                                                     if set to 2 CFs are computed using test PSDs in the gravity center computation;
%                                                                                     if set to 3 CFs are computed using the absolute difference between reference and test PSDs in the gravity center computation
%                 .custom                           - struct - parameters for carrying out custom analysis (CRBpar.customanalyis==1)
%                               .bands             - numerical matrix (number of channels/ICs  x 2) - NEEDED if CRBpar.customanalyis==1- user's defined bands for computing rho and CAF values; 
%                                                                       NaN values are returned in correspondence with rows containg NaN values 
%                               .selection_flags   - numerical vector of 0s and 1s (number of channels/ICs x 1) - NEEDED if CRBpar.customanalysis==1 - selected status of channels/ICs (0 for not selected and 1 for selected) 
%                                                                      for the computation of the IAF and the average alpha interval; note that the value in 
%                                                                      CRBpar.custom.selection_flags must be equal to 0 in correspondence with those channels/ICs that have NaN values in the CRB.custom.bands matrix%
%
% Outputs:
%   CRB                 -  struct - empty if CRBpar.onlyspectra==1
%        .results       -  cell matrix containing analysis results 
%        .colnames      -  cell vector  of strings containing the names of the columns of the CRB.results cell matrix
%        .rownames      -  cecell vector  of strings containing the names of the rows (chennel/IC labels) of the CRB.results cell matrix
%        .results_num   -  numerical matrix containing numerical values of the CRB.results cell matrix
%        .ave_alpha_int -  2-dimensional numerical vector containing the average boundaries of the responsiveness intervals of the channels/ICs participating in 
%                          the IAF computation 
%        .L             -  struct with CRB channels/ICs selection parameters and results (Step 2 of the CRB algorithm) %
%                         .rho_min      - scalar - minimum ? value under which no activity is considered to be present
%                         .r            - scalar between 0 and 1 utilized for computing the threshold rho_sub as the fraction r of the p-th percentile of the set of ? values greater than rho_min
%                         .p            - scalar between 0 and 100 utilized for computing the threshold rho_sub as the fraction r of the p-th percentile of the set of ? values greater than rho_min
%                         .rho_sub      - scalar - subject's specific threshold for selecting channels/ICs;
%                         .rhos_thresh  - scalar - threshold (max(rho_min,rho_sub)) for selecting channels/ICs at Step 2 of the CRB algorithm; 
%                                                  only channels/ICs with ? values greater than rhos_thresh are selected for participating in the IAF and average alpha interval computation %
%                         .indexes      - numerical vector - indexes of channels/ICs selected by the CRB algorithm %
%
%   spectra
%         .f                       - numerical vector - reference frequencies vector for PSDs 
%         .ave_refspectra          - numerical matrix (Number of channels/ICs x Number of frequency points) containing average reference spectra %
%         .ave_testspectra         - numerical matrix (Number of channels/ICs x Number of frequency points) containing average test spectra %
%         .singletrial_refspectra  - numerical matrix (Number of channels  x length(spectra.f) x Number of epochs) - single trial reference PSDs; included if CRBpar.singletrialspectra==1  %
%         .singletrial_testspectra - numerical matrix (Number of channels  x length(spectra.f) x Number of epochs) - single trial test PSDs; included if CRBpar.singletrialspectra==1    %
%


% Copyright (C) <2012>  <Anahita Goljahani>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [CRB spectra] = CRBanalysis( data, CRBpar )


if nargin < 1
    help CRBanalysis;
    return;
end;

if isempty(data),
    
    error('CRB analysis can not be executed on empty sets')
    
end

%%% checking  'CRBpar' for setting default values in case they were not defined by the user


CRBpar=CRBanalysis_parcheck(CRBpar);

if ~isfield(CRBpar,'colnames') || isempty(CRBpar.colnames),
   
    colnames = {'IAF(Hz)','selected','CAF (Hz)','rho (microV^2/Hz)','f_1 (Hz)','f_2 (Hz)','P_R (microV^2)','P_T (microV^2)','rel. power var.(%)'};
    CRBpar.colnames = colnames;

end



%%% some more default settings, if needed

if CRBpar.spectraldata==0,
    
    N_chan=size(data,1);
    
else
    
    N_chan=size(data{1},1);
    
end

if isempty(CRBpar.labels),
   
    labels=cell(1,N_chan);
    
    for i_chan=1:N_chan,
        
        labels{i_chan}=num2str(i_chan);
        
    end
    
    labels=labels.';
    CRBpar.labels=labels;
    
else
    
    if length(CRBpar.labels)~=N_chan,
        error('Number of labels not equal to number of channels/ICs')
    end
    
end
   


%%% computing spectra during reference and test intervals


if CRBpar.spectraldata==0,
    
    %%% extracting data relative to reference and test time intervals
    
    t=CRBpar.timeintervals.t; 
    
    ref_int=CRBpar.timeintervals.ref_int;
    test_int=CRBpar.timeintervals.test_int;    
    
    
    
    if ref_int(1)>ref_int(2),

        tmp=ref_int(1);
        ref_int(1)=ref_int(2);
        ref_int(2)=tmp;
        CRBpar.timeintervals.ref_int=ref_int;
    end
    
    if test_int(1)>test_int(2),
        
        tmp=test_int(1);
        test_int(1)=test_int(2);
        test_int(2)=tmp;
        CRBpar.timeintervals.test_int=test_int;
        
    end
    
    if ref_int(1)<t(1) || ref_int(1)>t(end) || ref_int(2)<t(1) || ref_int(2)>t(end),
        
        error('reference interval outside the epoch''s time interval');
        
    end
    
    if test_int(1)<t(1) || test_int(1)>t(end) || test_int(2)<t(1) || test_int(2)>t(end),
        
        error('test interval outside the epoch''s time interval');
        
    end
    
    if ~isempty(find(t>=ref_int(1),1,'first')) && ~isempty(find(t<=ref_int(2),1,'last')) && ~isempty(intersect( find(t>=ref_int(1)) , find(t<=ref_int(2)) )),

        ref_indexes(1)=find(t>=ref_int(1),1,'first');
        ref_indexes(2)=find(t<=ref_int(2),1,'last');

   
    else
        
        error('reference interval must be inside the epoch time interval')
                
    end
    
    
    if ~isempty(find(t>=test_int(1),1,'first')) && ~isempty(find(t>=test_int(1),1,'first')) && ~isempty(intersect( find(t>=test_int(1)) , find(t<=test_int(2)) )),

        test_indexes(1)=find(t>=test_int(1),1,'first');
        test_indexes(2)=find(t<=test_int(2),1,'last');

        
    else
        
        error('test interval must be inside the epoch time interval')
        
    end        
    
    data_ref=data(:,ref_indexes(1):ref_indexes(2),:);
    data_test=data(:,test_indexes(1):test_indexes(2),:);
    
    
    [N_chan N_sampref N_epochs]=size(data_ref);
   

    
    %%% computing spectra 
    
    R=zeros(N_chan,ceil((CRBpar.spectrapar.Nfft+1)/2),N_epochs);
    T=zeros(N_chan,ceil((CRBpar.spectrapar.Nfft+1)/2),N_epochs);
    
    
    win_type=CRBpar.spectrapar.win_type;
    
    
    ref_winlength=CRBpar.spectrapar.ref_winlength;
    
    ref_winint=[ref_int(1) ref_int(1)+ref_winlength];
    
    if ref_winint(2)<=ref_int(2),
        
        N_samprefwin=find(t<=ref_winint(2),1,'last')-find(t>=ref_winint(1),1,'first')+1;
        N_overlaprefwin=ceil(CRBpar.spectrapar.ref_winoverlap/100*N_samprefwin);
        
    else
        error('reference window length should not exceed reference interval duration');
    end
        
    test_winlength=CRBpar.spectrapar.test_winlength;
    
    test_winint=[test_int(1) test_int(1)+test_winlength];
    
    if test_winint(2)<=test_int(2),
        
        N_samptestwin=find(t<=test_winint(2),1,'last')-find(t>=test_winint(1),1,'first')+1;
        N_overlaptestwin=ceil(CRBpar.spectrapar.test_winoverlap/100*N_samptestwin);
        
    else
        error('test window length should not exceed test interval duration');
    end        
    
    switch win_type,
        
        case 'none'
            
            refwin=ones(1,N_samprefwin);
            testwin=ones(1,N_samptestwin);
            
        case 'Hanning'
            
            refwin=hann(N_samprefwin);
            testwin=hann(N_samptestwin);
            
        case 'Hamming'
            
            refwin=hamm(N_samprefwin);
            testwin=hamm(N_samptestwin);
            
    end
    
    
    
    for i_chan=1:N_chan,
                
        for i_epoch=1:N_epochs,
            
            signal=data_ref(i_chan,:,i_epoch);
            R(i_chan,:,i_epoch)=pwelch(signal,refwin,N_overlaprefwin,CRBpar.spectrapar.Nfft,CRBpar.spectrapar.srate);
            
            signal=data_test(i_chan,:,i_epoch);
            [T(i_chan,:,i_epoch) f]=pwelch(signal,testwin,N_overlaptestwin,CRBpar.spectrapar.Nfft,CRBpar.spectrapar.srate);
            
        end
        
    end
    
    %%% limiting spectra to the interval CRBpar.spectrapar.freq_lim
    
    f_indexes(1)=find(f>=CRBpar.spectrapar.freq_lim(1),1,'first');
    f_indexes(2)=find(f<=CRBpar.spectrapar.freq_lim(2),1,'last');
    
    R=R(:,f_indexes(1):f_indexes(2),:);
    T=T(:,f_indexes(1):f_indexes(2),:);
    f=f(f_indexes(1):f_indexes(2));
    
else %%% in case data is a cell containg reference and test spectra (CRBpar.spectraldata=1)
    
    R=data{1};
    T=data{2};
    
    
    %%% deriving vector of frequencies f
    
    freq_lim=CRBpar.spectrapar.freq_lim;    
    f=freq_lim(1):(freq_lim(2)-freq_lim(1))/(size(R,2)-1):freq_lim(2);
    
end




if nargout>1,
    
    spectra.f=f;
    spectra.ave_refspectra=mean(R,3);
    spectra.ave_testspectra=mean(T,3);
    
    if CRBpar.singletrialspectra==1,
        
        spectra.singletrial_refspectra=R;
        spectra.singletrial_testspectra=T;
        
        
    end
    
    spectra.labels=CRBpar.labels;
    
    if CRBpar.onlyspectra==1,
        
        CRB=[];
       
        return
        
    end
    
end

R=mean(R,3);
T=mean(T,3);

%%%%%%%%%%% CUSTOM ANALYSIS

if CRBpar.customanalysis==1,
    
    if CRBpar.spectraldata==1,
        
       CRB=custom_analysis(data{1},data{2},f,CRBpar); %% function defined at the end of the file
       
    else
        
        data=cell(1,2);
        data{1}=R;
        data{2}=T;
        
        CRB=custom_analysis(data{1},data{2},f,CRBpar);
        
    end
    
    
    return
    
end


%%%%%%%%%% CRB ALGORITHM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%   STEP 1 of CRB analysis:determination of responsiveness intervals and computaion of rho values for all channels intervals
%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[CRB rho] = perform_step1(R,T,f,CRBpar);

if CRBpar.onlystepone==1,
    
    CRB.L=[];
    return
    
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%
%%%%%%%  STEP 2 of CRB analysis: leads selection
%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rhos=CRB.results_num(:,4);

    
%%% selecting leads

L=select_leads(rhos,CRBpar);  %% defined at the end of this file


if ~isempty(L.indexes),
   
     CRB.results(L.indexes+1,3)={1};
     CRB.results_num(L.indexes,2)=1;

end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%
%%%%%%%%%  STEP 3: IF computation
%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~isempty(L.indexes),
    
   CAFs=CRB.results_num(L.indexes,3); 
   IAF=(median(CAFs)*10)/10; 
   CRB.results(2:end,2)={IAF};
   CRB.results_num(:,1)=IAF;
   CRB.ave_alpha_int=[round(mean(CRB.results_num(L.indexes,5))*10)/10 round(mean(CRB.results_num(L.indexes,6))*10)/10];  
   
end

CRB.L=L;

end



function L=select_leads(rhos,CRBpar)

    r=CRBpar.algpar.r;
    p=CRBpar.algpar.p;
    rho_min=CRBpar.algpar.rho_min;


    L.r=r;
    L.p=p;
    L.rho_min=rho_min;

    N_chan=length(rhos);

    if sum(isnan(rhos))==N_chan,

        L.indexes=[];

        return

    else

        if isempty(rhos>=rho_min),

           L.indexes=[];

        else

           L.rhos_thresh=rhos(rhos>=rho_min);
           
           if ~isempty(which('prctile')),
               
               if ~isempty(L.rhos_thresh),
                  rho_sub=r*prctile(L.rhos_thresh,p);
               else
                  rho_sub=NaN;
               end
               
           else
               
               if ~isempty(L.rhos_thresh),               
                   rho_sub=r*my_prctile(L.rhos_thresh,p);
               else
                   rho_sub=NaN;
               end

           end
           
           rho_sub=(rho_sub*1000)/1000;
           L.rho_sub=rho_sub;
           L.rhos_thresh=max(rho_min,rho_sub);
           L.indexes=find(rhos>max(rho_min,rho_sub));

        end

    end

end



function CRB=custom_analysis(R,T,f,CRBpar)

    N_chan=size(R,1);    
    
    if size(CRBpar.custom.bands,1)~=N_chan || length(CRBpar.custom.selection_flags)~=N_chan,
        error('For carrying out custom analyses size(CRBpar.custom.bands,1) and length(CRBpar.custom.selection_flags) must be equal to the number of channels/ICs')
    end

    if ~isfield(CRBpar,'labels') || isempty(CRBpar.labels)
        
        CRBpar.labels=cell(1,N_chan);
        
        for i_chan=1:N_chan,
            
            CRBpar.labels{i_chan}=num2str(i_chan);
            
        end
        
         CRBpar.labels=CRBpar.labels.';
         
    end
    
    if isfield(CRBpar,'colnames') && ~isempty(CRBpar.colnames), 
        
       colnames=CRBpar.colnames;
    
    else
        
       colnames = {'IAF(Hz)','selected','CAF (Hz)','rho (microV^2/Hz)','f_1 (Hz)','f_2 (Hz)','P_R (microV^2)','P_T (microV^2)','rel. power var.(%)'};
       CRBpar.colnames = colnames;
           
    end
        
    CRB.colnames=colnames;
    
    CRB.results=num2cell(nan(N_chan+1,length(colnames)+1));  
    CRB.results{1,1}=[];
    
    
    CRB.rownames=CRBpar.labels;
    CRB.results_num=nan(N_chan,length(colnames));
    CRB.L.indexes=find(CRBpar.custom.selection_flags==1);
    
    CRB.results(1,2:end)=colnames;
    CRB.results(2:end,1)=CRBpar.labels;
        
    if ~isempty(CRBpar.custom.selection_flags),

        CRB.results(2:end,3)=num2cell(CRBpar.custom.selection_flags);
       
    else
        
        CRBpar.custom.selection_flags=ones(N_chan,1);
        CRB.results(2:end,3)=num2cell(CRBpar.custom.selection_flags);
        
    end
    

    CRB.results(2:end,[6 7])=num2cell(CRBpar.custom.bands);
    
    CRB.results_num(:,2)= CRBpar.custom.selection_flags;
    CRB.results_num(:,[5 6])= CRBpar.custom.bands;
    
    Diff=R-T;
    
    for i_chan=1:N_chan,
         
        b1=CRB.results_num(i_chan,5);
        b2=CRB.results_num(i_chan,6);
                
        if ~(isnan(b1) || isnan(b2)),
            
            if b1>b2,
                
                b1_tmp=b1;
                b1=b2;
                b2=b1_tmp;
                
                CRB.results(i_chan+1,[6 7])={b1 b2};
                CRB.results_num(i_chan,[5 6])=[b1 b2];
                
                
            end
            
        end
        
        if (isnan(b1) || isnan(b2)) 
            
            if CRB.results_num(i_chan,2)==1,
                        
                warning(['Channel ' num2str(i_chan) ' cannot be selected (selected==1) with  f_1 and/or f_2 set to NaN... channel deselected'])                        
                CRB.results_num(i_chan,2)=0;
                CRB.results_num(i_chan,[3 4 7 8 9])=NaN;

                CRB.results{i_chan+1,3}=0;
                CRB.results(i_chan+1,[3 4 7 8 9]+1)={NaN};
            
            else
                
                CRB.results_num(i_chan,2)=0;
                CRB.results_num(i_chan,[3 4 7 8 9])=NaN;

                CRB.results{i_chan+1,3}=0;
                CRB.results(i_chan+1,[3 4 7 8 9]+1)={NaN};                
                
            end
            
        else
                        
           if  b1>=f(1) && b2<=f(end) && ~isempty(intersect(find(f>=b1),find(f<=b2)))                       
               
               i1=find(f>=b1,1,'first');
               i2=find(f<=b2,1,'last');
  

               R_band=R(i_chan,i1:i2);
               R_band=R_band(:);

               T_band=T(i_chan,i1:i2);
               T_band=T_band(:);

               Diff_band=Diff(i_chan,i1:i2);
               Diff_band=Diff_band(:);

               f_band=f(i1:i2);
               f_band=f_band(:);
               
               if CRBpar.algpar.CFcomp==1,
               
                  CRB.results{i_chan+1,4}=round(trapz(f_band, R_band.*f_band)/trapz(f_band,R_band)*10)/10;  %CAF
               
               elseif CRBpar.algpar.CFcomp==2,
                   
                  CRB.results{i_chan+1,4}=round(trapz(f_band, T_band.*f_band)/trapz(f_band,T_band)*10)/10;  %CAF
                   
               else
                   
                  CRB.results{i_chan+1,4}=round(trapz(f_band, abs(T_band-R_band).*f_band)/trapz(f_band,abs(T_band-R_band))*10)/10; %CF
                   
               end
               
               
               CRB.results{i_chan+1,5}=round(trapz(f_band,Diff_band)/(b2-b1)*1000)/1000; %rho
               CRB.results{i_chan+1,8}=round(trapz(f_band,R_band)*1000)/1000;
               CRB.results{i_chan+1,9}=round(trapz(f_band,T_band)*1000)/1000;
               CRB.results{i_chan+1,10}=round((CRB.results{i_chan+1,9}-CRB.results{i_chan+1,8})/CRB.results{i_chan+1,8}*100*10)/10;

               CRB.results_num(i_chan,[3 4 7 8 9])=cell2mat(CRB.results(i_chan+1,[4 5 8 9 10]));

           else
               
                warning(['Channel ' num2str(i_chan) ': (' sprintf('%.2f',b1) ',' sprintf('%.2f',b2) ')Hz badly defined band; allowed frequency range:'...
                          '(' sprintf('%.1f',f(1)) ',' num2str(sprintf('%.1f',f(end)))  ')Hz'])                
                      
                CRB.results_num(i_chan,2)=0;
                CRB.results_num(i_chan,[3 4 7 8 9])=NaN;

                CRB.results{i_chan+1,3}=0;
                CRB.results(i_chan+1,[3 4 7 8 9]+1)={NaN};               
               
           end
           
        end
        
    end
     
    if ~isempty(find(CRB.results_num(:,2)==1,1)),
        
        CRB.results(2:end,2)={round(median(CRB.results_num(CRB.results_num(:,2)==1,3))*10)/10};    
        CRB.results_num(1:end,1)=round(median(CRB.results_num(CRB.results_num(:,2)==1,3))*10)/10;
    
    end    
    
end







