n_run = 1;
wfilter = 'db4';
colors = {'b', 'c', 'r', 'm', 'k'};

% How many plots do we want
steps = 4;
window_size = (nb_trials * length(drinks))/steps;
window_size = 20;
trial_window_size = (noflash_time + flash_time) * sample_rate;

figure(2);

for window = 1:steps
    averaged_eeg = zeros(length(drinks), 160);
    count = zeros(length(drinks), 1);
    
    for i = 1: window * window_size
        averaged_eeg(stimulus(i), :) = averaged_eeg(stimulus(i), :) + n_eeg(n_run, audio_cues(i):audio_cues(i)+trial_window_size-1);
        count(stimulus(i)) = count(stimulus(i)) + 1;
    end
    
    p300_value = 0;
    p300_x = 0;
    
    for drink = 1:length(drinks)
        cur_avg = averaged_eeg(drink, :)./count(drink);
        figure(1);
        subplot(steps,1, window);
        title(strcat(num2str(i/5), ' Hedef Uyaran'));
        hold on;
        plot(cur_avg, colors{drink});
        figure(2);
        subplot(steps, 1, window);
        title(strcat(num2str(i/5), ' Hedef Uyaran'));
        hold on;
        % Wavelets
        [C,L] = wavedec(cur_avg, 8, wfilter);
        D6    = wrcoef('d', C, L, wfilter, 6);
        D7    = wrcoef('d', C, L, wfilter, 7);
        D8    = wrcoef('d', C, L, wfilter, 8);      
        eegw  = D8 + D7 + D6;
        eegwzm = eegw - mean(eegw);
        plot(eegwzm, colors{drink});
    end
    
    figure(1);
    axis([0 trial_window_size -.2 .4]);
    figure(2);
    axis([0 trial_window_size -.2 .4]);
    if window == steps
        suptitle('Wavelet');
        %legend({'Su', 'Kahve', 'Çay', 'Soda', 'Bira'}, 'Location', 'Best');
        figure(1);
        suptitle('Ortalama P300');
        %legend({'Su', 'Kahve', 'Çay', 'Soda', 'Bira'}, 'Location', 'Best');
    end
end
