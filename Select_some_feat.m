%% Ps
TrainPs=[dataTrain.Ps_mean dataTrain.Ps_median dataTrain.Ps_p5 dataTrain.Ps_kurt dataTrain.Ps_std];
TrainPs_norm = zscore(TrainPs);

TrainPs=array2table(TrainPs);
TrainPs.Properties.VariableNames={'Ps_mean', 'Ps_median', 'Ps_p5','Ps_kurt', 'Ps_std'};
TrainPs=[dataTrainEX TrainPs];
TrainPs_norm=array2table(TrainPs_norm);
TrainPs_norm.Properties.VariableNames={'Ps_mean_norm', 'Ps_median_norm', 'Ps_p5_norm','Ps_kurt_norm', 'Ps_std_norm'};
TrainPs_norm=[dataTrainEX_norm TrainPs_norm];


TestPs=[dataTest.Ps_mean dataTest.Ps_median dataTest.Ps_p5 dataTest.Ps_kurt dataTest.Ps_std];
TestPs_norm = zscore(TestPs);

TestPs=array2table(TestPs);
TestPs.Properties.VariableNames={'Ps_mean', 'Ps_median', 'Ps_p5','Ps_kurt', 'Ps_std'};
TestPs=[dataTestEX TestPs];
TestPs_norm=array2table(TestPs_norm);
TestPs_norm.Properties.VariableNames={'Ps_mean_norm', 'Ps_median_norm', 'Ps_p5_norm','Ps_kurt_norm', 'Ps_std_norm'};
TestPs_norm=[dataTestEX_norm TestPs_norm];


%% Pc
TrainPc=[dataTrain.Pc_mean dataTrain.Pc_median dataTrain.Pc_p5 dataTrain.Pc_kurt dataTrain.Pc_std];
TrainPc_norm = zscore(TrainPc);

TrainPc=array2table(TrainPc);
TrainPc.Properties.VariableNames={'Pc_mean', 'Pc_median', 'Pc_p5','Pc_kurt', 'Pc_std'};
TrainPc=[dataTrainEX TrainPc];
TrainPc_norm=array2table(TrainPc_norm);
TrainPc_norm.Properties.VariableNames={'Pc_mean_norm', 'Pc_median_norm', 'Pc_p5_norm','Pc_kurt_norm', 'Pc_std_norm'};
TrainPc_norm=[dataTrainEX_norm TrainPc_norm];


TestPc=[dataTest.Pc_mean dataTest.Pc_median dataTest.Pc_p5 dataTest.Pc_kurt dataTest.Pc_std];
TestPc_norm = zscore(TestPc);

TestPc=array2table(TestPc);
TestPc.Properties.VariableNames={'Pc_mean', 'Pc_median', 'Pc_p5','Pc_kurt', 'Pc_std'};
TestPc=[dataTestEX TestPc];
TestPc_norm=array2table(TestPc_norm);
TestPc_norm.Properties.VariableNames={'Pc_mean_norm', 'Pc_median_norm', 'Pc_p5_norm','Pc_kurt_norm', 'Pc_std_norm'};
TestPc_norm=[dataTestEX_norm TestPc_norm];

%% aCT y aTA
Train_aCTTA=[dataTrain.aTA_mean dataTrain.aTA_median dataTrain.aTA_p5 dataTrain.aTA_kurt dataTrain.aTA_std dataTrain.aCT_mean dataTrain.aCT_median dataTrain.aCT_p5 dataTrain.aCT_kurt dataTrain.aCT_std];
Train_aCTTA_norm = zscore(Train_aCTTA);

Train_aCTTA=array2table(Train_aCTTA);
Train_aCTTA.Properties.VariableNames={'aTA_mean', 'aTA_median', 'aTA_p5','aTA_kurt', 'aTA_std', 'aCT_mean', 'aCT_median', 'aCT_p5','aCT_kurt', 'aCT_std'};
Train_aCTTA=[dataTrainEX Train_aCTTA];
Train_aCTTA_norm=array2table(Train_aCTTA_norm);
Train_aCTTA_norm.Properties.VariableNames={'aTA_mean_norm', 'aTA_median_norm', 'aTA_p5_norm','aTA_kurt_norm', 'aTA_std_norm', 'aCT_mean_norm', 'aCT_median_norm', 'aCT_p5_norm','aCT_kurt_norm', 'aCT_std_norm'};
Train_aCTTA_norm=[dataTrainEX_norm Train_aCTTA_norm];


Test_aCTTA=[dataTest.aTA_mean dataTest.aTA_median dataTest.aTA_p5 dataTest.aTA_kurt dataTest.aTA_std dataTest.aCT_mean dataTest.aCT_median dataTest.aCT_p5 dataTest.aCT_kurt dataTest.aCT_std];
Test_aCTTA_norm = zscore(Test_aCTTA);

Test_aCTTA=array2table(Test_aCTTA);
Test_aCTTA.Properties.VariableNames={'aTA_mean', 'aTA_median', 'aTA_p5','aTA_kurt', 'aTA_std', 'aCT_mean', 'aCT_median', 'aCT_p5','aCT_kurt', 'aCT_std'};
Test_aCTTA=[dataTestEX Test_aCTTA];
Test_aCTTA_norm=array2table(Test_aCTTA_norm);
Test_aCTTA_norm.Properties.VariableNames={'aTA_mean_norm', 'aTA_median_norm', 'aTA_p5_norm','aTA_kurt_norm', 'aTA_std_norm', 'aCT_mean_norm', 'aCT_median_norm', 'aCT_p5_norm','aCT_kurt_norm', 'aCT_std_norm'};
Test_aCTTA_norm=[dataTestEX_norm Test_aCTTA_norm];

%% testeo
%[predictResponse,scores] = predict(LinearSVM_aCTTA.ClassificationSVM, Test_aCTTA(:, 3:23));
[predictResponse,scores] = predict(LinearSVM_aCTTA_norm.ClassificationSVM, [Test_aCTTA_norm(:, 4) Test_aCTTA_norm(:, 7:23)]);
%[predictResponse,scores] = predict(SubspaceDiscriminant.ClassificationEnsemble, [datatest(:,6) datatest(:,11) datatest(:,40) datatest(:,48) datatest(:,51)]);
scores=scores(:,2);
%editar el comado acá y luego copiar y pegar en comand window para usar la función summaryOffPerf
[sens, spec, ppv, npv, acc, fscore, AUC, str,optimalthresh] = summaryOfPerf(dataTest.class, scores, 1,  [], 1, 1, [],[])
