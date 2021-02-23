% perform_step1() - performs step 1 of the CRB algorithm on input data
%
% Usage:
%   >>  [CRB rho]=perform_step1(R,T,f,par);
%
% Inputs:
%   R   -      numerical matrix (N_chan x N_freq_samples ) containg average reference spectra 
%   T   -      numerical matrix (N_chan x N_freq_samples ) containg average test spectra 
%   f   -      numerical vector (N_freq_samples x 1) of spectra frequencies 
%   par     -  parameters structure  - optional - see CRBpar in the CRBanalysis() help             
%
%
% Outputs:
%   CRB                 - struct - see the CRBanalysis() help
%
%
%   rho                - struct
%         .R
%         .T
%         .Diff
%         .par
%         .weights
%         .scan_rhos
%         .scan_win
%         .win_opt
%         .i_winopt
%         .rho_opt
%         .rho_opt_index
%         .Diff_max
%         .Diff_firstorder            
%         .Diff_secondorder         
%         .f_Diff_zeros
%         .i_Diff_zeros
%         .f_local_minima_epsilon
%         .f_local_minima_epsilon_left
%         .f_candidate_left
%         .f_candidate_right
%         .CAF            
%         .ref_powrer
%         .test_powrer


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


function [CRB rho]=perform_step1(R,T,f,par)

 %%%% executing a check on input parameters 
 
 par.spectraldata=1;
 par.spectrapar.freq_lim=[f(1) f(end)];
 par=CRBanalysis_parcheck(par);
 
 N_chan=size(R,1);
 
 if isempty(par.labels),
     
     labels={};
     
     for i_chan=1:N_chan,
        
        labels=[labels {num2str(i_chan)}];
        
    end
    
    labels=labels.';
    par.labels=labels; 
 
 end


 colnames = par.colnames;
 
  
 %%% cell matrix for saving results 
 
 CRB.results=cell(N_chan+1,length(colnames)+1);
 CRB.results(1,2:end)=colnames;
 CRB.results(2:end,1)=par.labels;
 CRB.results(2:end,2)={NaN};
 CRB.results(2:end,3)={0};
 
 CRB.colnames=colnames;
 CRB.rownames=par.labels;
 CRB.results_num=zeros(N_chan,length(colnames));
 CRB.results_num(:,1)=NaN;
 
 %%% Step 1 parameters

w_size=par.algpar.w_size;
w_shift=par.algpar.w_shift;
lambda=par.algpar.lambda; 
lambda_left=par.algpar.lambda_left;
epsilon=par.algpar.epsilon;
epsilon_left=par.algpar.epsilon_left;

scan_interval=par.algpar.scan_interval;
alpha_interval= par.algpar.alpha_interval;

win_start=scan_interval(1):w_shift:scan_interval(2)-w_size;

%%%% weigths computation

weights=ones(1,length(win_start));

leftwin_indexes=find(win_start<alpha_interval(1));

for i_win=1:length(leftwin_indexes), 
        
    weights(leftwin_indexes(i_win))=lambda_left^(abs(win_start(leftwin_indexes(i_win))-alpha_interval(1))); 
    
end


rightwin_indexes=find(win_start+w_size>alpha_interval(2));

for i_win=1:length(rightwin_indexes),
        
    weights(rightwin_indexes(i_win))=lambda^(abs(win_start(rightwin_indexes(i_win))+w_size-alpha_interval(2))); 
    
end


N_win=length(win_start);

