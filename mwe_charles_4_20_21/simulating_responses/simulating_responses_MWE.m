%% Main Script for Analysis
% Author: Nick Ornstein
% Group: Bensmaia Lab
% Project: Gelsight Profilometry
% Date: March 31 2020
% cd ~/Documents/bensmaia_lab/bensmaia_gelsight_scripts/profilometry_analysis_scripts
clear
close all
local_data_path_str = "../../../mwe_data/";
local_path_back = "/../bensmaia_gelsight_scripts/mwe_charles_4_20_21/simulating_responses";
addpath('helper_functions')
cd helper_functions/touchsim_gelsight
setup_path;
cd ../..

load('colorscheme')
%% set vars
figure_dir = 0; % do not save figures

PC_COLOR =  [255 127 0]/255;
RA_COLOR =  [30 120 180]/255;
SA_COLOR = [50 160 40]/255;

aff_colors = {PC_COLOR, RA_COLOR, SA_COLOR};

cd(strcat(local_data_path_str, "neural_data"))
load("RawPAFData")
load("TextureNames")
cd(strcat("..", local_path_back));

% good_neurons = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 22 25 28 33 34];
good_neurons = 1:39;
% texture_nums = [31, 25, 45, 7, 4, 42, 33, 9, 21, 38, 44]; %  49, 50, 55
texture_nums = [45, 4, 31, 42, 7, 38, 9]; %100 gram textures
% texture_nums = [7, 50];
% texture_nums = [25, 45, 50];
% texture_nums = [49, 50, 55];

%pull names
for i = 1:length(htxt_name)
    texture_names(i) = string(htxt_name{i});
end

% filename_gel = ["210223_velvet_gel_7_processed", ...
%     "201118_corduroy_35_gel_trimmed", ...
%     "210226_blizzard_fleece_gel_7_200_grams_processed", ...
%     "210217_wool_blend_gel_7_processed", ...
%     "210209_hucktowel_gel_11_processed",  ...
%     "210219_sueded_cuddle_gel_7_processed",...
%     "210423_gel_18_careerwear_flannel_200_grams_processed",...
%     "210423_gel_18_thick_corduroy_200_grams_processed", ...
%     "210423_gel_18_premier_velvet_200_grams_processed", ...
%     "210423_gel_18_velour_200_grams_processed", ...
%     "210423_gel_19_snowflake_knitside_200_grams_processed"];

%     
filename_gel = ["210304_blizzard_fleece_gel_11_100_grams_processed", ...
    "210304_hucktowel_gel_11_100_grams_processed", ...
    "210304_velvet_gel_11_100_grams_processed", ...
    "210310_sueded_cuddle_gel_11_100_grams_processed" ...
    "210310_wool_blend_gel_11_100_grams_processed", ...
    "210428_velour_gel_19_100_grams_processed",...
    "210428_thick_corduroy_gel_19_100_grams_processed"]; % 100 gram
% filename_gel = ["210217_wool_blend_gel_7_processed",  "210223_1mm_grating_gel_11_processed"];
% filename_gel = ["201118_corduroy_35_gel_trimmed", ...
%     "210226_blizzard_fleece_gel_7_200_grams_processed", ...
%     "210223_1mm_grating_gel_11_processed"];
% filename_gel = ["210216_3mm_grating_gel_7_processed", ...
%     "210223_1mm_grating_gel_11_processed", ...
%     "210414_2mm_dots_gel_17_200_grams_processed",];


% filename_nogel = ["210121_velvet_no_gel_processed", ...
%     "201118_corduroy_no_gel_trimmed", ...
%     "210226_blizzard_fleece_no_gel_processed",...
%     "210216_wool_blend_no_gel_processed", ...
%     "210204_hucktowel_nogel_processed",  ...
%     "210222_sueded_cuddle_no_gel_processed",...
%     "210423_no_gel_careerwear_flannel_processed", ...
%     "210423_no_gel_thick_corduroy_processed", ...
%     "210423_no_gel_premier_velvet_processed", ...
%     "210423_velour_no_gel_processed", ...
%     "210423_no_gel_snowflake_knitside_processed"];

%     
filename_nogel = ["210226_blizzard_fleece_no_gel_processed",...
    "210204_hucktowel_nogel_processed",  ...
    "210121_velvet_no_gel_processed", ...
    "210222_sueded_cuddle_no_gel_processed",...
    "210216_wool_blend_no_gel_processed", ...
    "210423_velour_no_gel_processed", ...
    "210423_no_gel_thick_corduroy_processed"];

