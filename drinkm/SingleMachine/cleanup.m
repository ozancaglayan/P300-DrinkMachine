function cleanup()
ListenChar(0);

if window
    Screen('CloseAll');
end

if pahandle
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
end

if mpdev
    % Disconnect cleanly
    calllib(mpdev, 'disconnectMPDev');
    
    % Unload the library
    unloadlibrary(mpdev);
end
end