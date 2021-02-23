% function [y, ind1]= ccaCalculate(data, condY, ntarget, type,freqV)    
function  [ind,rho]= ccaCalculate_rho(data, condY, ntarget,freqV)    
%          [Q1,T11,perm1] = qr(data',0);    
%             rankX = sum(abs(diag(T11)) > eps(abs(T11(1)))*n{i});
          for i = 1:ntarget     
%               [~,~,rr1{i},~,~] = canoncorr(data',condY{i}); 
              [~,~,rr1{i},~,~] = canoncorr(data,condY{i}); 
              r1(i) = rr1{i}(1,1);
          end
          [rho,ind] = max(r1);
%           y = (freqV(ind) == type)
          ind = freqV(ind);
end 