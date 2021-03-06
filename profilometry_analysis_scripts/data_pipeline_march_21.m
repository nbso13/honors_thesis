%% Main Script for Analysis
% Author: Nick Ornstein
% Group: Bensmaia Lab
% Project: Gelsight Profilometry
% Date: March 31 2020
% cd ~/Documents/bensmaia_lab/bensmaia_gelsight_scripts/profilometry_analysis_scripts
clear
close all
%
% TO DO:
% - welsh spectra (normalized!)
% - produce following figures:
%
% FIGURE 1: Apparatus
%
% FIGURE 2A B and C: Grating, Corduroy, blizzard fleece profiles no gel
% FIFUGRE 2DE and F: same, with touchsim
% FIGURE 2GH and I: same, with gelsight
%
% FIGURE 3 ABC: Power spectra no gel
% DEF: Power spectra touch sim
% GHI: Power spectra gel
%
% FIGURE 4A: Power spectra ratio no_gel touchsim, FOR COMPLIANT TEXTURES
% Figure 4B: power spectra ratio no gel, gel, FOR COMPLIANT TEXTURES
%
% FIGURE 5A: Comparison of spectra between real spike trains and  no gel profiles
% FIGURE 5B: real spike trains and gel profiles
% FIGURE 6C: real spike trains and  touchsim profiles
%
% FIGURE 6: Mother of all plots
%
% FIGURE 7: Comparison of afferent RMSEs across experimental conditions - matching contact conditions
%
%
% SI Figure 1: Gain match
% SI Figure 2: Finger match re instron
%
% Write up results
%
% THEN work on instron

%% set vars
% figure_dir = "../../pngs/feb_23_charles_checkin/sueded_cuddle";
figure_dir = 0; % do not save figures


cd ../neural_data
load("RawPAFData")
load("TextureNames")
cd ../profilometry_analysis_scripts

good_neurons = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 18 22 25 28 33 34];
% good_neurons = 1:39;
texture_nums = [ 25, 45, 50];
% texture_nums = [50, 49];

%pull names
for i = 1:length(htxt_name)
    texture_names(i) = string(htxt_name{i});
end


filename_gel = ["201118_corduroy_35_gel_trimmed", ...
    "210226_blizzard_fleece_gel_7_200_grams_processed", ...
    "210223_1mm_grating_gel_11_processed"];

% "210223_velvet_gel_7_processed", ...
%     "210209_hucktowel_gel_11_processed",  ...
%     "210219_sueded_cuddle_gel_7_processed",...
%     "210217_wool_blend_gel_7_processed", ...
% "210216_3mm_grating_gel_7_processed"
% "210217_wool_blend_gel_7_processed", ...
%     "210223_velvet_gel_7_processed", ...
%     "210209_hucktowel_gel_11_processed",  ...
%     "210219_sueded_cuddle_gel_7_processed",...
%     "201118_corduroy_35_gel_trimmed", ...
%     "210226_blizzard_fleece_gel_7_200_grams_processed", ...
%     "210310_wool_blend_gel_11_100_grams_processed", ...
%     "210304_velvet_gel_11_100_grams_processed", ...
%     "210304_hucktowel_gel_11_100_grams_processed", ...
%      "210310_sueded_cuddle_gel_11_100_grams_processed",...
%     "210304_blizzard_fleece_gel_11_100_grams_processed",...
%     "210310_5mm_grating_gel_11_100_grams_processed"];


filename_nogel = ["201118_corduroy_no_gel_trimmed", ...
    "210226_blizzard_fleece_no_gel_processed",...
    "201021_1mm_grating_no_gel"];
