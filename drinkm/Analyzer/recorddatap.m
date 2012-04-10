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

    fopen(udpB);
    fopen(udpB2);
    fprintf('1\n');

    handshake(udpB, udpB2);

    % Compute experiment parameters
    times = str2double(fscanf(udpB));
    runs = str2double(fscanf(udpB));
    ftime = str2double(fscanf(udpB));
    noftime = str2double(fscanf(udpB));
    samplerate = str2double(fscanf(udpB));

    % FIXME: Add 1 second padding for timing problems
    recordtime = (5 * (ftime + noftime)) * times + 3;
    samplestorecord = recordtime * samplerate;
    
    assignin('base', 'recordtime', recordtime);
    assignin('base', 'times', times);
    assignin('base', 'runs', runs);
    assignin('base', 'yftime', ftime);
    assignin('base', 'noftime', noftime);
    assignin('base', 'samplerate', samplerate);
    
    drinks = {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'};
    assignin('base', 'drinks', drinks);
    
    % EEG data
    eeg = zeros(runs, samplestorecord);
    ecg = zeros(runs, samplestorecord);
    
    % Normalized ones
    n_eeg = zeros(runs, samplestorecord);
    n_ecg = zeros(runs, samplestorecord);
    
    % Clean EEG
    clean_eeg = zeros(runs, samplestorecord);
    
    % We take 180 samples
    average_eeg = zeros(length(drinks), 160, runs);
    average_n_eeg = zeros(length(drinks), 160, runs);
    average_clean_eeg = zeros(length(drinks), 160, runs);
    
    % Processed EEG stimulus windows
    final_eeg = zeros(length(drinks), (noftime + ftime) * samplerate);
    
    % Stimulus data
    stimulus = zeros(runs, times * length(drinks));

    % Cues for timestamps
    cues = zeros(runs, times * length(drinks));

    % Hold the results
    results(1:runs) = 0;
    
    % Channel preset
    % a25: EMG
    % a22: EEG
    % a16: ECG
    channel_presets = {'a22', 'a16'};

    % Configure device parameters
    fprintf(1, 'Setting Sample Rate\n');

    retval = calllib(libname, 'setSampleRate', (1000/samplerate));

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

    for n_run = 1:runs
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
        numValuesToRead = samplerate * length(channel_presets);

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
               eeg(n_run, offset:offset + numRead/divider - 1) = temp_buffer(1:divider:numRead);
               ecg(n_run, offset:offset + numRead/divider - 1) = temp_buffer(2:divider:numRead);
           end

           offset = offset + numRead/divider;
           remaining = remaining - numRead;
        end
        
        assignin('base', 'eeg', eeg);
        assignin('base', 'ecg', ecg);

        % Stop acquisition
        fprintf(1, 'Stop Acquisition\n');

        retval = calllib(libname, 'stopAcquisition');
        if ~strcmp(retval, 'MPSUCCESS')
            fprintf(1, 'Failed to Stop\n');
            calllib(libname, 'disconnectMPDev');
            return
        end

        % Read stimulus and cues from the other computer
        handshake(udpB, udpB2);
        cues(n_run, :) = fread(udpB, size(cues, 2), 'int32')';
        pause(0.1);
        stimulus(n_run, :) = fread(udpB, size(stimulus, 2))';
        
        assignin('base', 'stims', stimulus);
        assignin('base', 'cues', cues);
        
        % Normalize signals between (-1, 1), use maximum value
        % from 400:end as the beginnings of the records are noisy and fluctuating.
        n_eeg(n_run, :) = eeg(n_run, :)./max(eeg(n_run, 1000:end));
        n_ecg(n_run, :) = ecg(n_run, :)./max(ecg(n_run, 1000:end));
        
        % Subtract ECG from EEG
        clean_eeg(n_run, :) = n_eeg(n_run, :) - n_ecg(n_run, :);
        
        assignin('base', 'n_eeg', n_eeg);
        assignin('base', 'n_ecg', n_ecg);
        assignin('base', 'clean_eeg', clean_eeg);

        for i = 1:times * length(drinks)
            average_eeg(stimulus(n_run, i), :, n_run) = average_eeg(stimulus(n_run, i), :, n_run) + eeg(n_run, cues(n_run, i):cues(n_run, i)+160-1);
            average_n_eeg(stimulus(n_run, i), :, n_run) = average_n_eeg(stimulus(n_run, i), :, n_run) + n_eeg(n_run, cues(n_run, i):cues(n_run, i)+160-1);
            average_clean_eeg(stimulus(n_run, i), :, n_run) = average_clean_eeg(stimulus(n_run, i), :, n_run) + clean_eeg(n_run, cues(n_run, i):cues(n_run, i)+160-1);
        end
        
        for i = length(drinks)
            average_eeg(i, :, n_run) = average_eeg(i, :, n_run) / times;
            average_n_eeg(i, :, n_run) = average_n_eeg(i, :, n_run) / times;
            average_clean_eeg(i, :, n_run) = average_clean_eeg(i, :, n_run) / times;
        end

        assignin('base', 'average_eeg', average_eeg);
        assignin('base', 'average_n_eeg', average_n_eeg);
        assignin('base', 'average_clean_eeg', average_clean_eeg);        

        % Process results
        [results(n_run), eegdata] = processdata(eeg(n_run, :), ...
                                                           stimulus(n_run, :), ...
                                                           cues(n_run, :), ...
                                                           times, samplerate, ...
                                                           ftime, noftime, ...
                                                           drinks, 'db4');
        assignin('base', 'eegdata', eegdata);                     
        assignin('base', 'final_eeg', final_eeg);

        % Send results back
        fprintf(udpB2, num2str(results(n_run)));
        pause(1);
    end
    
    assignin('base', 'results', results);

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