% filename_nogel = ["210216_wool_blend_no_gel_processed", "201021_1mm_grating_no_gel"];
% filename_nogel = ["201118_corduroy_no_gel_trimmed", ...
%     "210226_blizzard_fleece_no_gel_processed",...
%     "201021_1mm_grating_no_gel"];
% filename_nogel = ["210212_3_mm_grating_no_gel_processed", ...
% 	"201021_1mm_grating_no_gel",...
%     "210414_2mm_dots_no_gel_processed"];



num_textures = length(filename_gel);

%HYPERPARAMS
scatter_size = 50;
mean_vs_min = 0; %if 1, mean. if 0, min. FOR SPIKE TIMEs
ppm = 7;
top_neuron_number = [60 60 60]; %PC, RA, SA
% top_neuron_number = [20 20 20]; %PC, RA, SA
amplitude = "max"; % "max" or value - if value, add in difference between median texture value and this value!
aff_density = 1; %afferent population density
speed = 80; %mm/s
pin_radius = 0.025;% mm
gel_weight = 200;
gel_num = 0;
texture_type = "compliant"; %compliant, noncompliant, or combined
len = "full"; %seconds. 12 mm length / 80 mm/s so no edge scan.
stopBand = 0.3; %frequencies below 0.5 are noise
time_samp_period = 0.001; %millisecond time resolution
% ramp len

%% pull activities and real rates for each texture (for best neuron comparison)

my_texture_names = texture_names(texture_nums);

disp(texture_names(texture_nums));
if ~((length(texture_nums) == num_textures) && (num_textures == length(filename_nogel)))
    error("Filenames and/or Texture numbers don't match up.")
end

neuron_identities = {iPC, iRA, iSA};
excludeNeurons = 1; %don't average neurons that don't fire
[activities, av_spike_trains, space_vec, raw_rates] = pullRealActivities(rates, spikes, ...
    my_texture_names, good_neurons, neuron_identities, texture_nums, ...
    speed, excludeNeurons, time_samp_period);



%% Run Loop
% three entries for three afferent types: PC, RA, SA.
% modes: "area" - all afferents in area
%        "top"   - average of n=top_neuron_number neurons that respond
%        "best" -  average of closest n=top_neuron_number
%        "best_area" - average of closest n=top neuron number in texture
%        "area_rand" - random n affs in area (that fire)
%        "all_rand" - random n affs (that fire)
%        "best_area_match" - match on an afferent by afferent basis, same
%        as best area
%        "best_match" - match on an aff by aff basis, same as best

% neuron_selection_modes = ["all_rand", "area_rand", "area_rand"];
% neuron_selection_modes = ["best", "best_area", "best_area"];
neuron_selection_modes = ["best_match", "best_area_match", "best_area_match"];
distances_real_gel = {}; %texture_num x aff identity x [sim neurons x real neurons]
distances_real_ts = {};