%     
%     "210216_wool_blend_no_gel_processed", ...
% "210121_velvet_no_gel_processed", ...
%     "210204_hucktowel_nogel_processed",  ...
%     "210222_sueded_cuddle_no_gel_processed",...
%     
%     "210212_3_mm_grating_no_gel_processed"
%HYPERPARAMS
ppm = 7;
top_neuron_number = 20;
amplitude = "max"; % "max" or value - if value, add in difference between median texture value and this value!
aff_density = 1; %afferent population density
speed = 80; %mm/s
pin_radius = 0.025;
gel_weight = 200;
gel_num = 0;
texture_type = "compliant"; %compliant, noncompliant, or combined
len = "full"; %seconds. 12 mm length / 80 mm/s so no edge scan.
stopBand = 0.3; %frequencies below 0.5 are noise
gauss_kernel_size = 5;
gauss_flag = 0; %if yes, convolve with gaussian of size gauss_kernel_size
time_samp_period = 0.001; %millisecond time resolution
% ramp len
% sample frequency in time
% afferent density
% afferent location
% pin radius
% days since gel creation
% hours in toaster

%% pull activities and real rates for each texture (for best neuron comparison)

my_texture_names = texture_names(texture_nums);

disp(texture_names(texture_nums));
if ~((length(texture_nums) == length(filename_gel)) && (length(filename_gel) == length(filename_nogel)))
    error("Filenames and/or Texture numbers don't match up.")
end

neuron_identities = {iPC, iRA, iSA};
excludeNeurons = 1; %don't average neurons that don't fire
[activities, av_spike_trains, space_vec] = pullRealActivities(rates, spikes, ...
    my_texture_names, good_neurons, neuron_identities, texture_nums, ...
    speed, excludeNeurons, gauss_flag, gauss_kernel_size, time_samp_period);



%% Run Loop
% three entries for three afferent types: PC, RA, SA.
% modes: "area" - all afferents in area
%        "top"   - average of n=top_neuron_number neurons that respond
%        "best" -  average of closest n=top_neuron_number
%        "best_area" - average of closest n=top neuron number in texture
%        area
neuron_selection_modes = ["top", "area", "area"];

correlation = zeros(length(filename_gel), 6); %for each afferent, the correlation with gel profile, then with no_gel profile



tic
for i = 1:length(filename_gel)
    %load
    disp(strcat("Loading data from ", filename_gel(i)));
    cd ../../mat_files/
    load(filename_gel(i), "gel");
    load(filename_nogel(i), "no_gel");
    cd ../bensmaia_gelsight_scripts/profilometry_analysis_scripts
    
    disp(strcat("Highpass filter at ", num2str(stopBand), " per mm."));
    gel = removeLowFreq(gel, stopBand, 'charles');
    no_gel = removeLowFreq(no_gel, stopBand, 'charles');
    
    
        disp(strcat("Calculating neural response."));
        %activities
        texture_rates = activities.real(i,1:3);
        [FRs_ts, FRs_gel, r, a] = pullResponses(gel, ...
            no_gel, ppm, top_neuron_number, ...
            amplitude, len, speed, pin_radius, aff_density, ...
            texture_rates, neuron_selection_modes, figure_dir);
        mean_ts = FRs_ts{4}';
        sem_ts = FRs_ts{5}';
        mean_gel = FRs_gel{4}';
        sem_gel = FRs_gel{5}';
        activities.ts(i,:) = [mean_ts, sem_ts];
        activities.gel(i,:) = [mean_gel, sem_gel];
    
end
total_time = toc;
disp(strcat("average time per texture: ", num2str(total_time/length(filename_gel))))



%% Save and visualize

if isstring(ts_amplitude)
    touchsim_amplitude = 0;
else
    touchsim_amplitude = ts_amplitude;
end
c= date;

%activity params: gel weight, gel_num, top_neuron_number,
%touchsim_amplitude, ppm, speed, aff_density, modes (PC,RA,SA)
%NOTE: touchsim amplitude is written as "0" if maximum. gel num is written
%as 0 if gel num varies.

