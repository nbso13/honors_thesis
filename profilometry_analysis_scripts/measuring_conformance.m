%% Measuring conformance
% do to this, you need to visualize the profile and write down the ranges
% for min and max by eye
clear
close all
load('colorscheme.mat')
gel_constant = 1.49;
force = 200; %g

num_widths = 7; %0.35,0.5,0.75,1,1.2,1.5,2 

%nov 15 "35" gel was 2.81% or 34.65
%nov 3 "36" gel was 2.73% or 35.4
%jan 6 "36" gel 1 was 2.72% 35.7
%jan 6 "36" gel 2 was 2.94% or 33
%jan 14 gels 3, 4, and 5 were 2.80% or 34.7

days_old = [nan, 1, 8, 3, 30, 2, 2, 5, 5, 6, 6, 9, 9, 12, 12, 4, 4, 14, 14, 6, 45, 60, nan];
ratio = [nan, 2.81, 2.73, 2.81, 2.73, 2.72, 2.94, 2.72, 2.94, 2.72, 2.94, 2.72, 2.94, 2.72, 2.94, 2.80, 2.80, 2.72, 2.94, 2.80, 2.81, 2.73, nan];
gel_id_num = [nan, 35, 36, 35, 36, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 3, 4, 1, 2, 3, 35, 36, nan];
file_names = {'201111_craig_stim_32_gel_processed', ...
    '201116_craig_stim_35_gel_processed', '201111_craig_stim_36_gel_processed', ...
    '201118_craig_35_gel_processed', '201204_craig_36_gel_processed', ...
    '210108_craig_36_gel_1_processed', '210108_craig_36_gel_2_processed', ...
    '210111_craig_36_gel_1_processed', '210111_craig_36_gel_2_processed' ...
    '210112_craig_36_gel_1_processed', '210112_craig_36_gel_2_processed', ...
    '210115_craig_gel_1_processed', '210115_craig_gel_2_processed', ...
    '210118_craig_gel_1_processed', '210118_craig_gel_2_processed', ...
    '210118_craig_gel_3_processed', '210118_craig_gel_4_processed' ...
    '210120_craig_gel_1_processed', '210120_craig_gel_2_processed' ...
    '210120_craig_gel_3_processed', '210120_craig_old_gel_4_processed', '210120_craig_old_gel_not_4_processed'};
num_gels = length(file_names);
gels = zeros(num_gels, num_widths);
%% set empirically chosen parameters %CRAIG STIMS 

