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

if isnumeric(dll) || isnumeric(dothdir)
    error('DLL and Header Directory has to be string')
end

if exist(dll, 'file') ~= 2
    error('DLL file does not exist');
end

if exist(strcat(dothdir, doth), 'file') ~= 2
    error('Header file does not exist');
end

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

    % FIXME: Add 50 samples for extra
    recordtime = (5 * (ftime + noftime)) * times;
    samplestorecord = recordtime * samplerate + 50;
    
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

    % Stimulus data
    stimulus = zeros(runs, times * length(drinks));

    % Cues for timestamps
    cues = zeros(runs, times * length(drinks));
    
    % Channel preset
    % a25: EMG
    % a22: EEG
    channel_preset = 'a25';

    results = zeros(runs);

    % Configure device parameters
    fprintf(1, 'Setting Sample Rate\n');

    retval = calllib(libname, 'setSampleRate', (1000/samplerate));

    if ~strcmp(retval, 'MPSUCCESS')
       fprintf(1, 'Failed to Set Sample Rate.\n');
       calllib(libname, 'disconnectMPDev');
       return
    end

    fprintf(1, 'Setting to Acquire on Channel 1\n');
    if mptype == 101
        % MP150, 16 channels
        aCH = zeros(1, 16, 'int32');
    else
        % MP3x, 4 channels
        aCH = zeros(1, 4, 'int32');
    end
    
    % Acquire only on the 1st channel
    aCH(1) = 1;
   
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

    retval = calllib(libname, 'configChannelByPresetID', 0, channel_preset);
    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to Load Presets.\n');
        calllib(libname, 'disconnectMPDev');
        return
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
        numValuesToRead = samplerate;

        % Collect 1000 samples per channel
        remaining = samplestorecord;
        
        % Initialize the correct amount of data
        temp_buffer(1:numValuesToRead) = double(0);
        offset = 1;

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
                eeg(i, offset:offset + numRead - 1) = temp_buffer(1:numRead); 

                % SET TO true FOR LIVE PLOTTING
                if false
                    %live_plot = figure;
                    % len = length(buff);

                    %plot graph
                    pause(1/1000);

                    plot((1:samplestorecord), eeg(i,:), 'r-'), axis([1 samplestorecord -1 1]);
                    title('Acquired Signal Plot');
                    xlabel('Sample N');
                end
           end

           offset = offset + numRead;
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
        assignin('base', 'stims', stimulus);
        assignin('base', 'cues', cues);

        % Process results
        tic;
        results(i) = processdata(eeg(i,:), stimulus, cues, times);
        toc;

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
    fclose('all');

catch err
    
    rethrow(err);
    
    % Disconnect cleanly in case of system error
    calllib(libname, 'disconnectMPDev');

    % Unload the library
    unloadlibrary(libname);

    % Cleanup
    fclose('all');

end
end