cd activities\
title_str = strcat(texture_type, "_activities_", c, "_",...
    num2str(gel_weight), "_", ...
    num2str(gel_num), "_", ...
    num2str(top_neuron_number), "_", ...
    num2str(touchsim_amplitude), "_",...
    num2str(ppm), "_", ...
    num2str(speed), "_",...
    num2str(aff_density), ...
    neuron_selection_modes(1), ...
    neuron_selection_modes(2), ...
    neuron_selection_modes(3), ".mat");

% save(title_str, "activities");
cd ..
rmses = motherOfAllPlotsFunc(activities);
sgtitle(title_str, 'Interpreter', 'none') ;




%% FILENAME LIBRARY -

% ALL GELS 200 grams
% filename_gel = ["210219_sueded_cuddle_gel_7_processed", "210217_wool_blend_gel_7_processed", ...
%     "210209_hucktowel_gel_11_processed", "210122_velvet_gel_4_processed", ...
%     "201118_corduroy_35_gel_trimmed", "210219_cross_gel_7_processed", ...
%     "201116_2mm_grating_35_gel_processed", "201116_1mm_grating_35_gel_processed", ...
%     "210216_3mm_grating_gel_7_processed", "210216_3mm_grating_gel_11_processed" ];

% filename_nogel = ["210222_sueded_cuddle_no_gel_processed", "210216_wool_blend_no_gel_processed", ...
%     "210204_hucktowel_nogel_processed", "210121_velvet_no_gel_processed", ...
%     "201118_corduroy_no_gel_trimmed", "201119_cross_no_gel_processed", ...
%     "201019_no_gel_2mm_grating", "201021_1mm_grating_no_gel", ...
%     "210212_3_mm_grating_no_gel_processed", ];

% filename_gel = [ "210217_wool_blend_gel_7_processed", ...
%     "210223_velvet_gel_7_processed", ...
%     "210209_hucktowel_gel_11_processed",  ...
%     "210219_sueded_cuddle_gel_7_processed",...
%     "201118_corduroy_35_gel_trimmed", ...
%     "210226_blizzard_fleece_gel_7_200_grams_processed",...
%     "210223_1mm_grating_gel_11_processed",...
%     "210216_3mm_grating_gel_7_processed"];

% filename_nogel = [ "210216_wool_blend_no_gel_processed", ...
%     "210121_velvet_no_gel_processed", ...
%     "210204_hucktowel_nogel_processed",  ...
%     "210222_sueded_cuddle_no_gel_processed",...
%     "201118_corduroy_no_gel_trimmed", ...
%     "210226_blizzard_fleece_no_gel_processed",...
%     "201021_1mm_grating_no_gel",...
%     "210212_3_mm_grating_no_gel_processed", ...
%     "210310_5mm_grating_no_gel_processed"];
% %

% 100 gram gels
% "210310_wool_blend_gel_11_100_grams_processed", ...
%     "210304_velvet_gel_11_100_grams_processed", ...
%     "210304_hucktowel_gel_11_100_grams_processed", ...
%      "210310_sueded_cuddle_gel_11_100_grams_processed",...
%     "210304_blizzard_fleece_gel_11_100_grams_processed",...
%        "210304_1mm_grating_gel_11_100_grams_processed",...
%     "210304_3mm_grating_gel_11_100_grams_processed", ...
%     "210310_5mm_grating_gel_11_100_grams_processed"];
%
% "210216_wool_blend_no_gel_processed", ...
%     "210121_velvet_no_gel_processed", ...
%     "210204_hucktowel_nogel_processed",  ...
%     "210222_sueded_cuddle_no_gel_processed",...
% "210226_blizzard_fleece_no_gel_processed",...
%     "201021_1mm_grating_no_gel",...
%     "210212_3_mm_grating_no_gel_processed", ...
%     "210310_5mm_grating_no_gel_processed"];


%% Texture options

% COMPLIANT
% sueded cuddle
% filename_gel = "210219_sueded_cuddle_gel_7_processed";
% filename_nogel = "210222_sueded_cuddle_no_gel_processed";

