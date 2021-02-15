Dates = {'0627' '0628' '0702' '0703' '0706' '0710' '0711' '0712' '0724' '0725' '0726'};
for dd=1:length(Dates)
    fprintf(1,'***************************************\n\nRUNNING KILOSORT2\n\n****************************\n')
    Input_folder = ['W:\users\JulieE\GiMo_65430_71300\Loggers\2018' Dates{dd} '\logger16\extracted_data'];
    Server_folder = ['W:\users\JulieE\GiMo_65430_71300\Loggers\2018' Dates{dd} '\logger16'];
    Output_folder = ['C:\Users\Dell Workstation\Documents\DataKilosort22018' Dates{dd}];
    
    csc2kilosort2(Input_folder,Output_folder,0,'win');
    mymaster_kilosort(Server_folder,Output_folder);
    close all
    [sdel,mdel,edel]=rmdir(Output_folder, 's');
end

