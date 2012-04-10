function buff = getBiopacData(nb_ch, sample_rate, samples_to_fetch)
total_read = 0;

% Place to hold each channel's data
buff = zeros(nb_ch, samples_to_fetch);

% Collect 1 second worth of data points per iteration
to_read = sample_rate * nb_ch * 1;

% Number of remaining samples to read
remaining = samples_to_fetch * nb_ch;

% Initialize the correct amount of data
temp_buffer(1:to_read) = double(0);
offset = 1;

while(remaining > 0)
    if to_read > remaining
        to_read = remaining;
    end
    
    [retval, temp_buffer, total_read] = calllib('mpdev', ...
        'receiveMPData', temp_buffer, to_read, total_read);
    
    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to receive MP data (Error: %s)\n', retval);
        %fprintf(1, 'MPDaemonLastError: %s\n', obj.getMPDaemonLastError());
        calllib('mpdev', 'stopAcquisition');
        calllib('mpdev', 'disconnect');
        return
    else
        % Place interleaved data into each channel's data in buff
        for n_ch = 1:nb_ch
            buff(n_ch, offset:offset + total_read/nb_ch - 1) = temp_buffer(n_ch:nb_ch:total_read);
        end
    end
    
    % Compute new values
    offset = offset + total_read/nb_ch;
    remaining = remaining - total_read;
end
calllib('mpdev', 'stopAcquisition');
end