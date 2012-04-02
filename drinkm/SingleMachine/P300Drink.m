% Entry point for the P300 Drink Experiment
                
function P300Drink()

try
    % Initialize PsychSound for low-latency sound playback
    InitializePsychSound(1);
    PsychPortAudio('Verbosity', 5);
    
    GetSecs;

    %%%
    % Default experiment parameters
    %%%
    
    % Store drink names
    drinks = {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'};
    
    % Load audio data, each stimulus is 0.5 seconds long
    sounds = zeros(length(drinks), 8000);
    for i = 1:length(drinks)
        [sounds(i,:), sampling_freq, ~] = wavread(strcat('data\', drinks{i}, '.wav'));
    end
      
    % Get a PA handle for audio playback
    pahandle = PsychPortAudio('Open', [], [], 1, sampling_freq, 1); 
    
    % Number of repetitions (i.e. How much experiments are we going to do?)
    nb_repetition = 1;
    
    % Number of trials for each repetition
    nb_trial = 1;
    
    % Sample rate in Hz to pass to the underlying acquisiton device
    sample_rate = 200;
    
    % Highlighting time in s (i.e. A specific drink is painted)
    flash_time = 0.500;
    
    % Steady state time in s (i.e. Background texture is shown)
    noflash_time = 0.300;
    
    % Create MP35 object
    mp35 = BIOPACDevice('C:\BHAPI\', 'mp35', 'usb', sample_rate, {'a22'});
    
    % Pre-allocate stimulus data (5 = len(drinks))
    stimulus = zeros(nb_repetition, nb_trial * length(drinks));
    
    % Pre-allocate cues for delays
    cues = zeros(nb_repetition, nb_trial * length(drinks));
    
    % Colors
    fg_color = [255 255 255];

    % Open window
    window = Screen('OpenWindow', 0, [0 0 0]);
    flip_interval = Screen('GetFlipInterval', window);
    
    % Load images and create PTB textures       
    tex0 = Screen('MakeTexture', window, imread('data/drinksback', 'JPG'));
    tex1 = Screen('MakeTexture', window, imread('data/Water', 'JPG'));
    tex2 = Screen('MakeTexture', window, imread('data/Coffee', 'JPG'));
    tex3 = Screen('MakeTexture', window, imread('data/Tea', 'JPG'));
    tex4 = Screen('MakeTexture', window, imread('data/Soda', 'JPG'));
    tex5 = Screen('MakeTexture', window, imread('data/Beer', 'JPG'));
    textures = [tex1, tex2, tex3, tex4, tex5];
    
    %ListenChar(2);
    
    % Start the experiment. Outer loop is for each repetition.
    for repetition_count = 1:nb_repetition
        count = 0;
        
        % Show countdown to prepare the subject
        Screen('DrawText', window, '3', 100, 100, fg_color);
        Screen('Flip', window);
        WaitSecs(1);
        Screen('DrawText', window, '2', 100, 100, fg_color);
        Screen('Flip', window);
        WaitSecs(1);
        Screen('DrawText', window, '1', 100, 100, fg_color);
        Screen('Flip', window);
        
        %tic;
        %WaitSecs(1);
        
        for trial_count = 1:nb_trial
            
            % Random flashing order for drinks
            for flashing = randperm(5)
                PsychPortAudio('FillBuffer', pahandle, sounds(flashing, :));

                % Draw the new texture
                Screen('DrawTexture', window, textures(flashing));
                
                target = GetSecs + noflash_time;
                
                % check for key-press to cleanly interrupt the experiment
%                 [keyPressed, ~, keyCode, ~] = KbCheck;
%                 
%                 if keyPressed && keyCode(KbName('ESCAPE'))
%                     me = MException('p300drink:experimentinterrupted', ...
%                         'user interrupted the experiment');
%                     throw(me);
%                 end
                
                
                % Put some data in cues and stimulus
                count = count + 1;
                cues(repetition_count, count) = toc;
                stimulus(repetition_count, count) = flashing;
                
                % target = target + noflash_time;

                startTime = PsychPortAudio('Start', pahandle, [], target, 1);
                PsychPortAudio('Start', pahandle, [], target);
                %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window, target);
                Screen('Flip', window, target);
                
                %fprintf('VBLTimestamp: %f, Audio Timestamp: %f\n', VBLTimeStamp, startTime);

                
                % Highlight for flash_time ms.
                % WaitSecs(flash_time);
                
                % Revert back to the background texture and wait noflash_time ms.
                %target = target + flash_time;
                Screen('DrawTexture', window, tex0);
                Screen('Flip', window, target + flash_time);
                %WaitSecs(noflash_time);
            end
        end
    end
    
    KbWait;
    Screen('CloseAll');
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
    
catch err
    if strcmp(err.identifier, 'P300Drink:ExperimentInterrupted')
        fprintf('Interrupted: %s', err.msg);
    end
    
    mp35.disconnect();
    
    if window
        Screen('CloseAll');
    end
    
    if pahandle
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close', pahandle);
    end
    rethrow(err);

% End of try-catch block
end

% End of function
end