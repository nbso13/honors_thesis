function [] = plotExProf(total_texture_number, gel, no_gel, scale_bar_loc, subplot_dim_1, subplot_dim_2, ind_gel, ind_no_gel)
%plotExProf takes in plot index, gel struct, and no_gel struct
%plotting example profiles
gcf;
subplot(subplot_dim_1, subplot_dim_2,ind_no_gel); visualizeProfile(no_gel);
title(strcat(no_gel.name, " Raw Profile"));
subplot(subplot_dim_1, subplot_dim_2, ind_gel); visualizeProfile(gel);
title(strcat(no_gel.name, " Gel Profile"));


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

subplot(subplot_dim_1, subplot_dim_2, ind_gel);
xlim([0 x_min])
ylim([0 y_min])
% caxis([0 max_profile_val])
yticks([]); yticklabels({})
xticks([]); xticklabels({})
ylabel("");
xlabel("");
daspect([1 1 1])
ax_raw = gca;
ax_raw.Position(2) = 0.17;


subplot(subplot_dim_1, subplot_dim_2,ind_no_gel);
xlim([0 x_min])
ylim([0 y_min])
% caxis([0 max_profile_val])
yticks([]); yticklabels({})
xticks([]); xticklabels({})
ylabel("");
xlabel("");

daspect([1 1 1])

x_norm_per_fig_units = ax_raw.Position(4)/ax_raw.YLim(2);
norm_units_2mm = 2*x_norm_per_fig_units/1.611;
box = annotation("textbox", [0.657567567567568 0.933300971693589 0.0616216201073415 0.0436893195685446],...
    'String', "2 mm", 'FitBoxToText','on', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
box.EdgeColor = 'none';
rec = annotation("rectangle", [0.638108108108109 0.932006472491914 0.0870000000000002 0.0068232558139536], 'FaceColor', 'k');


% scalebar('Location', scale_bar_loc, 'Colour', [0, 0, 0], 'Bold', 1, ...
%     'ScaleLength', 2, 'Unit', 'mm');
end