% each file name is a gel struct of a different gel with the craig
% stimulus.
area_vecs = {}; %each row is for a craig stim reading 32 is 1, 35 is 2, 36 is 3, 1st entry is min ranges, 
%2nd entry is max ranges. Starts with smallest gap (0.35)
area_vecs{1,1} = [13, 14; 12, 13; 10, 11.5; 8, 10; 6, 8; 3, 6; 0.1, 3];
area_vecs{1,2} = [14, 16; 12.5, 13.5; 11, 12; 9, 10; 7, 8; 5, 6; 2, 4];
area_vecs{1,3} = 'v';
area_vecs{2,1} = [0.01, 1; 1, 3; 3, 4; 4, 6; 6, 8.5; 8.5, 11; 11, 13.5];
area_vecs{2,2} = [1, 1.4; 2, 3; 4, 5; 6, 7; 8, 10; 10, 12; 12, 13.8];
area_vecs{2,3} = 'h';
area_vecs{3,1} = [0.1, 0.2; 10, 11; 8, 10; 6, 8; 3, 5; 0.01, 3; 0.1, 0.2]; %ALERT: 0.35 and 2mm gaps not measured here. NAN in data.
area_vecs{3,2} = [0.1, 0.2; 11, 11.5; 9, 10; 7, 8; 5, 6; 2, 4; 0.1, 0.2];       
area_vecs{3,3} = 'h';
area_vecs{4,1} = [13, 15; 12, 13; 10, 12; 8, 10; 6, 8; 3, 6; 1, 3]; 
area_vecs{4,2} = [14, 15; 12.5, 13; 11, 12; 9, 10; 7, 8; 5, 6; 2, 3.5];       
area_vecs{4,3} = 'h';
area_vecs{5,1} = [13, 14; 11, 13; 10, 11;  7, 9; 5, 7; 2, 5; 0.5, 2 ]; 
area_vecs{5,2} = [14, 14.5; 12, 13.5; 11, 12; 9, 10; 7, 8;  5, 6;  1, 3.5 ];       
area_vecs{5,3} = 'h';
area_vecs{6,1} = [13, 14; 11, 13; 10, 11;  7, 9; 5, 7; 2, 5; 0.5, 2 ]; 
area_vecs{6,2} = [14, 14.5; 12, 13.5; 11, 12; 9, 10; 7, 8;  5, 6;  1, 3.5 ];       
area_vecs{6,3} = 'h';
area_vecs{7,1} = [13, 14; 11, 13; 10, 11;  7, 10; 6, 8; 4, 6; 0.5, 2 ]; 
area_vecs{7,2} = [13.9, 14.5; 12.5, 13.5; 11, 11.3; 9, 10; 7, 8;  5, 6;  1, 3.5 ];       
area_vecs{7,3} = 'h';
area_vecs{8,1} = [14, 14.2; 12, 13; 10, 12;  8, 10; 6, 8; 4, 6; 0.5, 4 ]; 
area_vecs{8,2} = [14.25, 14.5; 12.9, 13.5; 11, 12; 9, 10; 7, 8;  5, 6;  2, 3.5 ];       
area_vecs{8,3} = 'h';
area_vecs{9,1} = [13.96, 14.5; 12.5, 13; 10.7, 11.5;  9, 9.4; 6.7, 7.3; 4, 5; 0.5, 3 ]; 
area_vecs{9,2} = [14.25, 14.45; 12.9, 13.1; 11, 12; 9.6, 9.9; 7.6, 7.9;  5, 5.7;  2.8, 3.2 ];       
area_vecs{9,3} = 'h';
area_vecs{10,1} = [13.7, 14; 12, 13; 10, 12;  8, 10; 6, 8; 4, 5; 0.5, 3 ]; 
area_vecs{10,2} = [14, 14.2; 12.7, 13; 11, 11.5; 9, 10; 7, 8;  5, 6;  2, 3.5 ];       
area_vecs{10,3} = 'h';
area_vecs{11,1} = [13.96, 14.5; 12.5, 13; 10.7, 11.5;  9, 9.4; 6.7, 7.3; 4, 5; 0.5, 3 ]; 
area_vecs{11,2} = [14.25, 14.45; 12.9, 13.1; 11, 12; 9.6, 9.9; 7.6, 7.9;  5, 5.7;  2.8, 3.2 ];       
area_vecs{11,3} = 'h';
area_vecs{12,1} = [15, 16; 13, 15; 12, 14; 10, 12;  8, 10; 5, 8; 2, 5]; 
area_vecs{12,2} = [15.7, 16; 14, 15; 12.5, 13; 11, 12; 9, 10;  7, 7.2; 4,5 ];       
area_vecs{12,3} = 'h';
area_vecs{13,1} = [0.1, 1; 13, 14.5; 11, 13; 9, 11;  7, 9; 5, 7.3; 2, 4]; 
area_vecs{13,2} = [0.1, 1; 14, 14.5; 12.5, 13.1; 10, 11; 8, 9; 6, 7;  3, 4.5 ];       
area_vecs{13,3} = 'h'; %ALERT: 0.35 gap not measured here. NAN in data.
area_vecs{14,1} = [14, 16; 12.5, 14; 11, 12; 9, 11;  7, 9; 4, 6; 2, 4]; 
area_vecs{14,2} = [15, 15.2; 12, 13; 11.5, 12.1; 10,10.5; 8, 8.5; 6, 6.2;  2, 4 ];       
area_vecs{14,3} = 'h'; 
area_vecs{15,1} = [14, 15; 12, 14; 10, 12; 8, 10;  6, 8; 4, 6; 1, 4]; 
area_vecs{15,2} = [14, 14.5; 12.5, 13.1; 10, 11.7; 9.5, 10; 7, 8;  5, 6; 2,3 ];       
area_vecs{15,3} = 'h'; 
area_vecs{16,1} = [14.5, 15; 13, 14.5; 11, 13; 9, 11;  7, 9; 5, 7.3; 2, 4]; 
area_vecs{16,2} = [15, 15.5;  13.5, 14; 12, 12.5; 10, 11; 8, 9; 6, 7;  3, 4.5 ];       
area_vecs{16,3} = 'h'; 
area_vecs{17,1} = [14, 14.5; 12, 14.5; 11, 13; 9, 11;  6, 8; 4, 5; 1, 4]; 
area_vecs{17,2} = [14, 14.5; 13, 13.5; 11, 12; 9, 10; 7, 8;  5, 6; 3, 3.3];       
area_vecs{17,3} = 'h'; 
area_vecs{18,1} = [14, 14.5; 13, 14.5; 11, 13; 9, 11;  7, 9; 5, 7.3; 2, 4]; 
area_vecs{18,2} = [14.5, 15; 13, 13.5; 11.7, 12.3; 10, 10.5; 8, 8.5;  5.5, 6; 3, 3.5];       
area_vecs{18,3} = 'h'; 
area_vecs{19,1} = [14, 14.5; 12.4, 13; 11, 12; 9, 10;  7, 8; 4, 5; 1, 3]; 
area_vecs{19,2} = [14.2, 14.5; 13, 13.5; 11, 12; 9, 10; 7, 8;  5, 6; 3, 3.3];       
area_vecs{19,3} = 'h'; 
area_vecs{20,1} = [11, 12.5; 10, 11; 8, 10; 6,8;  4,6; 2,3; 0.001, 1]; 
area_vecs{20,2} = [12, 12.4; 10.5, 11; 9, 9.6; 7, 8; 5, 6;  3, 4; 0.001, 1];       
area_vecs{20,3} = 'h'; 
area_vecs{21,1} = [14, 14.5; 12.4, 13; 11, 12; 9, 10;  7, 8; 4, 5; 1, 3]; 
area_vecs{21,2} = [14.3, 14.6; 13, 13.5; 11, 12; 9, 10; 7, 8;  5.5, 5.8; 3, 3.3];       
area_vecs{21,3} = 'h'; 
area_vecs{22,1} = [13.4, 13.8; 12.5, 13; 10.5, 12; 9, 10;  6,7; 4, 5; 1, 3]; 
area_vecs{22,2} = [13.8, 14; 13, 13.5; 11, 12; 9, 10; 7, 8;  5,5.6; 2.5, 3];       
area_vecs{22,3} = 'h'; 
%% run main for loop
plot_flag = 0;
for i = 1: num_gels
    cd ../../mat_files
    load(file_names{i})
    gel.profile(gel.profile<0) = 0; % by histogram inspection
    gel.profile = gel.profile.*gel_constant;
    cd ../bensmaia_gelsight_scripts/profilometry_analysis_scripts
    gels(i, :) = find_grating_differences(gel, area_vecs{i,3},...
                                               area_vecs{i,1}, ...
                                               area_vecs{i,2}, ...
                                               plot_flag)';
