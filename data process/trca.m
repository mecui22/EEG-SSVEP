function result = trca(data,filters,targetNum,traindata_Allh,trca_SFs_FBs_group_neighbours)
% -------------------------------------------------------------------------
for chan = 1:size(data,2)
    bpdatah1(chan,:) = filtfilt(filters.B1,filters.A1,data(:,chan));
    bpdatah2(chan,:) = filtfilt(filters.B2,filters.A2,data(:,chan));
    bpdatah3(chan,:) = filtfilt(filters.B3,filters.A3,data(:,chan));
    bpdatah4(chan,:) = filtfilt(filters.B4,filters.A4,data(:,chan));
    bpdatah5(chan,:) = filtfilt(filters.B5,filters.A5,data(:,chan));
end
testdatah1 = bpdatah1;
testdatah2 = bpdatah2;
testdatah3 = bpdatah3;
testdatah4 = bpdatah4;
testdatah5 = bpdatah5;
% -------------------------------------------------------------------------
weights = [1:10].^(-0.5)+0;
w = 2;
% -------------------------------------------------------------------------
Xh1 = testdatah1';
Xh2 = testdatah2';
Xh3 = testdatah3';
Xh4 = testdatah4';
Xh5 = testdatah5';
for cond = 1:targetNum
    Y2h1 = (squeeze(traindata_Allh.traindatah1(:,:,cond)))';
    Y2h2 = (squeeze(traindata_Allh.traindatah2(:,:,cond)))';
    Y2h3 = (squeeze(traindata_Allh.traindatah3(:,:,cond)))';
    Y2h4 = (squeeze(traindata_Allh.traindatah4(:,:,cond)))';
    Y2h5 = (squeeze(traindata_Allh.traindatah5(:,:,cond)))';
    %
    SFsIndex=[1:targetNum]; % TRCA¿Õ¼äÂË²¨Æ÷×é
    %
    U1 = Xh1 * [trca_SFs_FBs_group_neighbours.SFsAllh1(:,SFsIndex)];
    V1 = Y2h1 * [trca_SFs_FBs_group_neighbours.SFsAllh1(:,SFsIndex)];
    rr1(cond)= corr2_new(U1,V1); 
    %
    U2 = Xh2 * [trca_SFs_FBs_group_neighbours.SFsAllh2(:,SFsIndex)];
    V2 = Y2h2 * [trca_SFs_FBs_group_neighbours.SFsAllh2(:,SFsIndex)];
    rr2(cond)= corr2_new(U2,V2); 
    %
    U3 = Xh3 * [trca_SFs_FBs_group_neighbours.SFsAllh3(:,SFsIndex)];
    V3 = Y2h3 * [trca_SFs_FBs_group_neighbours.SFsAllh3(:,SFsIndex)];
    rr3(cond)= corr2_new(U3,V3);
    %
    U4 = Xh4 * [trca_SFs_FBs_group_neighbours.SFsAllh4(:,SFsIndex)];
    V4 = Y2h4 * [trca_SFs_FBs_group_neighbours.SFsAllh4(:,SFsIndex)];
    rr4(cond)= corr2_new(U4,V4);
    %
    U5 = Xh5 * [trca_SFs_FBs_group_neighbours.SFsAllh5(:,SFsIndex)];
    V5 = Y2h5 * [trca_SFs_FBs_group_neighbours.SFsAllh5(:,SFsIndex)];
    rr5(cond)= corr2_new(U5,V5); 
    % 
end
rrr = weights(1)*sign(rr1).*abs(rr1).^w+weights(2)*sign(rr2).*abs(rr2).^w+weights(3)*sign(rr3).*abs(rr3).^w+weights(4)*sign(rr4).*abs(rr4).^w+weights(5)*sign(rr5).*abs(rr5).^w;
result = find(rrr==max(rrr));
end
% -------------------------------------------------------------------------