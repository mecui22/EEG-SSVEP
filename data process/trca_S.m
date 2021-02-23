function S = trca_S(X)
% Task-related component analysis (TRCA)
% X : eeg data (Num of channels * num of sample points * number of trials)

nChans  = size(X,1);
nTrials = size(X,3);
S = zeros(nChans, nChans);
% Computation of correlation matrices
for trial_i = 1:1:nTrials
    for trial_j = 1:1:nTrials
    %if trial_i ~= trial_j
        x_i = X(:, :, trial_i);
        x_j = X(:, :,trial_j);
        S = S + x_i*x_j';
    %end %if
    end % trial_j
end % trial_i

