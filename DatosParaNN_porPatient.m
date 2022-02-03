%% extraer datos para NN y pasar .mat a .csv
clear
path=pwd;%'C:\Users\natyv\Documents\1 PRÁCTICA INDUSTRIAL\datos pacientes - copia\Training'; % ruta, si es la actual  poner path=pwd
ext='.mat'; % extension, si no se desea filtrar por extension poner ext=''
ar=ls(path);
data = [];
npacientes = 0;
suj = 'NF053_20130101';
for j=3:2:size(ar,1)-1
    cn=ar(j,:);
    cnIBIF=ar(j+1,:);
    [~,~,ex]=fileparts(cn);
    if (and(~isdir(fullfile(path,cn)),or(strcmpi(strtrim(ex),ext),isempty(ext))))
        disp(cn)
        disp(cnIBIF)
        load(cn)
        load(cnIBIF)
        patient = cell(length(cppall),1);
        if cn(1)=='P'
            class = ones(length(cppall),1);
        else
            class = zeros(length(cppall),1);
        end
        dataComp = [acflow mfdr oq sq freq h1h2 level]; %dataTrain completa
        npacientes=npacientes+1;
        dataComp = array2table(dataComp);
        dataComp.Properties.VariableNames = {'ACFL','MFDR','OQ','SQ','f0','H1H2','spl'};
        writetable(dataComp,[cn(1:17) '_Patient.csv']);
        disp('sgte sujeto')
    end
%    for i=1:size(data)
%    data(:,1) = cn(1:5);
end
disp('fin')
clear
%data.Properties.VariableNames = {'ACFL','MFDR','OQ','SQ','f0','H1H2','spl'};
%writetable(data,'AllPatientData.csv');