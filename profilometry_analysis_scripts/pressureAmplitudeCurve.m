%% Touchsim Force / Amplitude curve
% Jan 18 21

% Approach: to compare gelsight and touchsim neural simulations, we need to be 
% using the same force per unit area, or pressure. Touchsim takes in profiles
% and amplitudes of indentation. If we can build a pressure vs amplitude curve
% for a stimulus, we can then choose the amplitude that matches the pressure used
% with gelsight.
% 
% steps:
% 1) calculate the area of the texture
% 2) sum the forces at a range of amplitudes
% 3) plot

clear 
close all

%% set vars
ppm = 7;
gel_constant = 1.49;
one_dim = 0; % yes, this is one dimensional and grating goes horizontal.

%cross
filename_gel = "201119_cross_gel_processed";
filename_nogel = "201119_cross_no_gel_processed";

% CORDUROY
% filename_gel = "201118_corduroy_35_gel_trimmed";
% filename_nogel = "201118_corduroy_no_gel_trimmed";


%% Load data process data
cd ../../mat_files/
load(filename_gel);
load(filename_nogel);
cd ../bensmaia_gelsight_scripts/profilometry_analysis_scripts

gel.profile = gel.profile.*gel_constant; %scale up

figure
visualizeProfile(gel);
figure
visualizeProfile(no_gel);

if ~checkSizeMatch(gel, no_gel)
    [gel, no_gel] = resampleToMin(gel, no_gel); %resamples to the min resolution
    [gel, no_gel] = bruteCropFit(gel, no_gel); %crops to same size
end

% gel = rotateProfilometry(gel, 90);
% no_gel = rotateProfilometry(no_gel, 90);
gel_area = gel.x_axis(end)*gel.y_axis(end);
no_gel_area = no_gel.x_axis(end)*no_gel.y_axis(end);

figure
visualizeProfile(gel);
figure
visualizeProfile(no_gel);

%% generate touchsim models

plot_flag = 0;
pin_radius = 0.025;
[new_gel_ts, new_no_gel_ts, skin_surface_ts] = TouchSimSkin(gel, no_gel, ppm, pin_radius, plot_flag);

%get profiles
touchsim_gel = shape2profilometry(skin_surface_ts.shape, ...
    skin_surface_ts.offset, skin_surface_ts.pins_per_mm);
new_gel = shape2profilometry(new_gel_ts.shape, ...
    new_gel_ts.offset, new_gel_ts.pins_per_mm);
new_no_gel = shape2profilometry(new_no_gel_ts.shape, ...
    new_no_gel_ts.offset, new_no_gel_ts.pins_per_mm);

%show the profiles
figure
visualizeProfile(touchsim_gel);
figure
visualizeProfile(new_gel);
figure
visualizeProfile(new_no_gel);


cd ../touchsim_gelsight
setup_path;
cd ../profilometry_analysis_scripts
ts_structs = [skin_surface_ts, new_gel_ts, new_no_gel_ts];
speed = 80; %mm/s.
len = 1; % s
loc = [0 0];
samp_freq = 2000; % hz
ramp_len = 0.2;
amp = 0.1:0.1:1;
forces = zeros(size(amp));
for i = 1:length(amp)
    disp(strcat("Indenting at (mm): ", num2str(amp(i))));
    new_offset = amp(i) + skin_surface_ts.offset - max(skin_surface_ts.offset); %setting up amplitude
    new_offset(new_offset<0) = 0;
    [~, P] = skinModel(skin_surface_ts.shape, new_offset', pin_radius, plot_flag);
    total_forces = sum(sum(P));
    forces(i) = total_forces;
end

forces = forces./gel_area; %now in N/mm^2
pressures = forces*1000000; %now in N/m^2
figure
plot(amp, pressures)
title("Amplitude vs pressure")
xlabel("Amplitude of indentation (mm)")
ylabel("Pressure (N/m^2)");
force = 200*0.0098; %grams to newtons
gel_pressure = force/(576/1000000);
yline(gel_pressure);
