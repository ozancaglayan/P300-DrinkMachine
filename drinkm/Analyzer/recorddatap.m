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

    for i = 1:runs
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
               eeg(i, offset:offset + numRead/divider - 1) = temp_buffer(1:divider:numRead);
               ecg(i, offset:offset + numRead/divider - 1) = temp_buffer(2:divider:numRead);
           end

           offset = offset + numRead/divider;
           remaining = remaining - numRead;
        end

        % Stop acquisition
        fprintf(1, 'Stop Acquisition\n');

        retval = calllib(libname, 'stopAcquisition');
        if ~strcmp(retval,'MPSUCCESS')
            fprintf(1,'Failed to Stop\n');
            calllib(libname, 'disconnectMPDev');
            return
        end

        % Read stimulus and cues from the other computer
        handshake(udpB, udpB2);
        cues(i, :) = fread(udpB, size(cues, 2), 'int32')';
        pause(0.1);
        stimulus(i, :) = fread(udpB, size(stimulus, 2))';
        
        assignin('base', 'eeg', eeg);
        assignin('base', 'ecg', ecg);
        assignin('base', 'stims', stimulus);
        assignin('base', 'cues', cues);

        % Process results
        results(i) = processdata(eeg(i,:), ecg(i,:), stimulus(i,:), cues(i,:), times, 'db4');

        % Send results back
        fprintf(udpB2, num2str(results(i)));
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




