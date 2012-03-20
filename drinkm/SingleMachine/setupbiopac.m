function [libname] = setupbiopac(dll, header_path, trigger, sample_rate)
% Define some enumerations from mpdev.h for readability
MPTYPE      = struct('MP150', 101, 'MP35', 102, 'MP36', 103);
MPCOMTYPE   = struct('MPUSB', 10, 'MPUDP', 11);

% Turn off annoying enum warnings
warning off MATLAB:loadlibrary:enumexists;
warning off MATLAB:loadlibrary:parsewarnings;

libname = 'mpdev';
doth = 'mpdev.h';

% Check if the library is already loaded
if libisloaded(libname)
    calllib(libname, 'disconnectMPDev');
    unloadlibrary(libname);
end

% Load the library
loadlibrary(dll, strcat(header_path, doth));

% Connect to the device
fprintf(1, 'Connecting to BIOPAC MP35\n');

retval = calllib(libname, 'connectMPDev', MPTYPE.MP35, MPCOMTYPE.MPUSB, 'auto');

if ~strcmp(retval, 'MPSUCCESS')
    fprintf(1, 'Failed to connect.\n');
    calllib(libname, 'disconnectMPDev');
    return
end

% Succesfully connected
fprintf(1, 'Connected.\n');

retval = calllib(libname, 'setSampleRate', (1000/sample_rate));

if ~strcmp(retval, 'MPSUCCESS')
    fprintf(1, 'Failed to Set Sample Rate.\n');
    calllib(libname, 'disconnectMPDev');
    return
end

fprintf(1, 'Setting to Acquire on Channel 1\n');

% MP3x, 4 channels
aCH = zeros(1, 4, 'int32');

% Acquire only on the 1st channel
aCH(1) = 1;

retval = calllib(libname, 'setAcqChannels', aCH);

if ~strcmp(retval,'MPSUCCESS')
    fprintf(1, 'Failed to Set Acq Channels.\n');
    calllib(libname, 'disconnectMPDev');
    return
end

pwd
retval = calllib(libname, 'loadXMLPresetFile', 'PresetFiles\channelpresets.xml');

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

% Set Trigger if requested
if trigger
    retval = calllib(libname, 'setMPTrigger', 'MPTRIGEXT', false, 1, 1);
    
    if ~strcmp(retval, 'MPSUCCESS')
        fprintf(1, 'Failed to Set Trigger.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
end

end