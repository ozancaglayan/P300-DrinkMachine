function retval = recorddatap(dll, dothdir, mptype, mpmethod, sn)
% Usage:
%   retval      return value for diagnostic purposes
%   dll         fullpath to mpdev.dll (ie C:\mpdev.dll)
%   dothdir     directory where mdpev.h
%   mptype      enumerated value for MP device, refer to the documentation
%   mpmethod    enumerated value for MP communication method, refer to the
%   documentation
%   sn          Serial Number of the mp150 if necessary

% Turn off annoying enum warnings
warning off MATLAB:loadlibrary:enumexists;

libname = 'mpdev';
doth = 'mpdev.h';

% Check if the library is already loaded
if libisloaded(libname)
    calllib(libname, 'disconnectMPDev');
    unloadlibrary(libname);
end

% Load the library
loadlibrary(dll, strcat(dothdir, doth));

%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin Demonstration %
%%%%%%%%%%%%%%%%%%%%%% %
try
    % Connect to the device
    fprintf(1,'Connecting to BIOPAC...\n');

    retval = calllib(libname, 'connectMPDev', mptype, mpmethod, sn);

    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to Connect.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
    
    % Succesfully connected
    fprintf(1, 'Connected\n');

    %% Handshake preparation
    portA = 9090;
    portA2 = 9092;

    ipB = '10.1.8.138';
    portB = 9091;
    portB2 = 9093;

    udpB = udp(ipB, portA, 'LocalPort', portB);
    udpB2 = udp(ipB, portB2, 'LocalPort', portA2);
    set(udpB, 'OutputBufferSize', 16384);
    set(udpB2, 'OutputBufferSize', 16384);
    set(udpB, 'InputBufferSize', 16384);
    set(udpB2, 'InputBufferSize', 16384);

    fopen(udpB);
    fopen(udpB2);
    fprintf('1\n');

    assignin('base', 'udpB', udpB);
    handshake(udpB, udpB2);

    % Compute experiment parameters
    play_time = str2double(fscanf(udpB));
    wait_time = str2double(fscanf(udpB));
    sample_rate = str2double(fscanf(udpB));
    stim_count = str2double(fscanf(udpB));

    % FIXME: Add 1 second padding for timing problems
    recordtime = (stim_count * (play_time + wait_time)) + 1;
    samplestorecord = recordtime * sample_rate;
    
    assignin('base', 'recordtime', recordtime);
    assignin('base', 'play_time', play_time);
    assignin('base', 'wait_time', wait_time);
    assignin('base', 'sample_rate', sample_rate);
    assignin('base', 'stim_count', stim_count);
    
    % EEG data
    eeg = zeros(1, samplestorecord);
    ecg = zeros(1, samplestorecord);
    
    % Normalized ones
    n_eeg = zeros(1, samplestorecord);
    n_ecg = zeros(1, samplestorecord);
    
    % Clean EEG
    clean_eeg = zeros(1, samplestorecord);
    
    % Processed EEG stimulus windows
    % final_eeg = zeros(length(drinks), (noftime + ftime) * sample_rate);
    
    % Stimulus data
    stimulus = zeros(1, stim_count, 'int32');

    % Cues for timestamps
    cues = zeros(1, stim_count, 'int32');

    % Hold the results
    % results = 0;
    
    % Channel preset
    % a25: EMG
    % a22: EEG
    % a16: ECG
    % a37: Microphone (SS17L, .5 - 200 Hz)
    % a38: Microphone for Speech (SS62L)
    channel_presets = {'a22', 'a16'};

    % Configure device parameters
    fprintf(1, 'Setting Sample Rate\n');

    retval = calllib(libname, 'setSampleRate', (1000/sample_rate));

    if ~strcmp(retval, 'MPSUCCESS')
       fprintf(1, 'Failed to Set Sample Rate.\n');
       calllib(libname, 'disconnectMPDev');
       return
    end

    fprintf(1, 'Setting to Acquire on Channels\n');
    aCH = zeros(1, 4, 'int32');
    for i = 1:length(channel_presets)
        aCH(i) = 1;
    end
   
    retval = calllib(libname, 'setAcqChannels', aCH);

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1, 'Failed to Set Acq Channels.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    retval = calllib(libname, 'loadXMLPresetFile', 'PresetFiles\channelpresets2.xml');
    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1,'Failed to Load Presets XML file.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    for i = 1:length(channel_presets)
        retval = calllib(libname, 'configChannelByPresetID', i-1, channel_presets{i});
        if ~strcmp(retval, 'MPSUCCESS')
            fprintf(1, 'Failed to Load Presets for channel %d\n', i);
            calllib(libname, 'disconnectMPDev');
            return
        end
    end

    % Set Trigger
    retval = calllib(libname, 'setMPTrigger', 'MPTRIGEXT', false, 1, 1);

    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to Set Trigger.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
    
    fprintf(1, 'Start Acquisition Daemon\n');

    retval = calllib(libname, 'startMPAcqDaemon');

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1, 'Failed to Start Acquisition Daemon.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    retval = calllib(libname, 'startAcquisition');

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Start Acquisition.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    fprintf(1, 'Start Acquisition\n');

    numRead = 0;

    % Collect 1 second worth of data points per iteration
    numValuesToRead = sample_rate * length(channel_presets);

    remaining = samplestorecord * length(channel_presets);

    % Initialize the correct amount of data
    temp_buffer(1:numValuesToRead) = double(0);
    offset = 1;

    divider = length(channel_presets);

    while(remaining > 0)

        if numValuesToRead > remaining
            numValuesToRead = remaining;
        end

        [retval, temp_buffer, numRead] = calllib(libname, 'receiveMPData', temp_buffer, numValuesToRead, numRead);

        if ~strcmp(retval, 'MPSUCCESS')
            fprintf(1, 'Failed to receive MP data.\n');
            calllib(libname, 'disconnectMPDev');
            return
        else
            eeg(1, offset:offset + numRead/divider - 1) = temp_buffer(1:divider:numRead);
            ecg(1, offset:offset + numRead/divider - 1) = temp_buffer(2:divider:numRead);
        end

        offset = offset + numRead/divider;
        remaining = remaining - numRead;
    end

    % Stop acquisition
    fprintf(1, 'Stop Acquisition\n');

    retval = calllib(libname, 'stopAcquisition');
    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to Stop\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    % Normalize signals between (-1, 1), use maximum value
    % from 400:end as the beginnings of the records are noisy and fluctuating.
    n_eeg(1, :) = eeg(1, :)./max(eeg(1, 1000:end));
    n_ecg(1, :) = ecg(1, :)./max(ecg(1, 1000:end));

    % Subtract ECG from EEG
    clean_eeg(1, :) = n_eeg(1, :) - n_ecg(1, :);

    assignin('base', 'n_eeg', n_eeg);
    assignin('base', 'n_ecg', n_ecg);
    assignin('base', 'eeg', eeg);
    assignin('base', 'ecg', ecg);
    assignin('base', 'clean_eeg', clean_eeg);
    
    % Read stimulus and cues from the other computer
    handshake(udpB, udpB2);
    cues = fread(udpB, stim_count, 'int32')';
    pause(1);
    stimulus = fread(udpB, stim_count, 'int32')';
    
    assignin('base', 'stimulus', stimulus);
    assignin('base', 'cues', cues);

    % We take 180 samples
    average_eeg = zeros(2, 180);
    average_clean_eeg = zeros(2, 180);
    for i = 1:stim_count
        average_eeg(stimulus(i) + 1, :) = average_eeg(stimulus(i) + 1, :) + eeg(cues(i):cues(i)+180-1);
        average_clean_eeg(stimulus(i) + 1, :) = average_clean_eeg(stimulus(i) + 1, :) + clean_eeg(cues(i):cues(i)+180-1);
    end
    target_count = length(find(stimulus));

    average_eeg(1, :) = average_eeg(1, :) ./ (stim_count - target_count);
    average_eeg(2, :) = average_eeg(2, :) ./ target_count;
    average_clean_eeg(1, :) = average_clean_eeg(1, :) ./ (stim_count - target_count);
    average_clean_eeg(2, :) = average_clean_eeg(2, :) ./ target_count;
    
    assignin('base', 'average_eeg', average_eeg);
    assignin('base', 'average_clean_eeg', average_clean_eeg);

    % Process results
%     eegdata = processdata(eeg, cues, sample_rate, play_time, wait_time, 'db4');
%     assignin('base', 'processed_data', eegdata);

    % Disconnect
    fprintf(1, 'Disconnecting...\n')
    retval = calllib(libname, 'disconnectMPDev');

    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1,'Acquisition Daemon Demo Failed.\n');
        calllib(libname, 'disconnectMPDev')
    end
    
    % Unload library
    unloadlibrary(libname);

    % Cleanup
    fclose(udpB);
    fclose(udpB2);

catch err
    fprintf(1, 'Caught exception, cleaning up..\n');
    
    % Disconnect cleanly in case of system error
    calllib(libname, 'disconnectMPDev');

    % Unload the library
    unloadlibrary(libname);

    % Cleanup
    fclose(udpB);
    fclose(udpB2);
    
    rethrow(err);
end
end




