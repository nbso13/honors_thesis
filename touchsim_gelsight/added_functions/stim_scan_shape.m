function s = stim_scan_shape(shape,pin_offset, pinspermm, len, samp_freq, amp, speed, gel_flag)
% SAME AS stim_indent_shape_new but SCANS texture.
% if gel_flag is positive, treat input as a already modeled skin sheet (not
% texture profile)
% 
% shape: pin positions making up object shape, e.g. shape_letter().
% pin_offset: indentation offset for each pin, allows complex shapes that 
% are not flat, default: 0.
% len: length of stimulus period in seconds
% loc: location on the finger i.e, [0 0]
% samp_freq: sampling frequency, only necessary if trace is not Stimulus
% object.
% amp: amplitude to indent texture (0 is tip of texture makes contact)
% speed: speed to scan in mm/s

%generate old trace using stim_ramp, do stuff to it until it's the right
%shape.

pin_radius = 0.05;
% make sure pin_radius is not too big
if size(shape,1)>1
    if size(shape,1)>=3
        try
            % triangulation for efficiency
            tri=delaunay(shape(:,1),shape(:,2));
            tri=tri(:,[1:end 1]);
            dx = diff(reshape(shape(tri,1),size(tri)),1,2);
            dy = diff(reshape(shape(tri,2),size(tri)),1,2);
            dmin = sqrt(min(dx(:).^2+dy(:).^2));
        catch
            % brute force, if that doesn't work
            dx = shape(:,1)-shape(:,1)';
            dy = shape(:,2)-shape(:,2)';
            dist = sqrt(dx(:).^2+dy(:).^2);
            dist(dist==0) = NaN;
            dmin = min(dist);
        end
    elseif size(shape,1)==2
        dmin = sqrt(sum((shape(1,:)-shape(2,:)).^2));
    end
    if dmin<(2*pin_radius)
        pin_radius = dmin/2;
        warning(['Pin radius too big for object shape and has been adjusted to '...
            num2str(pin_radius) '.']);
    end
end

%trace shape
t = zeros(int64(samp_freq*len),1);
trace = repmat(t,[1 size(shape,1)]);

med = median(pin_offset);
disp(strcat("stim_scan_shape: Indenting at ", num2str(max(pin_offset)), "mm median amplitude."));

if sum(pin_offset<0)>0
    pin_offset(pin_offset<0) = 0; %zero negative values
    disp("found negative values and zero'd out.")
end
%find x coord num
%first x val
x1 = shape(1,1);
xs = shape(:,1);
x_len = sum(xs==x1);
trace = scanTexture(pin_offset, trace, x_len, pinspermm, speed, samp_freq); % scan offset across trace

s = Stimulus(trace,shape,samp_freq,pin_radius, gel_flag);

