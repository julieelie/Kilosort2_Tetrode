Dates = {'0116' '0117' '0118' '0119' '0120' '0123' '0124' '0125''0128'  '0129' '0130' '0131'};
for dd=1:length(Dates)
    fprintf(1,'***************************************\n\nRUNNING KILOSORT2\n\n****************************\n')
    Input_folder = ['Z:\users\JulieE\LMC\LMC_HoHa\logger\2019' Dates{dd} '\Logger16\extracted_data'];
    Server_folder = ['Z:\users\JulieE\LMC\LMC_HoHa\logger\2019' Dates{dd} '\Logger16'];
    Output_folder = ['C:\Users\Dell Workstation\Documents\DataKilosort22019' Dates{dd}];
    
    csc2kilosort2(Input_folder,Output_folder,0,'win');
    mymaster_kilosort(Server_folder,Output_folder);
    close all
    [sdel,mdel,edel]=rmdir(Output_folder, 's');
end


