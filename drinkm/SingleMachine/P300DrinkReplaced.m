% Entry point for the P300 Drink Experiment
function P300Drink()

try
    % Initialize PsychSound for low-latency sound playback
    InitializePsychSound(1);
    PsychPortAudio('Verbosity', 1);
    
    GetSecs;

    % Store drink names
    drinks = {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'};
    assignin('base', 'drinks', drinks);
    
    % Load audio data, each stimulus is 0.5 seconds long
    frequency = 48000;
    nr_channels = 2;
    sounds = zeros(nr_channels, frequency / 2, length(drinks));
    for i = 1:length(drinks)
        [tmp, ~, ~] = wavread(strcat('data\', drinks{i}, '.wav'));
        sounds(1, :, i) = interp(tmp, 3);
        sounds(2, :, i) = interp(tmp, 3);
    end
    assignin('base', 'sounds', sounds);
    
    % Get a PA handle for audio playback
    reqlatencyclass = 2;
    suggestedlatency = 0.0010;
    pahandle = PsychPortAudio('Open', [], [], reqlatencyclass, ...
                              frequency, nr_channels, [], suggestedlatency);
    
    % Number of repetitions (i.e. How much experiments are we going to do?)
    nb_runs = 1;
    
    % Number of trials for each repetition
    nb_trials = 11;
    
    % Sample rate in Hz to pass to the underlying acquisiton device
    sample_rate = 200;
    
    % Highlighting time in s (i.e. A specific drink is painted)
    flash_time = 0.300;
    
    % Steady state time in s (i.e. Background texture is shown)
    noflash_time = 0.500;

    % Create MP35 object
    channels = {'a22', 'a16'};
    mp35 = BIOPACDevice('C:\BHAPI\', 'mp35', 'usb', sample_rate, channels);
    
    % Single trial window length (160 by default)
    trial_window_size = (noflash_time + flash_time) * sample_rate;
    
    % Add 1 second worth of padding for now
    trial_samples = (trial_window_size * (nb_trials-1) * length(drinks)) + sample_rate;
    assignin('base', 'trial_samples', trial_samples);
    
    % For storing the results
    results(1:nb_runs) = 0;

    % Pre-allocate stimulus data (5 = len(drinks))
    stimulus = zeros(nb_runs, nb_trials * length(drinks));
    
    % Pre-allocate video_cues for delays
    video_cues = zeros(nb_runs, nb_trials * length(drinks));
    audio_cues = zeros(nb_runs, nb_trials * length(drinks));
    ts_video_cues = zeros(nb_runs, nb_trials * length(drinks));
    ts_audio_cues = zeros(nb_runs, nb_trials * length(drinks));
    
    % EEG data
    eeg = zeros(nb_runs, trial_samples);
    ecg = zeros(nb_runs, trial_samples);
    mic = zeros(nb_runs, trial_samples);
    
    % Normalized ones
    n_eeg = zeros(nb_runs, trial_samples);
    n_ecg = zeros(nb_runs, trial_samples);
    
    % Clean EEG
    clean_eeg = zeros(nb_runs, trial_samples);

    % Averaged ones
    average_eeg = zeros(length(drinks), trial_window_size, nb_runs);
    average_n_eeg = zeros(length(drinks), trial_window_size, nb_runs);
    average_clean_eeg = zeros(length(drinks), trial_window_size, nb_runs);
    
    % Processed EEG's
    wavelets = zeros(length(drinks), trial_window_size, nb_runs);

    % Open window
    window = Screen('OpenWindow', 0, [0 0 0]);
    Priority(MaxPriority(window));
    
    % Suppress outputs
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
    for n_run = 1:nb_runs
        for n_trial = 1:nb_trials
            perm = randperm(length(drinks));
            bound = length(drinks) * n_trial;
            %if ~all(perm == 1:length(drinks)) && ...
                    %(max(ismember(stimulus(n_run, bound-4:bound), perm, 'rows')) == 0)
            stimulus(n_run, bound-4:bound) = perm;
            %end
        end
    end
    
    assignin('base', 'stimulus', stimulus);

    % Start the experiment. Outer loop is for each repetition.
    for n_run = 1:nb_runs       
        % Prepare the subject first
        Screen('DrawTexture', window, textures(6));
        Screen('Flip', window);
        WaitSecs(1.0);
        
        % Start acquisition
        mp35.startAcquisition();
        
        % Get the start_time in secs
        last_onset = GetSecs();
        initial_start = last_onset;
        
        % stim_count counts from 1 to 25 if length(drinks) == 5
        for stim_count = 1:nb_trials * length(drinks)
            target_time = last_onset + noflash_time - slack;

            % Fetch stimuli (e.g. one of {1,2,3,4,5})
            stimuli = stimulus(n_run, stim_count);
            
            % Draw the new texture
            Screen('DrawTexture', window, textures(stimuli));
            
            % Fill audio buffer
            PsychPortAudio('FillBuffer', pahandle, sounds(:, :, stimuli));
            ts_audio_cues(n_run, stim_count) = PsychPortAudio('Start', pahandle, [], target_time, 1);

            % Flip and save stimulus onset time into video_cues
            ts_video_cues(n_run, stim_count) = Screen('Flip', window, target_time);
            
            % Revert back to the background texture and wait noflash_time ms.
            Screen('DrawTexture', window, textures(6));
            last_onset = Screen('Flip', window, ts_video_cues(n_run, stim_count) + flash_time - slack);
        end
        
        % Stop acquisition
        buff = mp35.readAndStopAcquisition(trial_samples + 800);
        assignin('base', 'buff', buff);
        
        eeg(n_run, :) = buff(1, trial_window_size*length(drinks)+1:end);
        ecg(n_run, :) = buff(2, trial_window_size*length(drinks)+1:end);
        %mic(n_run, :) = buff(3,:);
        
        assignin('base', 'eeg', eeg);
        assignin('base', 'ecg', ecg);
        %assignin('base', 'mic', mic);
        
        % Normalize cues
        video_cues(n_run, :) = int32(ceil((ts_video_cues(n_run, :) - initial_start) * sample_rate));
        audio_cues(n_run, :) = int32(ceil((ts_audio_cues(n_run, :) - initial_start) * sample_rate));
        
        assignin('base', 'video_cues', video_cues);
        assignin('base', 'audio_cues', audio_cues);
        assignin('base', 'ts_video_cues', ts_video_cues);
        assignin('base', 'ts_audio_cues', ts_audio_cues);
        
        % Normalize signals between (-1, 1), use maximum value
        % from 1000:end as the beginnings of the records are noisy and fluctuating.
        n_eeg(n_run, :) = eeg(n_run, :)./max(eeg(n_run, 1000:end));
        n_ecg(n_run, :) = ecg(n_run, :)./max(ecg(n_run, 1000:end));
        
        % Shrink cues and stimulus down to (nb-trial-1)*length(drinks)
        shrinked_cues = video_cues(n_run, length(drinks)+1:end) - (length(drinks)*trial_window_size);
        shrinked_stimulus = stimulus(n_run, length(drinks)+1:end);

        assignin('base', 'stimulus', shrinked_stimulus);
        assignin('base', 'cues', shrinked_cues);
        
        % Subtract ECG from EEG
        clean_eeg(n_run, :) = n_eeg(n_run, :) - n_ecg(n_run, :);
        
        assignin('base', 'n_eeg', n_eeg);
        assignin('base', 'n_ecg', n_ecg);
        assignin('base', 'clean_eeg', clean_eeg);
     
        % Average the signals
        for i = 1:(nb_trials-1) * length(drinks)
            average_eeg(shrinked_stimulus(n_run, i), :, n_run) = ...
                average_eeg(shrinked_stimulus(n_run, i), :, n_run) ...
                + eeg(n_run, shrinked_cues(n_run, i):shrinked_cues(n_run, i)+trial_window_size-1);
            average_n_eeg(shrinked_stimulus(n_run, i), :, n_run) = ...
                average_n_eeg(shrinked_stimulus(n_run, i), :, n_run) ...
                + n_eeg(n_run, shrinked_cues(n_run, i):shrinked_cues(n_run, i)+trial_window_size-1);
            average_clean_eeg(shrinked_stimulus(n_run, i), :, n_run) = ...
                average_clean_eeg(shrinked_stimulus(n_run, i), :, n_run) ...
                + clean_eeg(n_run, shrinked_cues(n_run, i):shrinked_cues(n_run, i)+trial_window_size-1);
        end
        
        for i = length(drinks)
            average_eeg(i, :, n_run) = average_eeg(i, :, n_run) / (nb_trials-1);
            average_n_eeg(i, :, n_run) = average_n_eeg(i, :, n_run) / (nb_trials-1);
            average_clean_eeg(i, :, n_run) = average_clean_eeg(i, :, n_run) / (nb_trials-1);
        end
        
        assignin('base', 'average_eeg', average_eeg);
        assignin('base', 'average_n_eeg', average_n_eeg);
        assignin('base', 'average_clean_eeg', average_clean_eeg);
        
        % Process results
        [results(n_run), wavelets(:, :, n_run)] = processdata(clean_eeg(n_run, :), ...
            shrinked_stimulus(n_run, :), ...
            shrinked_cues(n_run, :), ...
            nb_trials-1, sample_rate, ...
            trial_window_size, drinks, 'db4');

    end
    assignin('base', 'wavelets', wavelets);    
    assignin('base', 'results', results);

    Priority(0);
    Screen('CloseAll');
    mp35.disconnect();
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);
       
catch err
    if strcmp(err.identifier, 'P300Drink:ExperimentInterrupted')
        fprintf('Interrupted: %s', err.msg);
    end
    
    Priority(0);
    mp35.disconnect();
    
    Screen('CloseAll');
    
    PsychPortAudio('Stop', pahandle);
    PsychPortAudio('Close', pahandle);

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