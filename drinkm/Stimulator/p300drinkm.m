function p300drinkm(times, runs, ftime, noftime, samplerate)

% Store drink names
drinks = {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'};

% Used to trigger the Analyzer
mynoise(1,:) = MakeBeep(1000, 0.1, 8192);

% Stimulus data
stimulus = zeros(runs, times * length(drinks));

% Cues for timestamps
cues = zeros(runs, times * length(drinks));

% Load auditory stimuli
load('data/soundz.mat', 'soundz');

GetSecs;

% Colors
tcolor  = [128 128 128];

% Open window
w = Screen('OpenWindow', 0, [0 0 0]);
Screen('Preference', 'TextAntialiasing', 0);
Screen('Preference', 'Verbosity', 5);
HideCursor;
Priority(MaxPriority(w));

% The slack is just to place the stimulus presentation deadline
% in the middle of a video refresh cycle, so it has some "slack" to the
% previous and next frame boundary.
slack = Screen('GetFlipInterval', w) / 2;

% Load images and create PTB textures
textures = zeros(6, 1);

for i=1:6
    % 6th one is the default background
    textures(i) = Screen('MakeTexture', w, imread(strcat('data/drinks', num2str(i), '.jpg')));
end

% Preload textures into VRAM if possible
Screen('PreloadTextures', w, textures);

% Draw background
Screen('DrawTexture', w, textures(6));
Screen('Flip', w, [], 1);

ipA = '10.1.2.142';
portA  = 9090;
portA2 = 9092;

portB  = 9091;
portB2 = 9093;

udpA = udp(ipA, portB, 'LocalPort', portA);
udpA2 = udp(ipA, portA2, 'LocalPort', portB2);

fopen(udpA);
fopen(udpA2);
fprintf('ports opened\n');

handshake(udpA, udpA2);

fprintf('sending data');

fprintf(udpA, num2str(times));
fprintf(udpA, num2str(runs));
fprintf(udpA, num2str(ftime));
fprintf(udpA, num2str(noftime));
fprintf(udpA, num2str(samplerate));

fprintf('data sent');
Screen('DrawText', w, 'Communication: OK.', 100, 100, tcolor);
Screen('Flip', w, [], 1);

% Pre-generate permutations
for r = 1:runs
    for t = 1:times
        perm = randperm(length(drinks));
        bound = length(drinks) * t;
        stimulus(r, bound-4:bound) = perm;
    end
end

for k = 1:runs
    % Prepare the subject
    Screen('DrawText', w, '3', 100, 130, tcolor);
    Screen('Flip', w, [], 1);
    WaitSecs(1);
    Screen('DrawText', w, '2', 120, 130, tcolor);
    Screen('Flip', w, [], 1);
    WaitSecs(1);
    Screen('DrawText', w, '1', 140, 130, tcolor);
    Screen('Flip', w, [], 1);
    WaitSecs(1);

    % Play the sound which will start EEG recording immediately
    Snd('Play', mynoise, 8192, 16);
    %WaitSecs(0.2);

    % Record the start time
    last_onset = GetSecs();

    for stim_count = 1:times * length(drinks)
        target_time = last_onset + noftime - slack;
        stimuli = stimulus(k, stim_count);

        Screen('DrawTexture', w, textures(stimuli));

        % Record the flip timestamp
        cues(k, stim_count) = Screen('Flip', w, target_time);
        
        % Play sound asynchronously
        sound(soundz(stimuli, :), 16000);

        % Draw the background and wait noftime
        Screen('DrawTexture', w, textures(6));
        last_onset = Screen('Flip', w, cues(k, stim_count) + ftime - slack);
    end

    % Round (and make sure that none of the cues == 0)
    cues(k, :) = int32(ceil(cues(k, :) * sample_rate));
    % cues(k, 1) = cues(k, 1) + 1;
    
    assignin('base', 'stimulus', stimulus);
    assignin('base', 'cues', cues);

    % Waiting for process
    Screen('DrawText', w, 'Waiting for results..', 100, 100, tcolor);
    Screen('Flip', w);

    handshake(udpA, udpA2);

    fprintf('Sending data\n');
    
    fwrite(udpA, cues(k, :), 'int32');
    pause(0.1);
    fwrite(udpA, stimulus(k, :));

    fprintf('data sent\n');

    % Get the result and print that on the screen
    result = str2double(fscanf(udpA2));
    resultStr = sprintf('Your choice is: %s', drinks{result});
    Screen('DrawText', w, resultStr, 100, 100, tcolor);
    Screen('Flip', w);

    % Wait 1 second
    WaitSecs(1);
end

KbWait;
Priority(0);

fclose(udpA);
fclose(udpA2);

% This "catch" section executes in case of an error in the "try" section
% above.  Importantly, it closes the onscreen window if it's open.
Screen('CloseAll');
rethrow(psychlasterror);
end


 