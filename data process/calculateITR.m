function ITR = calculateITR( N,P,T )

NMatrix = N*ones(size(P));

ITR = 1./T.*(log2(NMatrix)+P.*log2(P)+(1-P).*log2((1-P)./(N-1)));
ITR(P==0) = 1./T(P==0).*(log2(NMatrix(P==0))+(1-P(P==0)).*log2((1-P(P==0))./(N-1)));
ITR(P==1) = 1./T(P==1).*(log2(NMatrix(P==1))+P(P==1).*log2(P(P==1)));
end

