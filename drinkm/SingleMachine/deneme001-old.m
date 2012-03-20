function p300drinkm(times, runs, ftime, noftime, samplerate)

for k = 1:runs
    count = 0;

    Snd('Play', mynoise, 8192, 16);

    tic
    WaitSecs(1);              

    for j = 1:times

        R1 = randperm(5);

        for i = 1:5
            randnum = R1(i);
            Screen('DrawTexture', w, textures(randnum));
            count = count + 1;
            cues(k, count) = toc;
            stimulus(k, count) = randnum;
            Screen('Flip', w);
            sound(soundz(randnum, :)*0.7, 16000);
            WaitSecs(ftime);
            Screen('DrawTexture', w, texback);
            Screen('Flip', w);
            WaitSecs(noftime);
        end
    end

    WaitSecs(3);
    Snd('Quiet');

    % Waiting for process
    Screen('DrawText', w, 'Waiting for results..', 100, 100, tcolor);
    Screen('Flip', w);

    handshake(udpA, udpA2);

    fprintf('sending data\n');

    for j = 1:times
        pause(0.1);
        data = [k, j, stimulus(k, (5*(j-1)) + 1:(5*(j-1)) + 5)];
        fprintf(udpA, num2str(data));
    end

    pause(0.1);

    for j = 1:times
        pause(0.1);
        cuedata = [k, j, cues(k,(5*(j-1)) + 1:(5*(j-1)) + 5)];
        fprintf(udpA, num2str(cuedata));
    end

    fprintf('data sent\n');

    result = str2double(fscanf(udpA2));
    resultStr = sprintf('Your choice is: %s', drinks(result));
    
    Screen('DrawText', w, resultStr, 100, 100, tcolor);
    Screen('Flip', w);

    WaitSecs(1);

end

assignin('base', 'Stims', stimulus);
assignin('base', 'Cues', cues); 

% This "catch" section executes in case of an error in the "try" section
% above.  Importantly, it closes the onscreen window if it's open.
Screen('CloseAll');
psychrethrow(psychlasterror);
end


 