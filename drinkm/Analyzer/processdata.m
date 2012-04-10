function[result, eegdata] = processdata(eeg, stims, cues, times, sample_rate, ...
                                        ftime, noftime, drinks, wfilter)

% EEG wavelet
[C,L] = wavedec(eeg, 8, wfilter);
D6    = wrcoef('d', C, L, wfilter, 6);
D7    = wrcoef('d', C, L, wfilter, 7);
D8    = wrcoef('d', C, L, wfilter, 8);
eegw  = D8 + D6 + D7;

% EEG zero mean
eegwzm = eegw - mean(eegw);

% P300 interval: 0.3sec - 0.5sec
p300_start = 0.3 * sample_rate;
p300_end = 0.5 * sample_rate;

% Initialize EEG data variable
window_length = (noftime + ftime) * sample_rate;
eegdata = zeros(length(drinks), window_length);

for j = 1:(times * length(drinks))
    eegdata(stims(j), :) = eegdata(stims(j), :) + eegwzm(cues(j):cues(j) + window_length - 1);
end

% Average over 'times'
eegdata = eegdata / times;

tops = zeros(1, length(drinks));

for i = 1:length(drinks)
    p300_data = eegdata(i, p300_start:p300_end);
    tops(1, i) = sqrt(sum((p300_data.^2)) / (p300_end-p300_start));
    %tops(1, i) = (norm(p300_data) / sqrt(times)) * sign(sum(p300_data));
end

tops
[C, result] = max(tops(1:length(drinks)));

end




