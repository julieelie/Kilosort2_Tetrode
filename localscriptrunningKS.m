Dates = {'0116'};
for dd=1:length(Dates)
    fprintf(1,'***************************************\n\nRUNNING KILOSORT2\n\n****************************\n')
%     Input_folder = ['W:\users\JulieE\GiMo_65430_71300\Loggers\2018' Dates{dd} '\logger16\extracted_data'];
%     Server_folder = ['W:\users\JulieE\GiMo_65430_71300\Loggers\2018' Dates{dd} '\logger16'];
    Input_folder = ['Z:\users\JulieE\LMC\LMC_HoHa\logger\2019' Dates{dd} '\logger20\extracted_data'];
    Server_folder = ['Z:\users\JulieE\LMC\LMC_HoHa\logger\2019' Dates{dd} '\logger20'];
    Output_folder = ['C:\Users\Dell Workstation\Documents\DataKilosort22019' Dates{dd}];
    
    csc2kilosort2(Input_folder,Output_folder,0,'win');
    mymaster_kilosort(Server_folder,Output_folder);
    close all
    [sdel,mdel,edel]=rmdir(Output_folder, 's');
end


%% KS on Hermina's data
Server_folder = 'Z:\users\JulieE\KS_Hermina';
Output_folder = 'C:\Users\Dell Workstation\Documents\DataKilosort2';
mymaster_kilosort_HR(Server_folder,Output_folder);

