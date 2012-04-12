%-- 12.04.2012 13:24 --%
plot(average_eeg(1,:))
hold on;
plot(average_eeg(5,:))
plot(eeg)
stimulus(1,1)
stimulus(1,2)
stimulus(1,3)
stimulus(1,4)
stimulus(1,50)
stimulus(1,501)
stimulus(1,51
)
stimulus(1,50)
a_eeg = zeros(5, 160);
for i=1:50
a_eeg(stimulus(1, i), :) = a_eeg(stimulus(1, i), :) + eeg(1, audio_cues(1, i):audio_cues(1,i)+159);
plot(a_eeg(5,:)); pause(1);
end
mean(a_eeg(1,:))
mean(a_eeg(2,:))
mean(a_eeg(3,:))
mean(a_eeg(4,:))
mean(a_eeg(5,:))
a_eeg(5,:) = a_eeg(5,:) ./ 50;
mean(a_eeg(5,:))
plot(a_eeg(5,:))
a_eeg(4,:) = a_eeg(4,:) ./ 50;
clear a_eeg;
a_eeg = zeros(5, 160);
for i=1:200
a_eeg(stimulus(1, i), :) = a_eeg(stimulus(1, i), :) + eeg(1, audio_cues(1, i):audio_cues(1,i)+159);
end
mean(a_eeg(:,:))
mean(a_eeg(1,:))
mean(a_eeg(2,:))
mean(a_eeg(3,:))
mean(a_eeg(4,:))
mean(a_eeg(5,:))
a_eeg(5,:) / 40
mean(a_eeg(5,:) / 40)
mean(a_eeg(4,:) / 40)
mean(a_eeg(3,:) / 40)
mean(a_eeg(2,:) / 40)
mean(a_eeg(1,:) / 40)
mean(a_eeg(1,:) ./ 40)
clear a_eeg;
a_eeg = zeros(5, 160);
for i = 1:nb_trials * length(drinks)
a_eeg(stimulus(1, i), :, 1) = a_eeg(stimulus(1, i), :, 1) +  eeg(1, audio_cues(1, i):audio_cues(1, i)+160-1);
end
plot(a_eeg(1,:))
hold on; plot(a_eeg(2,:), 'r'); plot(a_eeg(3,:), 'g'); plot(a_eeg(4,:), 'k'); plot(a_eeg(5,:), 'm')
length(drinks)
clear a_eeg;
% Average the signals
for i = 1:nb_trials * length(drinks)
average_eeg(stimulus(n_run, i), :, n_run) = ...
average_eeg(stimulus(n_run, i), :, n_run) ...
+ eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_n_eeg(stimulus(n_run, i), :, n_run) = ...
average_n_eeg(stimulus(n_run, i), :, n_run) ...
+ n_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_clean_eeg(stimulus(n_run, i), :, n_run) = ...
average_clean_eeg(stimulus(n_run, i), :, n_run) ...
+ clean_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
end
for i = 1:length(drinks)
average_eeg(i, :, n_run) = average_eeg(i, :, n_run) / nb_trials;
average_n_eeg(i, :, n_run) = average_n_eeg(i, :, n_run) / nb_trials;
average_clean_eeg(i, :, n_run) = average_clean_eeg(i, :, n_run) / nb_trials;
end
n_run = 1;
% Average the signals
for i = 1:nb_trials * length(drinks)
average_eeg(stimulus(n_run, i), :, n_run) = ...
average_eeg(stimulus(n_run, i), :, n_run) ...
+ eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_n_eeg(stimulus(n_run, i), :, n_run) = ...
average_n_eeg(stimulus(n_run, i), :, n_run) ...
+ n_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_clean_eeg(stimulus(n_run, i), :, n_run) = ...
average_clean_eeg(stimulus(n_run, i), :, n_run) ...
+ clean_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
end
for i = 1:length(drinks)
average_eeg(i, :, n_run) = average_eeg(i, :, n_run) / nb_trials;
average_n_eeg(i, :, n_run) = average_n_eeg(i, :, n_run) / nb_trials;
average_clean_eeg(i, :, n_run) = average_clean_eeg(i, :, n_run) / nb_trials;
end
trial_window_size = 160;
% Average the signals
for i = 1:nb_trials * length(drinks)
average_eeg(stimulus(n_run, i), :, n_run) = ...
average_eeg(stimulus(n_run, i), :, n_run) ...
+ eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_n_eeg(stimulus(n_run, i), :, n_run) = ...
average_n_eeg(stimulus(n_run, i), :, n_run) ...
+ n_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
average_clean_eeg(stimulus(n_run, i), :, n_run) = ...
average_clean_eeg(stimulus(n_run, i), :, n_run) ...
+ clean_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
end
for i = 1:length(drinks)
average_eeg(i, :, n_run) = average_eeg(i, :, n_run) / nb_trials;
average_n_eeg(i, :, n_run) = average_n_eeg(i, :, n_run) / nb_trials;
average_clean_eeg(i, :, n_run) = average_clean_eeg(i, :, n_run) / nb_trials;
end
p300_graph(average_clean_eeg, drinks)
p300_graph(average_eeg, drinks)
p300_graph(average_n_eeg, drinks)
p300_graph(average_clean_eeg, drinks)
p300_graph(wavelets, drinks)
plot(eeg)
plot(clean_eeg)
p300_graph(wavelets, drinks)
[results(n_run), wavelets(:, :, n_run)] = processdata(clean_eeg(n_run, :), ...
stimulus(n_run, :), ...
audio_cues(n_run, :), ...
nb_trials, sample_rate, ...
trial_window_size, drinks, 'db4');
plot(clean_eeg); hold on; plot(eegwzm, 'r')
clc
[1:160]
t = [1:160];
plot(sin(2*pi*t*3/200))
dummy = sin(2*pi*t*3/200);
modified_eeg = eeg;
for i = 1:nb_trials * length(drinks)
stimulus(i,:)
stimulus(1,:)
stimulus(2,:)
stimulus(1,:)
find(stimulus(1,:), 5)
find(stimulus(1,:))
stimulus(1,:)
help find
find(stimulus(1,:) = 5)
find(stimulus(1,:) > 3)
find(stimulus(1,:) > 4)
stimulus(1,1)
for i = find(stimulus(1,:) > 4)
modified_eeg(1, audio_cues(1, i):audio_cues(1, i)+159) = dummy;
end
plot(modified_eeg)
modified_eeg = eeg;
for i = find(stimulus(1,:) > 4)
modified_eeg(1, audio_cues(1, i):audio_cues(1, i)+159) = modified_eeg(1, audio_cues(1, i):audio_cues(1, i)+159) + dummy;
end
plot(modified_eeg)
[r, m_waves] = processdata(modified_eeg(1, :), stimulus(1, :), audio_cues(1, :), nb_trials, sample_rate, trial_window_size, {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'}, 'db4');
p300_graph(m_waves, drinks)
modified_average = zeros(5, 160);
for i = 1:nb_trials * length(drinks)
modified_average(stimulus(n_run, i), :, n_run) =  modified_average(stimulus(n_run, i), :, n_run) + modified_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
end
p300_graph(modified_average, drinks)
plot(modified_average(5,:))
hold on;
plot(average_eeg(5,:))
plot(average_eeg(4,:))
plot(average_eeg(4,:)); hold on;
plot(modified_average(5,:))
for i = 1:length(drinks)
modified_average(i, :, n_run) = modified_eeg(i, :, n_run) / nb_trials;
end
for i = 1:length(drinks)
modified_average(i, :) = modified_eeg(i, :) / nb_trials;
done
end
for i = 1:length(drinks)
modified_average(i, :) = modified_average(i, :) / nb_trials;
end
p300_graph(modified_average, drinks)
plot(modified_average(5,:))
hold on;
plot(average_eeg(5,:), 'r'))
plot(average_eeg(5,:), 'r')
modified_eeg = eeg;
for i = find(stimulus(1,:) > 4)
modified_eeg(1, audio_cues(1, i):audio_cues(1, i)+159) =modified_eeg(1, audio_cues(1, i):audio_cues(1, i)+159) + 50*dummy;
end
[r, m_waves] = processdata(modified_eeg(1, :), stimulus(1, :), audio_cues(1, :), nb_trials, sample_rate, trial_window_size, {'Water', 'Coffee', 'Tea', 'Soda', 'Beer'}, 'db4');
modified_average = zeros(5, 160);
for i = 1:nb_trials * length(drinks)
modified_average(stimulus(n_run, i), :, n_run) =  modified_average(stimulus(n_run, i), :, n_run) + modified_eeg(n_run, audio_cues(n_run, i):audio_cues(n_run, i)+trial_window_size-1);
end
plot(modified_average(5,:))
for i = 1:length(drinks)
modified_average(i, :) = modified_average(i, :) / nb_trials;
end
plot(modified_average(5,:))
p300_graph(m_waves, drinks)
plot(modified_eeg, 'm')
hold on;
plot(eegwzm, 'k')
p300_graph(m_waves, drinks)
plot(m_waves(5,:))
hold on;plot(modified_average(5,:), 'r')
32000/200
32000/200/60
