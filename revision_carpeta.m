%% revisión carpeta
clear
path=pwd;%'C:\Users\natyv\Documents\1 PRÁCTICA INDUSTRIAL\datos pacientes - copia\Training'; % ruta, si es la actual  poner path=pwd
ext='.mat'; % extension, si no se desea filtrar por extension poner ext=''
ar=ls(path);
malos = '';
for j=3:2:size(ar,1)-1
    cn=ar(j,:);
    cnIBIF=ar(j+1,:);
    [~,~,ex]=fileparts(cn);
    if (and(~isdir(fullfile(path,cn)),or(strcmpi(strtrim(ex),ext),isempty(ext))))
        if ~(strcmp(cn(1:17),cnIBIF(1:17)))
            disp('mal')
            malos = [malos ', ' cn ', ' cnIBIF '\n'];
        end
    end
end
