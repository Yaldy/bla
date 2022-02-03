%%% Para correr este script hay que estar en la carpeta 
%% Data Training
clear
path=pwd;%'C:\Users\natyv\Documents\1 PRÁCTICA INDUSTRIAL\datos pacientes csv\Training'; % ruta, si es la actual  poner path=pwd
ext='.csv'; % extension, si no se desea filtrar por extension poner ext=''
ar=ls(path);
dataTrain = [];
%dataTrainEX = []; %SIN datos NN
t = 5; %extensión de las  ventanas de tiempo (min)
npacientes = 0;
%parpool;
for j=3:2:size(ar,1)-1
    
    cn=ar(j+1,:);
    cnNN=ar(j,:);
    [~,~,ex]=fileparts(cn);
    
    %isdir(cn)
    if (and(~isdir(fullfile(path,cn)),or(strcmpi(strtrim(ex),ext),isempty(ext))))
        disp(cn)
        disp(cnNN)
        
        T1=readtable(cn,'FileType','text');
        T2=readtable(cnNN,'FileType','text');
        
        
        if cn(1)=='P'
             class = ones(length(T1.ACFL),1);
        else
            class = zeros(length(T1.ACFL),1);
        end
        class = array2table(class);
        class.Properties.VariableNames('class');
        
        level = T1.spl;
        
        LogAcflow = zeros(length(T1.ACFL),1);
        LogAcflowNorm = zeros(length(T1.ACFL),1);
        for i=1:length(T1.ACFL)
            LogAcflow(i) = 20*log10(abs(T1.ACFL(i))+eps);
            LogAcflowNorm(i) = level(i)/LogAcflow(i);
        end
        LogAcflow = array2table(LogAcflow);
        LogAcflow.Properties.VariableNames('LogAcflow');
        LogAcflowNorm = array2table(LogAcflowNorm);
        LogAcflowNorm.Properties.VariableNames('LogAcflowNorm');
        
        
        LogMfdr = zeros(length(T1.MFDR),1);
        LogMfdrNorm = zeros(length(T1.MFDR),1);
        for i=1:length(T1.ACFL)
            LogMfdr(i) = 20*log10(abs(T1.MFDR(i))+eps);
            LogMfdrNorm(i) = level(i)/LogMfdr(i);
        end
        LogMfdr = array2table(LogMfdr);
        LogMfdr.Properties.VariableNames('LogMfdr');
        LogMfdrNorm = array2table(LogMfdrNorm);
        LogMfdrNorm.Properties.VariableNames('LogMfdrNorm');
        
        T1=[LogAcflow LogAcflowNorm LogMfdr LogMfdrNorm T1(:,2:10)];
        T1=[class T1];
        
        totTime = length(T1.ACFL)*0.05*60;
        totFram = floor(length(T1.ACFL)/(1200*t)); %revisar round, si redondea para arriba no va a funcionar:(
        
        LogAcflow_p5 = zeros(totFram,1);
        LogAcflow_median = zeros(totFram,1);
        LogAcflow_mean = zeros(totFram,1);
        LogAcflow_kurt = zeros(totFram,1);
        LogAcflowNorm_p5 = zeros(totFram,1);
        LogAcflowNorm_median = zeros(totFram,1);
        LogAcflowNorm_mean = zeros(totFram,1);
        LogAcflowNorm_kurt = zeros(totFram,1);
        LogMfdr_median = zeros(totFram,1);
        LogMfdrNorm_median = zeros(totFram,1);
        Acflow_p5 = zeros(totFram,1);
        Acflow_median = zeros(totFram,1);        
        Acflow_mean = zeros(totFram,1);
        H1H2_p5 = zeros(totFram,1);
        H1H2_kurt = zeros(totFram,1);
        hrf_kurt = zeros(totFram,1);
        mfdr_median = zeros(totFram,1);
        patient = cell(totFram,1);
        statT2=[];
        c=0;
       
        for i=1:totFram 
            if sum(T1.voiced(((i-1)*1200*t)+1:(i*1200*t)))>=30
                c=c+1;
                window = T1(((i-1)*1200*t)+1:(i*1200*t),:);
                voiced = logical(window.voiced);
                window = window(voiced,:);
                LogAcflow_p5(c) = prctile(window.LogAcflow,5);
                LogAcflow_median(c) = median(window.LogAcflow,'omitnan');
                LogAcflow_mean(c) = mean(window.LogAcflow,'omitnan');
                LogAcflow_kurt(c) = kurtosis(window.LogAcflow);
                LogAcflowNorm_p5(c) = prctile(window.LogAcflowNorm,5);
                LogAcflowNorm_median(c) = median(window.LogAcflowNorm,'omitnan');
                LogAcflowNorm_mean(c) = mean(window.LogAcflowNorm,'omitnan');
                LogAcflowNorm_kurt(c) = kurtosis(window.LogAcflowNorm);
                Acflow_p5(c) = prctile(window.ACFL,5);
                Acflow_median(c) = median(window.ACFL,'omitnan');;        
                Acflow_mean(c) = mean(window.ACFL,'omitnan');
                H1H2_p5(c) = prctile(window.H1H2,5);
                H1H2_kurt(c) = kurtosis(window.H1H2);
                hrf_kurt(c) = kurtosis(window.hrf);
                mfdr_median(c) = median(window.MFDR,'omitnan');;
                LogMfdr_median(c) = median(window.LogMfdr,'omitnan');
                LogMfdrNorm_median(c) = median(window.LogMfdrNorm,'omitnan');
                patient(c) = {cn(1:5)};
                
                window2 = T2(((i-1)*1200*t)+1:(i*1200*t),:);
                window2 = window2(voiced,:);
                stat = [mean(table2array(window2),'omitnan') median(table2array(window2),'omitnan') prctile(table2array(window2),5) kurtosis(table2array(window2)) std(table2array(window2),'omitnan')];
                statT2 = [statT2; stat];
                            
            end
        end

        if c==0
            statT2 = zeros(0,20);
        end

        newData = [T1.class(1:c,:) LogAcflow_p5(1:c) LogAcflow_median(1:c) LogAcflow_mean(1:c) LogAcflow_kurt(1:c) LogAcflowNorm_p5(1:c) LogAcflowNorm_median(1:c) LogAcflowNorm_mean(1:c) LogAcflowNorm_kurt(1:c) Acflow_p5(1:c) Acflow_median(1:c) Acflow_mean(1:c) H1H2_p5(1:c) H1H2_kurt(1:c) hrf_kurt(1:c) mfdr_median(1:c) LogMfdr_median(1:c) LogMfdrNorm_median(1:c) statT2];
        newData = array2table(newData);
        newData = [patient(1:c) newData];
        %newDataEX = [T1.class(1:c,:) LogAcflow_p5(1:c) LogAcflow_median(1:c) LogAcflow_mean(1:c) LogAcflow_kurt(1:c) Acflow_p5(1:c) Acflow_median(1:c) Acflow_mean(1:c) H1H2_p5(1:c) H1H2_kurt(1:c) hrf_kurt(1:c) mfdr_median(1:c)];
        %newDataEX = array2table(newDataEX);
        %newDataEX = [patient(1:c) newDataEX];
        
        %disp()
        dataTrain = [dataTrain; newData];       
        %dataTestEX = [dataTestEX; newDataEX];
        
        npacientes=npacientes+1;
        disp('sgte sujeto')
   end
   
end
dataTrain.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5', 'LogAcflow_median', 'LogAcflow_mean', 'LogAcflow_kurt', 'LogAcflowNorm_p5', 'LogAcflowNorm_median', 'LogAcflowNorm_mean', 'LogAcflowNorm_kurt','Acflow_p5', 'Acflow_median', 'Acflow_mean', 'H1H2_p5', 'H1H2_kurt', 'hrf_kurt', 'mfdr_median', 'LogMfdr_median', 'LogMfdrNorm_median','Ps_mean', 'Pc_mean', 'aTA_mean', 'aCT_mean','Ps_median', 'Pc_median', 'aTA_median', 'aCT_median','Ps_p5', 'Pc_p5', 'aTA_p5', 'aCT_p5','Ps_kurt', 'Pc_kurt', 'aTA_kurt', 'aCT_kurt','Ps_std', 'Pc_std', 'aTA_std', 'aCT_std'};
dataTrainEX = dataTrain(:,1:16);
disp('listo:)')

%% Data Testeo
path=pwd;%'C:\Users\natyv\Documents\1 PRÁCTICA INDUSTRIAL\datos pacientes csv\Training'; % ruta, si es la actual  poner path=pwd
ext='.csv'; % extension, si no se desea filtrar por extension poner ext=''
ar=ls(path);
dataTest = [];
%dataTestEX = []; %SIN datos NN
t = 5; %extensión de las  ventanas de tiempo (min)
npacientes = 0;
%parpool;
for j=3:2:size(ar,1)-1
    
    cn=ar(j+1,:);
    cnNN=ar(j,:);
    [~,~,ex]=fileparts(cn);
    
    %isdir(cn)
    if (and(~isdir(fullfile(path,cn)),or(strcmpi(strtrim(ex),ext),isempty(ext))))
        disp(cn)
        disp(cnNN)
        
        T1=readtable(cn,'FileType','text');
        T2=readtable(cnNN,'FileType','text');
        
        
        if cn(1)=='P'
             class = ones(length(T1.ACFL),1);
        else
            class = zeros(length(T1.ACFL),1);
        end
        class = array2table(class);
        class.Properties.VariableNames('class');
        
        level = T1.spl;
        
        LogAcflow = zeros(length(T1.ACFL),1);
        LogAcflowNorm = zeros(length(T1.ACFL),1);
        for i=1:length(T1.ACFL)
            LogAcflow(i) = 20*log10(abs(T1.ACFL(i))+eps);
            LogAcflowNorm(i) = level(i)/LogAcflow(i);
        end
        LogAcflow = array2table(LogAcflow);
        LogAcflow.Properties.VariableNames('LogAcflow');
        LogAcflowNorm = array2table(LogAcflowNorm);
        LogAcflowNorm.Properties.VariableNames('LogAcflowNorm');
        
        LogMfdr = zeros(length(T1.MFDR),1);
        LogMfdrNorm = zeros(length(T1.MFDR),1);
        for i=1:length(T1.ACFL)
            LogMfdr(i) = 20*log10(abs(T1.MFDR(i))+eps);
            LogMfdrNorm(i) = level(i)/LogMfdr(i);
        end
        LogMfdr = array2table(LogMfdr);
        LogMfdr.Properties.VariableNames('LogMfdr');
        LogMfdrNorm = array2table(LogMfdrNorm);
        LogMfdrNorm.Properties.VariableNames('LogMfdrNorm');
        
        T1=[LogAcflow LogAcflowNorm LogMfdr LogMfdrNorm T1(:,2:10)];
        T1=[class T1];
        
        totTime = length(T1.ACFL)*0.05*60;
        totFram = floor(length(T1.ACFL)/(1200*t)); %revisar round, si redondea para arriba no va a funcionar:(
               
        LogAcflow_p5 = zeros(totFram,1);
        LogAcflow_median = zeros(totFram,1);
        LogAcflow_mean = zeros(totFram,1);
        LogAcflow_kurt = zeros(totFram,1);
        LogAcflowNorm_p5 = zeros(totFram,1);
        LogAcflowNorm_median = zeros(totFram,1);
        LogAcflowNorm_mean = zeros(totFram,1);
        LogAcflowNorm_kurt = zeros(totFram,1);
        LogMfdr_median = zeros(totFram,1);
        LogMfdrNorm_median = zeros(totFram,1);
        Acflow_p5 = zeros(totFram,1);
        Acflow_median = zeros(totFram,1);        
        Acflow_mean = zeros(totFram,1);
        H1H2_p5 = zeros(totFram,1);
        H1H2_kurt = zeros(totFram,1);
        hrf_kurt = zeros(totFram,1);
        mfdr_median = zeros(totFram,1);
        patient = cell(totFram,1);
        statT2=[];
        c=0;
        for i=1:totFram 
            if sum(T1.voiced(((i-1)*1200*t)+1:(i*1200*t)))>=30
                c=c+1;
                window = T1(((i-1)*1200*t)+1:(i*1200*t),:);
                voiced = logical(window.voiced);
                window = window(voiced,:);
                LogAcflow_p5(c) = prctile(window.LogAcflow,5);
                LogAcflow_median(c) = median(window.LogAcflow,'omitnan');
                LogAcflow_mean(c) = mean(window.LogAcflow,'omitnan');
                LogAcflow_kurt(c) = kurtosis(window.LogAcflow);
                LogAcflowNorm_p5(c) = prctile(window.LogAcflowNorm,5);
                LogAcflowNorm_median(c) = median(window.LogAcflowNorm,'omitnan');
                LogAcflowNorm_mean(c) = mean(window.LogAcflowNorm,'omitnan');
                LogAcflowNorm_kurt(c) = kurtosis(window.LogAcflowNorm);
                Acflow_p5(c) = prctile(window.ACFL,5);
                Acflow_median(c) = median(window.ACFL,'omitnan');;        
                Acflow_mean(c) = mean(window.ACFL,'omitnan');
                H1H2_p5(c) = prctile(window.H1H2,5);
                H1H2_kurt(c) = kurtosis(window.H1H2);
                hrf_kurt(c) = kurtosis(window.hrf);
                mfdr_median(c) = median(window.MFDR,'omitnan');;
                LogMfdr_median(c) = median(window.LogMfdr,'omitnan');
                LogMfdrNorm_median(c) = median(window.LogMfdrNorm,'omitnan');
                patient(c) = {cn(1:5)};
                    
                window2 = T2(((i-1)*1200*t)+1:(i*1200*t),:);
                window2 = window2(voiced,:);
                stat = [mean(table2array(window2),'omitnan') median(table2array(window2),'omitnan') prctile(table2array(window2),5) kurtosis(table2array(window2)) std(table2array(window2),'omitnan')];
                statT2 = [statT2; stat];
                            
            end
        end

        if c==0
            statT2 = zeros(0,20);
        end

        newData = [T1.class(1:c,:) LogAcflow_p5(1:c) LogAcflow_median(1:c) LogAcflow_mean(1:c) LogAcflow_kurt(1:c) LogAcflowNorm_p5(1:c) LogAcflowNorm_median(1:c) LogAcflowNorm_mean(1:c) LogAcflowNorm_kurt(1:c) Acflow_p5(1:c) Acflow_median(1:c) Acflow_mean(1:c) H1H2_p5(1:c) H1H2_kurt(1:c) hrf_kurt(1:c) mfdr_median(1:c) LogMfdr_median(1:c) LogMfdrNorm_median(1:c) statT2];
        newData = array2table(newData);
        newData = [patient(1:c) newData];
        %newDataEX = [T1.class(1:c,:) LogAcflow_p5(1:c) LogAcflow_median(1:c) LogAcflow_mean(1:c) LogAcflow_kurt(1:c) Acflow_p5(1:c) Acflow_median(1:c) Acflow_mean(1:c) H1H2_p5(1:c) H1H2_kurt(1:c) hrf_kurt(1:c) mfdr_median(1:c)];
        %newDataEX = array2table(newDataEX);
        %newDataEX = [patient(1:c) newDataEX];
        
        %disp()
        dataTest = [dataTest; newData];       
        %dataTestEX = [dataTestEX; newDataEX];
        
        
        
        
        npacientes=npacientes+1;
        disp('sgte sujeto')

   end
   
end
dataTest.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5', 'LogAcflow_median', 'LogAcflow_mean', 'LogAcflow_kurt', 'LogAcflowNorm_p5', 'LogAcflowNorm_median', 'LogAcflowNorm_mean', 'LogAcflowNorm_kurt','Acflow_p5', 'Acflow_median', 'Acflow_mean', 'H1H2_p5', 'H1H2_kurt', 'hrf_kurt', 'mfdr_median', 'LogMfdr_median', 'LogMfdrNorm_median','Ps_mean', 'Pc_mean', 'aTA_mean', 'aCT_mean','Ps_median', 'Pc_median', 'aTA_median', 'aCT_median','Ps_p5', 'Pc_p5', 'aTA_p5', 'aCT_p5','Ps_kurt', 'Pc_kurt', 'aTA_kurt', 'aCT_kurt','Ps_std', 'Pc_std', 'aTA_std', 'aCT_std'};
dataTestEX = dataTest(:,1:16);
disp('listo:)')
%dataTest.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5', 'LogAcflow_median', 'LogAcflow_mean', 'LogAcflow_kurt', 'Acflow_p5', 'Acflow_median', 'Acflow_mean', 'H1H2_p5', 'H1H2_kurt', 'hrf_kurt', 'mfdr_median' ,'Ps_mean', 'Pc_mean', 'aTA_mean', 'aCT_mean','Ps_median', 'Pc_median', 'aTA_median', 'aCT_median','Ps_p5', 'Pc_p5', 'aTA_p5', 'aCT_p5','Ps_kurt', 'Pc_kurt', 'aTA_kurt', 'aCT_kurt','Ps_std', 'Pc_std', 'aTA_std', 'aCT_std'};    
%% corregir los NaN
dataTrain = rmmissing(dataTrain);
dataTest = rmmissing(dataTest);
disp('yap')
%% train > test
if height(dataTest)>height(dataTrain)
    dataTrain1 = dataTrain;
    dataTrain = dataTest;
    dataTest = dataTrain1;
    disp('cambiado')
    clear dataTrain1
else
    disp('no cambia')
end
%% Normalización z
dataTrain_norm = zscore(table2array(dataTrain(:,3:33)));
dataTest_norm = zscore(table2array(dataTest(:,3:33)));
dataTrainEX_norm = zscore(table2array(dataTrainEX(:,3:13)));
dataTestEX_norm = zscore(table2array(dataTestEX(:,3:13)));

dataTrain_norm = array2table(dataTrain_norm);
dataTrain_norm = [dataTrain(:,1:2) dataTrain_norm];
dataTrain_norm.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5_norm', 'LogAcflow_median_norm', 'LogAcflow_mean_norm', 'LogAcflow_kurt_norm', 'Acflow_p5_norm', 'Acflow_median_norm', 'Acflow_mean_norm', 'H1H2_p5_norm', 'H1H2_kurt_norm', 'hrf_kurt_norm', 'mfdr_median_norm' ,'Ps_mean_norm', 'Pc_mean_norm', 'aTA_mean_norm', 'aCT_mean_norm','Ps_median_norm', 'Pc_median_norm', 'aTA_median_norm', 'aCT_median_norm','Ps_p5_norm', 'Pc_p5_norm', 'aTA_p5_norm', 'aCT_p5_norm','Ps_kurt_norm', 'Pc_kurt_norm', 'aTA_kurt_norm', 'aCT_kurt_norm','Ps_std_norm', 'Pc_std_norm', 'aTA_std_norm', 'aCT_std_norm'};    

dataTrainEX_norm = array2table(dataTrainEX_norm);
dataTrainEX_norm = [dataTrain(:,1:2) dataTrainEX_norm];
dataTrainEX_norm.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5_norm', 'LogAcflow_median_norm', 'LogAcflow_mean_norm', 'LogAcflow_kurt_norm', 'Acflow_p5_norm', 'Acflow_median_norm', 'Acflow_mean_norm', 'H1H2_p5_norm', 'H1H2_kurt_norm', 'hrf_kurt_norm', 'mfdr_median_norm'};    

dataTest_norm = array2table(dataTest_norm);
dataTest_norm = [dataTest(:,1:2) dataTest_norm];
dataTest_norm.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5_norm', 'LogAcflow_median_norm', 'LogAcflow_mean_norm', 'LogAcflow_kurt_norm', 'Acflow_p5_norm', 'Acflow_median_norm', 'Acflow_mean_norm', 'H1H2_p5_norm', 'H1H2_kurt_norm', 'hrf_kurt_norm', 'mfdr_median_norm' ,'Ps_mean_norm', 'Pc_mean_norm', 'aTA_mean_norm', 'aCT_mean_norm','Ps_median_norm', 'Pc_median_norm', 'aTA_median_norm', 'aCT_median_norm','Ps_p5_norm', 'Pc_p5_norm', 'aTA_p5_norm', 'aCT_p5_norm','Ps_kurt_norm', 'Pc_kurt_norm', 'aTA_kurt_norm', 'aCT_kurt_norm','Ps_std_norm', 'Pc_std_norm', 'aTA_std_norm', 'aCT_std_norm'};    

dataTestEX_norm = array2table(dataTestEX_norm);
dataTestEX_norm = [dataTest(:,1:2) dataTestEX_norm];
dataTestEX_norm.Properties.VariableNames={'patient', 'class', 'LogAcflow_p5_norm', 'LogAcflow_median_norm', 'LogAcflow_mean_norm', 'LogAcflow_kurt_norm', 'Acflow_p5_norm', 'Acflow_median_norm', 'Acflow_mean_norm', 'H1H2_p5_norm', 'H1H2_kurt_norm', 'hrf_kurt_norm', 'mfdr_median_norm'};    
%% partición tadatrain
dataTrainA=[dataTrain_norm(1:2387,:); dataTrain_norm(11180:12813,:)];
dataTrainB=[dataTrain_norm(2388:11179,:); dataTrain_norm(12812:21761,:)];

dataTrainEXA=[dataTrainEX_norm(1:2387,:); dataTrainEX_norm(11180:12813,:)];
dataTrainEXB=[dataTrainEX_norm(2388:11179,:); dataTrainEX_norm(12812:21761,:)];
%% exraer cierto feat %scrip aparte
TrainPs=[dataTrain.Ps_mean dataTrain.Ps_median dataTrain.Ps_p5 dataTrain.Ps_kurt dataTrain.Ps_std];
TrainPs=array2table(TrainPs);
TrainPs.Properties.VariableNames={'Ps_mean_norm', 'Ps_median_norm', 'Ps_p5_norm','Ps_kurt_norm', 'Ps_std_norm'};
TrainPs=[dataTrainEX TrainPs];

TestPs=[dataTest.Ps_mean dataTest.Ps_median dataTest.Ps_p5 dataTest.Ps_kurt dataTest.Ps_std];
TestPs=array2table(TestPs);
TestPs.Properties.VariableNames={'Ps_mean_norm', 'Ps_median_norm', 'Ps_p5_norm','Ps_kurt_norm', 'Ps_std_norm'};
TestPs=[dataTestEX TestPs];
%% testeo
[predictResponse,scores] = predict(LinearSVM_Ps_norm.ClassificationSVM, [TestPs(:, 3) TestPs(:, 6:17)]);
%[predictResponse,scores] = predict(SubspaceDiscriminant.ClassificationEnsemble, [datatest(:,6) datatest(:,11) datatest(:,40) datatest(:,48) datatest(:,51)]);
scores=scores(:,2);
%editar el comado acá y luego copiar y pegar en comand window para usar la función summaryOffPerf
[sens, spec, ppv, npv, acc, fscore, AUC, str,optimalthresh] = summaryOfPerf(dataTest.class, scores, 1,  [], 1, 1, [],[])
malEtiq = sum(~(predictResponse==dataTest.class)) % cantidad de datos mal clasificados