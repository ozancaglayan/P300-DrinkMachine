range = 13:400;
stim_count = length(range);
average_eeg = zeros(2, 180);
for i = range
average_eeg(stimulus(i) + 1, :) = average_eeg(stimulus(i) + 1, :) + n_eeg(cues(i):cues(i)+180-1);
end
target_count = length(find(stimulus(range)));
average_eeg(1, :) = average_eeg(1, :) ./ (stim_count - target_count);
average_eeg(2, :) = average_eeg(2, :) ./ target_count;
plot(average_eeg(1,:), 'b-'); hold on; plot(average_eeg(2,:), 'r-'); legend('Non-target', 'Target')