tic
for i = 1:num_textures
    %load
    disp(strcat("Loading data from ", filename_gel(i)));
    cd(strcat(local_data_path_str, "sim_data"));
    load(filename_gel(i), "gel");
    load(filename_nogel(i), "no_gel");
    cd(strcat("..", local_path_back));
    
    %truncate low values 
    bottom_flag = 1;
    sd = 1.5;
    gel = truncateProfile(gel, sd, bottom_flag);
    no_gel = truncateProfile(no_gel, sd, bottom_flag);
    
    disp(strcat("Highpass filter at ", num2str(stopBand), " per mm."));
    gel = removeLowFreq(gel, stopBand, 'charles');
    no_gel = removeLowFreq(no_gel, stopBand, 'charles');
    
    
    disp(strcat("Calculating neural response."));
    texture_rates = {raw_rates{i,1}, raw_rates{i,2}, raw_rates{i,3}}; %cell array with three entires - vectors of rates for 
    %PCs, RAs, and SAs, for this texture
    [FRs_ts, FRs_gel, r, a, len_scan] = pullResponses(gel, ...
        no_gel, ppm, top_neuron_number, ...
        amplitude, len, speed, pin_radius, aff_density, ...
        texture_rates, neuron_selection_modes, figure_dir);
    mean_ts = FRs_ts{4}';
    sem_ts = FRs_ts{5}';
    mean_gel = FRs_gel{4}';
    sem_gel = FRs_gel{5}';
    activities.ts(i,:) = [mean_ts, sem_ts];
    activities.gel(i,:) = [mean_gel, sem_gel];
    
    h3 = findobj('Type','figure');
    fig = figure(h3(2));
    fig.Position = [100 100 900 700];
    subplot(2,3,3); % plot real spikes using TouchSim plot_spikes function wrapper
    tsPlotSpikes(spikes, len_scan, good_neurons, htxt_name, neuron_identities, texture_nums(i), speed)
    title(strcat(no_gel.name, " Recorded Data"));
    ylabel("");
    ax = gca;
    ax.FontSize = 12;
    ax.FontWeight = 'bold';
    
    subplot(2,3, 6); plotFiringRates(rates, good_neurons, htxt_name, neuron_identities, texture_nums(i), speed, 1);
    %     title(strcat(no_gel.name, "Mean Rate Recorded Data"));
    title("")
    ylabel("")
    ax = gca;
    ax.FontSize = 12;
    ax.FontWeight = 'bold';
    close(h3(1), h3(2), h3(3)); %close extraneous figures
%     
    
    disp("Calculating distance metric between real and sim spike trains...")
    % spike distance
    distances_real_gel{i} = spike_dist_touchsim(spikes, r{2}.responses,... % double check r{2} is gel?
         len_scan, good_neurons, neuron_identities, texture_nums(i), speed); 
     % each entry is, for each aff,num sim affs by num real affs
    distances_real_ts{i} = spike_dist_touchsim(spikes, r{1}.responses,...
         len_scan, good_neurons, neuron_identities, texture_nums(i), speed);
    
    
%     
end
total_time = toc;
disp(strcat("average time per texture: ", num2str(total_time/num_textures)))



%% MOAP
% 
if isstring(amplitude)
    amplitude = 0;
end
c= date;

%activity params: gel weight, gel_num, top_neuron_number,
%touchsim_amplitude, ppm, speed, aff_density, modes (PC,RA,SA)
%NOTE: touchsim amplitude is written as "0" if maximum. gel num is written
%as 0 if gel num varies.

title_str = strcat(texture_type, "_activities_", c, "_",...
    num2str(gel_weight), "_", ...
    num2str(gel_num), "_", ...
    num2str(top_neuron_number), "_", ...
    num2str(amplitude), "_",...
    num2str(ppm), "_", ...
    num2str(speed), "_",...
    num2str(aff_density), ...
    neuron_selection_modes(1), ...
    neuron_selection_modes(2), ...
    neuron_selection_modes(3), ".mat");

[rmses, rs, mean_ratios] = motherOfAllPlotsFunc(activities);

% sgtitle(title_str, 'Interpreter', 'none') ;

%% Bar plot average spike distance 

spike_distances = zeros(length(filename_gel), 6); 
min_distances = {};
sd_spike_distances = spike_distances;
% first two cols, PC mean gel and PC mean no gel. second two, RA mean gel,
% RA mean no gel. last two, SA mean gel, SA mean no gel.

for i = 1:num_textures % for each texture
    gel_aff_distances = distances_real_gel{i}; % get distance matrix across afferents for this texture
    ts_aff_distances = distances_real_ts{i};
    for j = 1:3
        % find means for each texture for each aff class for gel and no gel
        gel_dis = gel_aff_distances{j}; %sim by real afferents
        ts_dis = ts_aff_distances{j};
        if mean_vs_min
            spike_distances(i, j*2-1) = mean(gel_dis(:));
            spike_distances(i, j*2) = mean(ts_dis(:));
            sd_spike_distances(i, j*2-1) = std(gel_dis(:))/sqrt(length(gel_dis(:)));
            sd_spike_distances(i, j*2) = std(ts_dis(:))/sqrt(length(ts_dis(:)));
        else
            min_distances{i, j*2-1} = min(gel_dis, [], 2); % we want MIN for every REAL afferent
            min_distances{i, j*2} = min(ts_dis, [], 2);
        end
        
    end
end

