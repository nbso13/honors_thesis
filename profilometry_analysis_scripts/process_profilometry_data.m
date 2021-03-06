%% Processing Data
clear
close all
%date - July 15 2021
%% Load data
file_names = {"210310_sueded_cuddle_gel_11_100_grams"};
gel_id = [1]; %1 if gel 0 if nah

for index = 1:length(file_names)
    close all
    clearvars -except file_names gel_id index
    
    %macros
    GEL = gel_id(index);
    file_name = file_names{index};
    cd ../../csv_data;
    file_list = dir;
    starting_row = 19;
    x_res_row = 3;
    y_res_row = 4;
    z_res_row = 5;
    res_col = 1;
    title_str = file_name;
    
    %picking out pertainent files
    for file = 1:size(file_list,1)
        file_logit(file) = (contains(file_list(file).name, 'csv'))&(contains(file_list(file).name, file_name));
    end
    target_file = file_list(logical(file_logit));
    
    %reading data
    temp_data  = csvread(target_file(1).name, starting_row, 1);
    %read in resolutions from spreadsheet, put them into resolution cell -
    %x, y, z.
    temp_data_res = csvread(target_file(1).name, x_res_row, res_col, [x_res_row res_col z_res_row res_col]);
    
    %samp_freq = 1/(x_res/1000); % once every 2.5 microns
    temp_data_filtered = temp_data;%filter2(fir1(10,0.6), temp_data);
    
    x_res = temp_data_res(1,1)/1000;
    y_res = temp_data_res(2,1)/1000;
    z_res = temp_data_res(3,1)/1000; % all in mms
    x_axis = linspace(0, x_res*(size(temp_data,1)-1), size(temp_data_filtered,1));
    y_axis = linspace(0, y_res*(size(temp_data,2)-1), size(temp_data_filtered,2));
    new_window = temp_data_filtered;
    new_window = new_window./1000;
    
    cd ../bensmaia_gelsight_scripts/profilometry_analysis_scripts
    
    %% turning csv data into 3xn matrix of x,y,z points
    y_axis = y_axis'; x_axis = x_axis';
    y_size = size(y_axis, 1); x_size = size(x_axis, 1);
    prof = struct;
    prof.profile = new_window';
    prof.x_res = x_res;
    prof.y_res = y_res;
    prof.z_res = z_res;
    prof.x_axis = x_axis';
    prof.y_axis = y_axis';
    filename = strcat(file_name, "_processed.mat");
    visualizeProfile(prof);
    
    cd ../../mwe_data/sim_data
    if GEL
        gel = prof;
        save(filename, "gel");
    else
        no_gel = prof;
        save(filename, "no_gel");
    end
    
    cd ../../bensmaia_gelsight_scripts/profilometry_analysis_scripts
    
    [prof] = processAndUpdate(filename, GEL);
    
end
