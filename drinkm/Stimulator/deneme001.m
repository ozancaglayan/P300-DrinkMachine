function p300drinkm(times, runs, ftime, noftime, samplerate)

% Store drink names
drinks = ['Water', 'Coffee', 'Tea', 'Soda', 'Beer'];

% Load auditory stimuli
load('data/soundz.mat', 'soundz');

% Initialize PTB
Screen('Preference', 'SkipSyncTests', 0);

% Choosing the display with the highest dislay number is
% a best guess about where you want the stimulus displayed.
screens = Screen('Screens');
screenNumber = max(screens);

% Colors
bcolor  = [0 0 0];
tcolor  = [128 128 128];

% Open window
w = Screen('OpenWindow', screenNumber);
Screen('FillRect', w, bcolor);

% Load images and create PTB textures
texback = Screen('MakeTexture', w, double(imread('data/drinksback', 'JPG')));
tex1 = Screen('MakeTexture', w, double(imread('data/drinks1', 'JPG')));
tex2 = Screen('MakeTexture', w, double(imread('data/drinks2', 'JPG')));
tex3 = Screen('MakeTexture', w, double(imread('data/drinks3', 'JPG')));
tex4 = Screen('MakeTexture', w, double(imread('data/drinks4', 'JPG')));
tex5 = Screen('MakeTexture', w, double(imread('data/drinks5', 'JPG')));
textures = [tex1, tex2, tex3, tex4, tex5];

Screen('DrawText', w, 'Connecting to other computer', 100, 100, tcolor);
Screen('Flip', w);

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

Screen('DrawText', w, 'ports opened', 100, 100, tcolor);
Screen('Flip',w);

handshake(udpA, udpA2);

fprintf('sending data');
Screen('DrawText', w, 'Sending initial parameters', 100, 100, tcolor);
Screen('Flip', w);

fprintf(udpA, num2str(times));
fprintf(udpA, num2str(runs));
fprintf(udpA, num2str(ftime));
fprintf(udpA, num2str(noftime));
fprintf(udpA, num2str(samplerate));

fprintf('data sent');
Screen('DrawText', w, 'initial values sent', 100, 100, tcolor);
Screen('Flip', w);

% Used to trigger the Analyzer
mynoise(1,:) = MakeBeep(1000, 0.1, 8192);

stimulus = zeros(runs, times * 5);

% Cues for delays
cues = zeros(runs, times * 5);

for k = 1:runs
    count = 0;

    Screen('DrawText', w, '3', 100, 100, tcolor);
    Screen('Flip', w);
    WaitSecs(1);
    Screen('DrawText', w, '2', 100, 100, tcolor);
    Screen('Flip', w);
    WaitSecs(1);
    Screen('DrawText', w, '1', 100, 100, tcolor);
    Screen('Flip', w);
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

kbwait

fclose(udpA);
delete(udpA);
fclose(udpA2);
delete(udpA2);
clear udpA udpA2

% This "catch" section executes in case of an error in the "try" section
% above.  Importantly, it closes the onscreen window if it's open.
Screen('CloseAll');
psychrethrow(psychlasterror);
end


 