if ~mean_vs_min
    aff_class_means = zeros(1, 6);
    aff_class_sd = aff_class_means;
    SAs = [];
    RAs = [];
    PCs = [];
    affs = {SAs, RAs, PCs};
    for i = 1:num_textures
        for j = 1:3
            affs{j} = vertcat(affs{j}, [min_distances{i, j*2-1}, min_distances{i, j*2}]);
        end
    end
    for j = 1:3
        aff_class_means((j*2-1):(j*2)) = mean(affs{j}, 1);
        aff_class_sds((j*2-1):(j*2)) = std(affs{j}, 1);
    end
else
    aff_class_means = mean(spike_distances, 1);
    aff_class_sds = std(spike_distances, 1);
end


figure;
aff_names = ["PCs", "RAs", "SAs"];
sig_mat_textures = zeros(3, num_textures);
for i = 1:3 %plotting either scatter or bar
    
    if mean_vs_min
        subplot(3,1,i);
    else
        subplot(1,3,i);
    end
    
    if mean_vs_min
        significance = zeros(1,num_textures);
        for j = 1:num_textures
            gel_aff_distances = distances_real_gel{j}; distance_mat_gel = gel_aff_distances{i};
            ts_aff_distances = distances_real_ts{j}; distance_mat_ts = ts_aff_distances{i};
            dist_mat_gel = distance_mat_gel(:); dist_mat_ts = distance_mat_ts(:);
            if ne(length(dist_mat_gel), length(dist_mat_ts))
                min_length = min(length(dist_mat_gel), length(dist_mat_ts));
                dist_mat_gel = dist_mat_gel(1:min_length);
                dist_mat_ts = dist_mat_ts(1:min_length);
            end
            [~, sig] = ttest(dist_mat_gel, dist_mat_ts);
            significance(j) = sig;
        end
        sig_mat_textures(i, :) = significance;
        
        distance_means = spike_distances(:, (i*2-1):(i*2));
        distance_sds = sd_spike_distances(:, (i*2-1):(i*2));
        b = bar(distance_means); % gel and ts for each afferent
        b(1).FaceColor = 'c'; b(2).FaceColor = 'r';
        title(strcat(aff_names(i), " Spike Distances"));
        xticklabels(my_texture_names);
        ylabel("Mean Spike Distance")
        hold on
        errorbars_group(distance_means, distance_sds, significance);
        if i == 1
            legend(["Gel", "No Gel"])
        end
    else %plotting scatter of best distances
        hold on
        for j = 1:num_textures
            scatter(min_distances{j, i*2}, min_distances{j, i*2-1}, scatter_size, colorscheme(j, :), 'filled'); % touch_sim x, gel y
        end
        if i == 1
            strs = my_texture_names';
            colors = colorscheme(1:size(strs,1), :);
            leg = legend([color_legend(strs, colors)]);
            leg.Box = 0;
        end
        xlabel("No Gel Spike Distance")
        ylabel("Gel Spike Distance")
        xlim([0 1]);
        ylim([0 1]);
        plot([0, 1], [0, 1], 'k');
        title(strcat(aff_names(i), " Spike Distances to Real Data"));
        ax = gca;
        ax.FontSize = 12;
        ax.FontWeight = 'bold';
    end
        
    
    
    
end

% plotting across all textures and just for each class.
figure;
sig_vec_aff = zeros(1,3);
aff_mean_distances = zeros(3,2);
aff_sd_distances = zeros(3,2);
for i = 1:3
    aff_mean_distances(i, :) = aff_class_means((i*2-1):(i*2));
    aff_sd_distances(i, :) = aff_class_sds((i*2-1):(i*2));
    distance_means = spike_distances(:, (i*2-1):(i*2));
    [~, sig] = ttest(distance_means(:, 1), distance_means(:, 2));
    sig_vec_aff(i) = sig;
end
b = bar(aff_mean_distances);
b(1).FaceColor = colorscheme(3, :); b(2).FaceColor = colorscheme(4,:);
title("Mean Spike Distances for each afferent class")
xticklabels(aff_names);
ylabel("Spike Distance (+/- SEM)")
hold on
errorbars_group(aff_mean_distances, aff_sd_distances, sig_vec_aff);
strs = {'Gel', 'Raw'}';
colors = colorscheme(3:4, :);
leg = color_legend(strs, colors);
leg = legend(leg);
leg.Box = 0;
ax = gca;
ax.FontSize = 12;
ax.FontWeight = 'bold';