% wool_blend
% filename_gel = "210217_wool_blend_gel_7_processed";
% filename_nogel = "210216_wool_blend_no_gel_processed";

% hucktowel
% filename_gel = "210209_hucktowel_gel_11_processed";
% filename_nogel = "210204_hucktowel_nogel_processed";

%velvet REDO
% filename_gel = "210122_velvet_gel_3_processed";
% filename_gel = "210122_velvet_gel_4_processed";
% filename_nogel = "210121_velvet_no_gel_processed";

% CORDUROY REDO
% filename_gel = "201118_corduroy_35_gel_trimmed";
% filename_nogel = "201118_corduroy_no_gel_trimmed";

% %upholstery 1 on gel 1
% filename_gel = "210113_upholstry_36_gel_1_processed";
% filename_nogel = "210113_upholstry_no_gel_processed";

%upholstery gel 2
% filename_gel = "210112_upholstry_36_gel_2_processed";
% filename_nogel = "210111_upholstery_no_gel_processed";

%upholstery gel 1
% filename_gel = "210112_upholstry_36_gel_1_processed";
% filename_nogel = "210111_upholstery_no_gel_processed";

% TO DO
% Empire Velveteen
% Taffeta
% Wool Gabardine
% Flag/Banner
% Premier Velvet
% Wool Crepe
% Chiffron
% Swimwear Lining
% Blizzard Fleece
% Drapery Tape(Foam Side)


% NON COMPLIANT

% TO DO
% 12 mm grating
% 8mm grating
% 5mm grating
% 2mm embossed dots
% 3mm embossed dots
% 4mm embossed
% 5
% 6

%cross
% filename_gel = "201119_cross_gel_processed";
% filename_gel = "210219_cross_gel_7_processed";
% filename_nogel = "201119_cross_no_gel_processed";

% gain_stim
% filename_gel = "201119_gain_gel_processed";
% filename_nogel = "201119_gain_no_gel_processed";

% 3/05 DOTS
% filename_gel = "200305_dots_gel_processed";
% filename_nogel = "200305_dots_no_gel_processed";

% 5/24 DOTS
% filename_gel = "200524_dots_gel_processed_aligned";
% filename_nogel = "200524_dots_no_gel_processed";

% 9/23 DOTS
% filename_gel = "200923_dots_gel_processed_aligned";
% filename_nogel = "200923_dots_no_gel";

% 9/25 DOTS
% filename_gel = "200925_dots_gel_processed_aligned";
% filename_nogel = "200925_dots_no_gel";

% 01/19/21 DOTS
% filename_gel = "210119_dots_gel_3_processed";
% filename_nogel = "210120_dots_no_gel_processed";

% 2MM GRATING THIN
% filename_gel = "201116_2mm_grating_35_gel_processed";
% filename_nogel = "201019_no_gel_2mm_grating";

% 1MM GRATING THIN
% filename_gel = "201116_1mm_grating_35_gel_processed";
% filename_nogel = "201021_1mm_grating_no_gel";


% 2/16/21 3mm grating,
% filename_gel = "210216_3mm_grating_gel_7_processed"; %gel 7
% filename_gel = "210216_3mm_grating_gel_11_processed"; %gel 11
% filename_nogel = "210212_3_mm_grating_no_gel_processed";

% 2/22/21 1mm grating
% filename_gel =
% filename_nogel = "210222_1mm_grating_no_gel_processed";

%
% Eventual texture list:
%
% - metallic silk
% - chiffron
% - taffeta
% - upholstery
% - wool blend
% - velvet
% - corduroy
% - blizzard fleece
% - denim
% - empire velveteen
% - sueded cuddle
% - wool garbadine
% - flag banner
% - swimwear lining


% - gratings - 1mm, 3mm, 5mm, 8mm, 12mm
% - dots - 6, 5, 4, 3, 2
