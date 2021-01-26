function [trace] = scanTexture(offset, trace, x_len, pinspermm, speed, samp_freq)
%scanTexture takes in a vector of pinoffsets (the
%same size as the x length of the stimulus trace). It then takes the offset
%and rewrites the trace matrix by wrapping it around forward for each
%timepoint for each  TIME RESOLUTION SHOULD BE MUCH HIGHER THAN SPATIAL otherwise
%it's just one pin per time increment. 
offset_len = length(offset);
pinspersec = pinspermm*speed; %pins per second (speed)
timeperpin = ceil(samp_freq/pinspersec); % (time_intervals per pin move)
if ne(size(trace,2), length(offset))
    error("trace width and offset length are unequal and do not match to the same pins");
end
trace(1,:) = offset;
counter = 2; %keeps track of how moved the profile is at this time spot
speed_counter = 1; %keeps track of how many time intervals since last move
for i = 2:size(trace,1)
    if speed_counter < timeperpin %if its not yet time to move up
        speed_counter = speed_counter+1; %increment counter
        trace(i,:) = trace(i-1,:); %trace does not move
    
    else %rotate within each x swath
        for j= 1:offset_len/x_len %for every x swath
            ind_1 = 1+(j-1)*x_len;
            ind_2 = ind_1+x_len;
            x_swath = offset(ind_1:ind_2);
            x_swath_rotated = [x_swath(end), x_swath(1:end-1)];
            offset(ind_1:ind_2) = x_swath_rotated;
        end
%         trace(i, counter:end) = offset(1:end-counter+1); %take beginning of offset and put it at the end of trace
%         trace(i, 1:counter-1) = offset(end-counter+2:end); %take the end off offset and put it at the beginning of trace
        speed_counter = 1; %reset counter
%         counter = counter+1; %move pins more to the right
    end
end
end

