function [traindata_Allh, trca_SFs_FBs_group_neighbours] = trcaTrain(data)
for ii = 1:size(data,4)
    for cond = 1:size(data,3)
        for chan = 1:size(data,2)
            downsdata = squeeze(data(:,chan,cond,ii));
            bpdatah1(chan,:,cond,ii) = bp40_FB1(downsdata,250,1);
            bpdatah2(chan,:,cond,ii) = bp40_FB1(downsdata,250,2);
            bpdatah3(chan,:,cond,ii) = bp40_FB1(downsdata,250,3);
            bpdatah4(chan,:,cond,ii) = bp40_FB1(downsdata,250,4);
            bpdatah5(chan,:,cond,ii) = bp40_FB1(downsdata,250,5);
        end
    end
end
% -------------------------------------------------------------------------
%
traindatah1 = squeeze(mean(bpdatah1,4)); % 模板
trca_X_All = squeeze(bpdatah1(:,:,:,:));
X1 = trca_X_All(:,:);
X1 = X1 - repmat(mean(X1,2),1,size(X1,2));
Q_All = X1*X1';% 协方差，用40类所有trial数据
for qq = 1:size(data,3)
    trca_X = squeeze(bpdatah1(:,:,qq,:));
    S = trca_S(trca_X);%相关系数矩阵，用当前类所有trial
    [V,D] = eig(Q_All\S);
    SFsh1(:,1:9,qq) = V;
end
%
traindatah2 = squeeze(mean(bpdatah2,4)); % 模板
trca_X_All = squeeze(bpdatah2(:,:,:,:));
X1 = trca_X_All(:,:);
X1 = X1 - repmat(mean(X1,2),1,size(X1,2));
Q_All = X1*X1';% 协方差，用40类所有trial数据
for qq = 1:size(data,3)
    trca_X = squeeze(bpdatah2(:,:,qq,:));
    S = trca_S(trca_X);%相关系数矩阵，用当前类所有trial
    [V,D] = eig(Q_All\S);
    SFsh2(:,1:9,qq) = V;
end
%
traindatah3 = squeeze(mean(bpdatah3,4)); % 模板
trca_X_All = squeeze(bpdatah3(:,:,:,:));
X1 = trca_X_All(:,:);
X1 = X1 - repmat(mean(X1,2),1,size(X1,2));
Q_All = X1*X1';% 协方差，用40类所有trial数据
for qq = 1:size(data,3)
    trca_X = squeeze(bpdatah3(:,:,qq,:));
    S = trca_S(trca_X);%相关系数矩阵，用当前类所有trial
    [V,D] = eig(Q_All\S);
    SFsh3(:,1:9,qq) = V;
end
%
traindatah4 = squeeze(mean(bpdatah4,4)); % 模板
trca_X_All = squeeze(bpdatah4(:,:,:,:));
X1 = trca_X_All(:,:);
X1 = X1 - repmat(mean(X1,2),1,size(X1,2));
Q_All = X1*X1';% 协方差，用40类所有trial数据
for qq = 1:size(data,3)
    trca_X = squeeze(bpdatah4(:,:,qq,:));
    S = trca_S(trca_X);%相关系数矩阵，用当前类所有trial
    [V,D] = eig(Q_All\S);
    SFsh4(:,1:9,qq) = V;
end
%
traindatah5 = squeeze(mean(bpdatah5,4)); % 模板
trca_X_All = squeeze(bpdatah5(:,:,:,:));
X1 = trca_X_All(:,:);
X1 = X1 - repmat(mean(X1,2),1,size(X1,2));
Q_All = X1*X1';% 协方差，用40类所有trial数据
for qq = 1:size(data,3)
    trca_X = squeeze(bpdatah5(:,:,qq,:));
    S = trca_S(trca_X);%相关系数矩阵，用当前类所有trial
    [V,D] = eig(Q_All\S);
    SFsh5(:,1:9,qq) = V;
end
% -------------------------------------------------------------------------
for cond = 1:size(data,3)
    SFsAllh1(:,cond) = SFsh1(:,1,cond); % 第1个TRCA滤波器
    SFsAllh2(:,cond) = SFsh2(:,1,cond);
    SFsAllh3(:,cond) = SFsh3(:,1,cond);
    SFsAllh4(:,cond) = SFsh4(:,1,cond);
    SFsAllh5(:,cond) = SFsh5(:,1,cond);
end
traindata_Allh.traindatah1 = traindatah1;
traindata_Allh.traindatah2 = traindatah2;
traindata_Allh.traindatah3 = traindatah3;
traindata_Allh.traindatah4 = traindatah4;
traindata_Allh.traindatah5 = traindatah5;
%
trca_SFs_FBs_group_neighbours.SFsAllh1 = SFsAllh1;
trca_SFs_FBs_group_neighbours.SFsAllh2 = SFsAllh2;
trca_SFs_FBs_group_neighbours.SFsAllh3 = SFsAllh3;
trca_SFs_FBs_group_neighbours.SFsAllh4 = SFsAllh4;
trca_SFs_FBs_group_neighbours.SFsAllh5 = SFsAllh5;
end