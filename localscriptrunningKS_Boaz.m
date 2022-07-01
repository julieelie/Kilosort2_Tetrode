fprintf(1,'***************************************\n\nRUNNING KILOSORT2\n\n****************************\n')
Input_folder = 'D:\Logger data\11152021\neurologgers\logger19\extracted_data';
Server_folder = 'D:\Logger data\11152021\neurologgers\logger19\';
Output_folder = 'C:\Users\Dell Workstation\Documents\DataKilosort22019\11152021';
    
csc2kilosort2(Input_folder,Output_folder,0,'win');
mymaster_kilosort(Server_folder,Output_folder);
close all
[sdel,mdel,edel]=rmdir(Output_folder, 's');


