function [] = plotExProf(total_texture_number, index, gel, no_gel, scale_bar_loc)
%plotExProf takes in plot index, gel struct, and no_gel struct
%plotting example profiles
gcf;
subplot(2,3,index+3); visualizeProfile(gel);
% title(gel.name);
subplot(2,3,index); visualizeProfile(no_gel);
title(no_gel.name)


max_profile_val = 0;
y_min = 20;
x_min = 20;

if gel.y_axis(end) < y_min
    y_min = gel.y_axis(end);
end
if gel.x_axis(end) < x_min
    x_min = gel.x_axis(end);
end
if max(gel.profile(:)) > max_profile_val
    max_profile_val = max(gel.profile(:));
end
if no_gel.y_axis(end) < y_min
    y_min = no_gel.y_axis(end);
end
if no_gel.x_axis(end) < x_min
    x_min = no_gel.x_axis(end);
end
if max(no_gel.profile(:)) > max_profile_val
    max_profile_val = max(no_gel.profile(:));
end

subplot(2,3,index);
xlim([0 x_min])
ylim([0 y_min])
caxis([0 max_profile_val])
yticks([]); yticklabels({})
xticks([]); xticklabels({})
ylabel("");
xlabel("");
daspect([1 1 1])
ax_raw = gca;



subplot(2,3,index+3);
xlim([0 x_min])
ylim([0 y_min])
caxis([0 max_profile_val])
yticks([]); yticklabels({})
xticks([]); xticklabels({})
ylabel("");
xlabel("");
ax_gel = gca;

x_norm_per_fig_units = ax_raw.Position(3)/ax_raw.XLim(2);
norm_units_2mm = 2*x_norm_per_fig_units;
box = annotation("textbox", [ax_raw.Position(1), ax_raw.Position(2), 0.1, 0.1],...
    'String', "2 mm", 'FitBoxToText','on', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
box.EdgeColor = 'none';
rec = annotation("rectangle", [ax_raw.Position(1), ax_raw.Position(2), ...
    norm_units_2mm, 0.01*ax_raw.Position(4)], 'FaceColor', 'k');
daspect([1 1 1])

% scalebar('Location', scale_bar_loc, 'Colour', [0, 0, 0], 'Bold', 1, ...
%     'ScaleLength', 2, 'Unit', 'mm');
end
