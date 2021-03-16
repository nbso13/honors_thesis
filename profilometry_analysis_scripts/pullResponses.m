function [FRs_ts, FRs_gel, response_collection, aff_pop_final] = pullResponses(filename_gel, filename_nogel, ppm, top_neuron_number, ts_amplitude, figure_dir)
%pullResponses: given struct filenames and other hyperparams, calc firing
%rates. filenames indicate mat file name. ppm is pins per millimeter for
%touchsim model. ts amplitude indicates how much of the texture to input to
%skin mechanics for touchsim (must use entire gelsight profile). if figure
%dir is a string, save figures there.

% presets
len = 1; % s, length of indentation in time
loc = [0 0]; %location on finger
samp_freq = 2000; % hz
ramp_len = 0.01; %length of ramping on, in seconds
gel_constant = 1.48; %empirically derived factor to scale profilometry through gel
aff_density = 0.8; %afferent population density
speed = 80; %mm/s
%% Load data and process data

save_figures = 0;
if isstring(figure_dir)
    dir_list = split(figure_dir, "/");
    texture_name = dir_list(end);
    save_figures = 1;
    disp(strcat("Saving figures to ", figure_dir));
end

disp(strcat("Loading data from ", filename_gel));

cd ../../mat_files/
load(filename_gel);
load(filename_nogel);
cd ../bensmaia_gelsight_scripts/profilometry_analysis_scripts

if ~isfield(gel, 'scaled')
    gel.profile = gel.profile.*gel_constant; %scale up
end


disp("Adjusting crop and sample rate...")
if ~checkSizeMatch(gel, no_gel)
    [gel, no_gel] = resampleToMin(gel, no_gel); %resamples to the min resolution
    [gel, no_gel] = bruteCropFit(gel, no_gel); %crops to same size
end

figure
visualizeProfile(gel);
figure
visualizeProfile(no_gel);



%% build models
str = input("View touchsim surfaces? (y/n)", 's');
disp("Building surface models...")
if str == "y"
    plot_flag = 1;
else
    plot_flag = 0;
end
pin_radius = 0.025;
[new_gel_ts, new_no_gel_ts, skin_surface_ts, ...
    gel_fig, no_gel_fig, skin_fig] = TouchSimSkin(gel, no_gel, ppm, pin_radius, plot_flag);

if save_figures
    cd(figure_dir)
    cd('gel')
    temp = char(filename_gel);
    date_gel = temp(1:6);
    saveas(gel_fig, strcat("surf_gel_", texture_name, "_", string(date), '.png'));
    cd ..
    cd('real')
    temp = char(filename_nogel);
    date_no_gel = temp(1:6);
    saveas(no_gel_fig, strcat("surf_real_", texture_name, "_", string(date), '.png'));
    cd ..
    cd('ts')
    saveas(skin_fig, strcat("surf_ts_", texture_name, "_", string(date), '.png'));
    cd ../../../../bensmaia_gelsight_scripts/profilometry_analysis_scripts %out of ts, hucktowel, _checkin, pngs,
end

%% set up touchsim
% density = input("Afferent population density on distal digit 2? (enter # 0.1 - 1.0)");
cd ../touchsim_gelsight
setup_path;
cd ../profilometry_analysis_scripts/
aff_pop = affpop_hand('D2d',aff_density);

if ts_amplitude == "max"
    skin_surface_ts.amp = max(skin_surface_ts.offset); %max(skin_surface_ts.offset);
else
    skin_surface_ts.amp = ts_amplitude; %max(skin_surface_ts.offset);
end

% skin_surface_ts.amp = 1.95; %1/19 dots
new_gel_ts.amp = max(new_gel_ts.offset); %max(new_gel_ts.offset);
new_no_gel_ts.amp = 0;
ts_structs = [skin_surface_ts, new_gel_ts];

%% calc_responses
str = input("Calculating neural responses. Display figures? (y/n)", 's');
if str == "y"
    plot_flag = 1;
else
    plot_flag = 0;
end

[FRs_ts, FRs_gel, response_collection, aff_pop_final, figure_handles] = calcResponses(skin_surface_ts,...
    new_gel_ts, aff_pop, ppm, speed, len, loc, samp_freq, ramp_len, top_neuron_number, plot_flag);

if save_figures
    cd(figure_dir)
    direcs = ["ts", "gel"];
    dates = [string(date_no_gel), string(date_gel)];
    for i = 1:size(figure_handles, 1)
        cd(direcs(i))
        %saveas(figure_handles{i,1}, strcat("stim_", direcs(i), "_", texture_name, "_", dates(i), '.png'));
        saveas(figure_handles{i,2}, strcat("response_", direcs(i), "_", texture_name, "_", dates(i), '.png'));
        saveas(figure_handles{i,3}, strcat("mean_responses_", direcs(i), "_", texture_name, "_", dates(i), '.png'));
        saveas(figure_handles{i,4}, strcat("force_profile_", direcs(i), "_", texture_name, "_", dates(i), '.png'));
        saveas(figure_handles{i,5}, strcat("trace_profile_", direcs(i), "_", texture_name, "_", dates(i), '.png'));
        cd ..
    end
    cd ../../../bensmaia_gelsight_scripts/profilometry_analysis_scripts %out of ts, hucktowel, _checkin, pngs,
end

end

