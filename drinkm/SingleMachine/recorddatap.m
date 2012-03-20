function retval = recorddatap(dll, dothdir, mptype, mpmethod, sn)

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

    % Compute experiment parameters
    times = str2double(fscanf(udpB));
    runs = str2double(fscanf(udpB));
    ftime = str2double(fscanf(udpB));
    noftime = str2double(fscanf(udpB));
    samplerate = str2double(fscanf(udpB));

    % Add 1 sec for beginning and 4 sec for the end for graphic delays
    recordtime = (5 * (ftime + noftime)) * (times + 5);
    samplestorecord = recordtime * samplerate;

    results = zeros(runs);
    data = [];
    cuedata = [];

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

    retval = calllib(libname, 'configChannelByPresetID', 0, 'a22');
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

        % Download and Plot 1000 samples in realtime
        numRead = 0;

        % Collect 1 second worth of data points per iteration
        numValuesToRead = 50;

        % Collect 1000 samples per channel
        remaining = samplestorecord;
        
        % Initialize the correct amount of data
        tbuff(1:numValuesToRead) = double(0);
        offset = 1;

        while(remaining > 0)

           if numValuesToRead > remaining
                   numValuesToRead = remaining;
           end

           [retval, tbuff, numRead]  = calllib(libname, 'receiveMPData', tbuff, numValuesToRead, numRead);

           if ~strcmp(retval, 'MPSUCCESS')
               fprintf(1, 'Failed to receive MP data.\n');
               calllib(libname, 'disconnectMPDev');
               return
           else
                buff(offset:offset + double(numRead(1)) - 1) = tbuff(1:double(numRead(1))); 

                % SET TO true FOR LIVE PLOTTING
                if false
                    len = length(buff);

                    %plot graph
                    pause(1/100);

                    plot((1:50), buff(len-49:len), 'g-'), axis([1 50 -100 100]);
                    title('Data Plot For Channel 1');
                    xlabel('N''th Sample');
                end
           end

           offset = offset + double(numValuesToRead);
           remaining = remaining - double(numValuesToRead);
        end
         
        eeg(i, :) = buff;

        % Stop acquisition
        fprintf(1, 'Stop Acquisition\n');

        retval = calllib(libname, 'stopAcquisition');
        if ~strcmp(retval,'MPSUCCESS')
            fprintf(1,'Failed to Stop\n');
            calllib(libname, 'disconnectMPDev');
            return
        end

        handshake(udpB,udpB2);

        data1 = [];
        cue1  = [];

        %% FIXME: Comment this block to understand what is going on!
        for j = 1:times
            pause(0.1);
            data2 = fscanf(udpB);
            size(data2);

            while (size(data2, 2) < 55)
                data2 = [' ', data2];
            end

            datanum = str2num(data2);
            data1 = [data1, datanum(3:7)];
            data = [data; datanum];
        end

        % Wait 0.1 seconds
        pause(0.1);

        for j = 1:times
            pause(0.1);
            cuedata2 = fscanf(udpB);
            size(cuedata2);

            %% FIXME: IS THIS A MISTAKE?
            %% BEFORE: while (size(cuedata2, 2) < 55);
            while (size(cuedata2, 2) < 55)
                cuedata2 = [' ', cuedata2];
            end

            cuedatanum = str2num(cuedata2);
            cue1 = [cue1, int32(cuedatanum(3:7) * 200)];
            cuedata = [cuedata; cuedatanum];
        end

        % Process results
        tic
        results(i) = processdata(eeg(i,:), data1, cue1, times);
        toc

        % Send results back
        fprintf(udpB2, num2str(results(i)));
        pause(1)
    end

    % Disconnect
    fprintf(1, 'Disconnecting...\n')
    retval = calllib(libname, 'disconnectMPDev');

    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1,'Acquisition Daemon Demo Failed.\n');
        calllib(libname, 'disconnectMPDev')
    end
    
    assignin('base', 'eeg', eeg);
    assignin('base', 'recordtime', recordtime);
    assignin('base', 'times', times);
    assignin('base', 'runs', runs);
    assignin('base', 'yftime', ftime);
    assignin('base', 'noftime', noftime);
    assignin('base', 'samplerate', samplerate);
    assignin('base', 'results', results);
    assignin('base', 'stims', data);
    assignin('base', 'cues', cuedata);

catch err
    % Disconnect cleanly in case of system error
    calllib(libname, 'disconnectMPDev');
    
    % Unload the library
    unloadlibrary(libname);

end

% Unload library
unloadlibrary(libname);