for i_chan=N_chan:-1:1,
           
    rho(i_chan).R=R(i_chan,:);    
    rho(i_chan).T=T(i_chan,:);
    rho(i_chan).f=f;
    rho(i_chan).Diff=R(i_chan,:)-T(i_chan,:);
   
    rho(i_chan).par=par;    
    rho(i_chan).weights=weights;
    
    rho(i_chan).scan_rhos=zeros(1,N_win);   
    rho(i_chan).scan_win=zeros(2,N_win);    
    rho(i_chan).rho_opt=zeros(1,2);
    rho(i_chan).win_opt=zeros(2,2);
    rho(i_chan).i_winopt=zeros(2,2);
    

    %%%%%%%% SCANNING PHASE
        
    for i_win=1:N_win,

        win=[win_start(i_win) win_start(i_win)+w_size];

        rho(i_chan).scan_win(:,i_win)=win;
         
        if ~isempty(find(f>=win(1),1,'first')) && ~isempty(find(f<=win(2),1,'last')) 
            
            i_f(1)=find(f>=win(1),1,'first');
            i_f(2)=find(f<=win(2),1,'last');
            
            if i_f(1)==i_f(2),
               error(['Channel ' num2str(i_chan) ', scanning phase: only one frequency sample found inside window ' num2str(i_win) ' -  increase either par.spectrapar.Nfft or par.algpar.w_size value']);
            end
            
        else
            
            error(['Channel ' num2str(i_chan) ', scanning phase: no frequency samples found inside window ' num2str(i_win) ' - increase either par.spectrapar.Nfft or par.algpar.w_size value']);
            
        end
        
        if rho(i_chan).Diff(i_f(1))>=0 && rho(i_chan).Diff(i_f(2))>=0, %%% necessary condition for having an interval 'inside' the responsiveness region
            
            rho(i_chan).scan_rhos(i_win)=weights(i_win)*trapz(f(i_f(1):i_f(2)),rho(i_chan).Diff(i_f(1):i_f(2)))/w_size;
            
        else

            rho(i_chan).scan_rhos(i_win)=NaN;
            
        end

    end
    
    [rho(i_chan).rho_opt(1) rho(i_chan).rho_opt_index]=max(rho(i_chan).scan_rhos);
    
    if (rho(i_chan).rho_opt(1))>0,
        
        rho(i_chan).win_opt(:,1) = rho(i_chan).scan_win(:,rho(i_chan).rho_opt_index);
        rho(i_chan).i_winopt(:,1)= [find(f>=rho(i_chan).win_opt(1,1),1,'first') find(f<=rho(i_chan).win_opt(2,1),1,'last')];
        rho(i_chan).win_opt(:,1) = f(rho(i_chan).i_winopt(:,1));
        rho(i_chan).rho_opt(1)   = sum(rho(i_chan).Diff(rho(i_chan).i_winopt(1,1):rho(i_chan).i_winopt(2,1)))*(f(2)-f(1))/w_size;        
    
    
        %%%%%%%% EXPANSION PHASE

        rho(i_chan).Diff_max=max(rho(i_chan).Diff( rho(i_chan).i_winopt(1,1):rho(i_chan).i_winopt(2,1)  ));
        rho(i_chan).Diff_firstder=[0 diff(rho(i_chan).Diff)]/(f(2)-f(1));
        rho(i_chan).Diff_secondder=[0 diff(rho(i_chan).Diff_firstder)]/(f(2)-f(1));

        mu=0.01*rho(i_chan).Diff_max; % this is for taking into account the fact that, due to the sampling of the curves, zeros may occur between two consecutive samples 

        %%%% looking for intersection points

        if ~isempty( find(rho(i_chan).Diff.*[0 rho(i_chan).Diff(1:end-1)] <=0 ,1) ) ||...
           ~isempty(intersect(find(rho(i_chan).Diff>=0), find(rho(i_chan).Diff<=mu)))             

            rho(i_chan).i_Diff_zeros=union(find(  rho(i_chan).Diff(1:end).*[0 rho(i_chan).Diff(1:end-1)] <=0  ),intersect(find(rho(i_chan).Diff>=0), find(rho(i_chan).Diff<=mu))); 
            rho(i_chan).f_Diff_zeros=f(rho(i_chan).i_Diff_zeros);

        else

            rho(i_chan).i_Diff_zeros=[];
            rho(i_chan).f_Diff_zeros=[];

        end            

        %%%% looking for local minima points

        if ~isempty(find( rho(i_chan).Diff_firstder(1:end-1).* rho(i_chan).Diff_firstder(2:end)<=0,1))...
           && ~isempty(find(rho(i_chan).Diff_secondder>0,1)) && ~isempty(find(rho(i_chan).Diff>0,1)) 
       
            i_cross_firstder=union( find((rho(i_chan).Diff_firstder(1:end-1).* rho(i_chan).Diff_firstder(2:end))<=0) , find(abs(rho(i_chan).Diff_firstder)<=mu) ) ;
            i_cross_firstder=intersect(find(rho(i_chan).Diff>0),i_cross_firstder);

            if ~isempty( intersect(i_cross_firstder,find(rho(i_chan).Diff_secondder>0)) ) 

                i_local_minima=intersect(i_cross_firstder,find(rho(i_chan).Diff_secondder>0));

                if ~isempty( intersect(i_local_minima, find( rho(i_chan).Diff<=epsilon*rho(i_chan).Diff_max) )),

                   i_local_minima_epsilon=intersect( i_local_minima, find( rho(i_chan).Diff<epsilon*rho(i_chan).Diff_max) )  ;
                   rho(i_chan).f_local_minima_epsilon=f(i_local_minima_epsilon);

                else

                   rho(i_chan).f_local_minima_epsilon=[];
                   rho(i_chan).i_local_minima_epsilon=[];

                end

                if ~isempty( intersect(i_local_minima, find( rho(i_chan).Diff<=epsilon_left*rho(i_chan).Diff_max) )),

                   i_local_minima_epsilon_left=intersect( i_local_minima, find( rho(i_chan).Diff<epsilon_left*rho(i_chan).Diff_max) )  ;
                   rho(i_chan).f_local_minima_epsilon_left=f(i_local_minima_epsilon_left);

                else

                   rho(i_chan).f_local_minima_epsilon_left=[];
                   rho(i_chan).i_local_minima_epsilon_left=[];   
                   
                end                        

            else

               rho(i_chan).f_local_minima_epsilon=[];
               rho(i_chan).i_local_minima_epsilon=[];

               rho(i_chan).f_local_minima_epsilon_left=[];
               rho(i_chan).i_local_minima_epsilon_left=[];

            end

        else

            rho(i_chan).f_local_minima_epsilon=[];
            rho(i_chan).i_local_minima_epsilon=[];

            rho(i_chan).f_local_minima_epsilon_left=[];
            rho(i_chan).i_local_minima_epsilon_left=[];

        end

        rho(i_chan).f_candidate_right=sort(union(rho(i_chan).f_Diff_zeros,rho(i_chan).f_local_minima_epsilon));
        rho(i_chan).f_candidate_left=sort(union(rho(i_chan).f_Diff_zeros,rho(i_chan).f_local_minima_epsilon_left));


        %%%% finding the boundaries of the expanded interval, f_a and f_b, among candidate frequencies for those channels 
        %%%% for which at list one window with positive rho value was found in the scanning phase 

        if isnan(rho(i_chan).rho_opt(1)),

            rho(i_chan).win_opt(:,2)=NaN;
            rho(i_chan).i_winopt(:,2)=NaN;
            rho(i_chan).rho_opt(2)=NaN;

        else

            %%%% left boundary

            if isempty(rho(i_chan).f_candidate_left),

                rho(i_chan).win_opt(1,2)=rho(i_chan).win_opt(1,1);
                rho(i_chan).i_winopt(1,2)=rho(i_chan).i_winopt(1,1);

            else

                if ~isempty(find(rho(i_chan).f_candidate_left<=rho(i_chan).win_opt(1,1),1)),

                    fa=rho(i_chan).f_candidate_left(find(rho(i_chan).f_candidate_left <= rho(i_chan).win_opt(1,1),1,'last'));
                    
                    %[tmp i_fa]=min(abs(f-fa));

                    rho(i_chan).win_opt(1,2)=round(fa*10)/10;
                    rho(i_chan).i_winopt(1,2)=find(f >= rho(i_chan).win_opt(1,2),1,'first');

                else

                    rho(i_chan).win_opt(1,2)=round(rho(i_chan).win_opt(1,1)*10)/10;
                    rho(i_chan).i_winopt(1,2)=rho(i_chan).i_winopt(1,1);

                end

            end

            %%%% right boundary

            if isempty(rho(i_chan).f_candidate_right),

                rho(i_chan).win_opt(2,2)=rho(i_chan).win_opt(2,1);
                rho(i_chan).i_winopt(2,2)=rho(i_chan).i_winopt(2,1);

            else

                if ~isempty(find(rho(i_chan).f_candidate_right>=rho(i_chan).win_opt(2,1),1)),

                    fb=rho(i_chan).f_candidate_right(find(rho(i_chan).f_candidate_right>=rho(i_chan).win_opt(2,1),1,'first'));
                    
                    %[tmp i_fb]=min(abs(f-fb));
                                        
                    rho(i_chan).win_opt(2,2)=round(fb*10)/10;                    
                    rho(i_chan).i_winopt(2,2)=find(f <= rho(i_chan).win_opt(2,2),1,'last');

                else

                    rho(i_chan).win_opt(2,2)=round(rho(i_chan).win_opt(2,1)*10)/10;
                    rho(i_chan).i_winopt(2,2)=find(rho(i_chan).win_opt(2,2),1,'last');

                end

            end

            %rho(i_chan).rho_opt(2)=sum(rho(i_chan).Diff(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2)))*(f(2)-f(1))/(rho(i_chan).win_opt(2,2)-rho(i_chan).win_opt(1,2));
            rho(i_chan).rho_opt(2)=round(trapz(f(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2)),rho(i_chan).Diff(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2)))/(rho(i_chan).win_opt(2,2)-rho(i_chan).win_opt(1,2))*1000)/1000;
            
        end         
    
    else
        
        rho(i_chan).win_opt(:,1)=NaN;
        rho(i_chan).i_winopt(:,1)=NaN;
        rho(i_chan).rho_opt(1)=NaN;
         
        rho(i_chan).win_opt(:,2)=NaN;
        rho(i_chan).i_winopt(:,2)=NaN;
        rho(i_chan).rho_opt(2)=NaN;
         
    end
    %%%% computation of CAF and power values for channels for which at least one window with positive rho values was found in scanning phase 
    
    if ~isnan(rho(i_chan).rho_opt(2)),
        
        R_win=rho(i_chan).R(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2));
        R_win=R_win(:);

        T_win=rho(i_chan).T(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2));
        T_win=T_win(:);
        
        f_win=rho(i_chan).f(rho(i_chan).i_winopt(1,2):rho(i_chan).i_winopt(2,2));
        f_win=f_win(:);
        
        if par.algpar.CFcomp==1,
            
           rho(i_chan).CAF=round(trapz(f_win,R_win.*f_win)/trapz(f_win,R_win)*10)/10;
        
        elseif par.algpar.CFcomp==2,
            
           rho(i_chan).CAF=round(trapz(f_win,T_win.*f_win)/trapz(f_win,T_win)*10)/10;
            
        else
            
           rho(i_chan).CAF=round(trapz(f_win,abs(R_win-T_win).*f_win)/trapz(f_win,abs(R_win-T_win))*10)/10;
            
        end            
        
        rho(i_chan).ref_power=round(trapz(f_win,R_win)*1000)/1000;
        rho(i_chan).test_power=round(trapz(f_win,T_win)*1000)/1000;
        rho(i_chan).power_variation=round((rho(i_chan).test_power-rho(i_chan).ref_power)/rho(i_chan).ref_power*100*10)/10;
        
    else
        
        rho(i_chan).CAF=NaN;
        rho(i_chan).ref_power=NaN;
        rho(i_chan).test_power=NaN;
        rho(i_chan).power_variation=NaN;
        
    end
        
    
    %%%% inserting results in CRB matrix
    
    CRB.results{i_chan+1,4}=rho(i_chan).CAF;
    CRB.results{i_chan+1,5}=rho(i_chan).rho_opt(2);
    CRB.results{i_chan+1,6}=rho(i_chan).win_opt(1,2);
    CRB.results{i_chan+1,7}=rho(i_chan).win_opt(2,2);
    CRB.results{i_chan+1,8}=rho(i_chan).ref_power;
    CRB.results{i_chan+1,9}=rho(i_chan).test_power;
    CRB.results{i_chan+1,10}=rho(i_chan).power_variation;        
               
    CRB.results_num(i_chan,3)=CRB.results{i_chan+1,4};
    CRB.results_num(i_chan,4)=CRB.results{i_chan+1,5};
    CRB.results_num(i_chan,5)=CRB.results{i_chan+1,6};
    CRB.results_num(i_chan,6)=CRB.results{i_chan+1,7};
    CRB.results_num(i_chan,7)=CRB.results{i_chan+1,8};
    CRB.results_num(i_chan,8)=CRB.results{i_chan+1,9};
    CRB.results_num(i_chan,9)=CRB.results{i_chan+1,10};        
               
               
end   %%% end of cycle on channels