end

%% plot gel data
if plot_flag
    figure;
    hold on
    dot_size = 15;
end
x_norm = [0.35, 0.5, 0.75, 1, 1.2, 1.5, 2]'; %stimulus widths
x_36 = [0.5, 0.75, 1, 1.2, 1.5]';
x_gel_2_0115 = [0.5, 0.75, 1, 1.2, 1.5, 2]';
scatters = {};
fits = {};
for i = 1:num_gels
    if i == 3 %third one has no first or last entry (im dumb)
        x = x_36;
        y = gels(i, :)';
        y = y(2:end-1); 
    elseif i == 3 %third one has no first or last entry (im dumb)
        x = x_gel_2_0115;
        y = gels(i, :)';
        y = y(2:end); 
    else
        x = x_norm;
        y = gels(i, :)';
    end
    %add 0 to x and why because we know that 0 width should have 0
    %protrusion
    
    x = [0; 0; x];
    y = [0; 0; y];
    fit_ob = fitlm(x,y);
    fits{i} = fit_ob;
    
    if plot_flag
        scatters{i} = scatter(x,y, dot_size, colorscheme(ceil(i/2), :));
        fit_plot = fit(x,y, 'poly1');
        ax{i} = plot(fit_plot);
        ax_handles = ax{i};
        set(ax_handles,'color',colorscheme(i, :));
    end
end

%% add gibson and craig data
x = [0.35, 0.5, 0.75, 1, 1.2, 1.5]'; % in mm, from gibson and craig '06, fig 5
y = [0.06, 0.1, 0.17, 0.28, 0.366, 0.4]';
i = i+1;
fit_ob = fitlm(x,y);
fits{i} = fit_ob;

if plot_flag
    scatters{i} = scatter(x,y, dot_size, colorscheme(i, :));
    fit_plot = fit(x,y, 'poly1');
    ax{i} = plot(fit_plot);
    ax_handles = ax{i};
    set(ax_handles,'color',colorscheme(i, :));
    xlabel("Grating Width (mm)")
    ylabel("Conformance Depth (mm)")
    title("Width-Conformance relationship at 200g force")
end

% %automating plotting legend
% plot_legends = zeros(length(num_gels)*2, 1)';
% for i = 1:length(num_gels)
%     plot_legends(i*2) = num_gels(i);
%     plot_legends(i*2 - 1) = num_gels(i);
% end
% legend_labels = {'1:32 gel', '1:32 gel trendline', '1:35 gel', '1:35 gel trendline', '1:36 gel', '1:36 gel trendline', ...
%     '1:35_201118 gel', '1:35_201118 trendline', '1:36 gel dec', '1:36 dec trendline'};
% legend_labels = legend_labels(plot_legends);
% legend_labels = [legend_labels, 'Gibson & Craig, 2006 (human)', 'G&B trendline'];
% 
% 



%% stats on results - showing change over time for 33
num_gels  = num_gels+1;

rmses = zeros(num_gels,1);
SEs = zeros(num_gels,1);
slopes = zeros(num_gels,1);
for i = 1:num_gels
    lin_fit = fits{i};
    slopes(i) = lin_fit.Coefficients.Estimate(2);
    SEs(i) = lin_fit.Coefficients.SE(2);
    rmses(i) = lin_fit.RMSE;
end


gel_id_targets = 1:4;
gel_id_targets = [gel_id_targets, 35, 36];
gel_stats = {}; 
% first row is slopes second is standard errors on slopes, third is days
% old reading (x coord)
figure;
hold on
for i = gel_id_targets
gel_stats{1, i} = slopes(gel_id_num == i);
gel_stats{2, i} = SEs(gel_id_num == i);
gel_stats{3, i} = days_old(gel_id_num == i);
errorbar(gel_stats{3, i}, gel_stats{1, i}, gel_stats{2, i});
end

yline(slopes(end))
xlabel("days old")
ylabel("slope index")
legend("2.72%", "2.94%", "2.8%(3)", "2.8%(4)", "35", "36")
