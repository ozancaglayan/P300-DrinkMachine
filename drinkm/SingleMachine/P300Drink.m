% Entry point for the P300 Drink Experiment
                
function P300Drink()

try
    % Initialize PsychSound for low-latency sound playback
    InitializePsychSound(1);
    PsychPortAudio('Verbosity', 5);
    
    pahandle = 0;
    
    GetSecs;

    %%%
    % Default experiment parameters
    %%%
    
    % Store drink names
    drinks = {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'};
    assignin('base', 'drinks', drinks);
    
    % Load audio data, each stimulus is 0.5 seconds long
    sounds = zeros(length(drinks), 24000);
    for i = 1:length(drinks)
        [tmp, sampling_freq, ~] = wavread(strcat('data\', drinks{i}, '.wav'));
        sounds(i, :) = interp(tmp, 3);
    end
      
    % Get a PA handle for audio playback
    pahandle = PsychPortAudio('Open', [], 1, 4, 48000, 1);
    
    % Number of repetitions (i.e. How much experiments are we going to do?)
    nb_repetition = 1;
    
    % Number of trials for each repetition
    nb_trial = 5;
    
    % Sample rate in Hz to pass to the underlying acquisiton device
    sample_rate = 200;
    
    % Highlighting time in s (i.e. A specific drink is painted)
    flash_time = 0.300;
    
    % Steady state time in s (i.e. Background texture is shown)
    noflash_time = 0.500;
    
    trial_samples = (flash_time + noflash_time) * nb_trial * sample_rate;
    assignin('base', 'trial_samples', trial_samples);
    
    %records(nb_repetition, sample_rate * (flash_time + noflash_time)) = 0;
    
    % Create MP35 object
    %mp35 = BIOPACDevice('C:\BHAPI\', 'mp35', 'usb', sample_rate, {'a22'});
    
    % Pre-allocate stimulus data (5 = len(drinks))
    stimulus = zeros(nb_repetition, nb_trial * length(drinks));
    
    % Pre-allocate cues for delays
    cues = zeros(nb_repetition, nb_trial * length(drinks));

    % Open window
    window = Screen('OpenWindow', 0, [0 0 0]);
    Priority(MaxPriority(window));
    % To suppress outputs
    Screen('Preference', 'Verbosity', 1);
    
    % The slack is just to place the stimulus presentation deadline
    % in the middle of a video refresh cycle, so it has some "slack" to the
    % previous and next frame boundary.
    slack = Screen('GetFlipInterval', window) / 2;
    
    % Pre-allocate textures
    textures = zeros(length(drinks) + 1, 1);
    
    % Load images and create PTB textures
    for i = 1:length(drinks)
        textures(i) = Screen('MakeTexture', window, imread(strcat('data/', drinks{i}, '.jpg')));
    end
    textures(6) = Screen('MakeTexture', window, imread('data/drinksback.jpg'));
    
    % Preload textures if possible
    Screen('PreloadTextures', window, textures);
    
    % This is for disabling keyboard presses
    %ListenChar(2);
    
    % Pre generate random stimulus order
    for r = 1:nb_repetition
        for t = 1:nb_trial
            perm = randperm(length(drinks));
            bound = length(drinks) * t;
            %if ~all(perm == 1:length(drinks)) && ...
                    %(max(ismember(stimulus(r, bound-4:bound), perm, 'rows')) == 0)
            stimulus(r, bound-4:bound) = perm;
            %end
        end
    end
    
    assignin('base', 'stimulus', stimulus);
    
    % Start the experiment. Outer loop is for each repetition.
    for repetition_count = 1:nb_repetition       
        % Prepare the subject first
        Screen('DrawTexture', window, textures(6));
        Screen('Flip', window);
        WaitSecs(1.0);
        
        % Start acquisition
        %mp35.startAcquisition();
        
        % Get the start_time in secs
        last_onset = GetSecs();
        
        % stim_count counts from 1 to 25 if length(drinks) == 5
        for stim_count = 1:nb_trial * length(drinks)
            target_time = last_onset + noflash_time - slack;

            % Fetch stimuli (e.g. one of {1,2,3,4,5})
            stimuli = stimulus(repetition_count, stim_count);
            
            % Draw the new texture
            Screen('DrawTexture', window, textures(stimuli));
            
            % Fill audio buffer
            PsychPortAudio('FillBuffer', pahandle, sounds(stimuli, :));
            PsychPortAudio('Start', pahandle, [], target_time);

            % Flip and save stimulus onset time into cues
            cues(repetition_count, stim_count) = Screen('Flip', window, target_time);
            
            % Revert back to the background texture and wait noflash_time ms.
            Screen('DrawTexture', window, textures(6));
            last_onset = Screen('Flip', window, cues(repetition_count, stim_count) + flash_time - slack);
        end
        
        % Stop acquisition
        %mp35.stopAcquisition();
        %mp35.receiveData();

    end
    
    assignin('base', 'cues', cues);
    KbWait;
    Priority(0);
    Screen('CloseAll');
    %mp35.disconnect();
    if pahandle
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close', pahandle);
    end
       
catch err
    if strcmp(err.identifier, 'P300Drink:ExperimentInterrupted')
        fprintf('Interrupted: %s', err.msg);
    end
    
    Priority(0);
    %mp35.disconnect();
    
    Screen('CloseAll');
    
    if pahandle
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close', pahandle);
    end
    rethrow(err);

% End of try-catch block
end

% End of function
end

            
% check for key-press to cleanly interrupt the experiment
%                 [keyPressed, ~, keyCode, ~] = KbCheck;
%
%                 if keyPressed && keyCode(KbName('ESCAPE'))
%                     me = MException('p300drink:experimentinterrupted', ...
%                         'user interrupted the experiment');
%                     throw(me);
%                 end