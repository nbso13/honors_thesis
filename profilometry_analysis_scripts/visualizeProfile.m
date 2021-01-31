function [image_handle] = visualizeProfile(texture)
%visualizeProfile will visualize the profile assuming profilometry struct.
% if nargin < 2
%     handles = figure
%     axes_in = gca;
% end
%axes(handles.axes_in); %set the current axes to axes_in
max_filt = max(texture.profile, [], 'all');
min_filt = min(texture.profile, [], 'all');
image_handle = imagesc(texture.x_axis, texture.y_axis, texture.profile);
colormap jet
c = colorbar;
ylabel(c, 'mm');
caxis([min_filt, max_filt]);
xlabel('mm'); ylabel('mm');

% if nargin > 2
%     xline(texture.x_axis(vert_line));
%     yline(texture.y_axis(horiz_line));
% end

end

