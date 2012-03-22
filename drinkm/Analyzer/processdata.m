function[result] = processdata(eeg, stims, cues, times)

% EEG wavelet
[C,L] = wavedec(eeg, 8, 'db4');
D6    = wrcoef('d', C, L, 'db4', 6);
D7    = wrcoef('d', C, L, 'db4', 7);
D8    = wrcoef('d', C, L, 'db4', 8);
eegw  = D8 + D6 + D7;

% EEG zero mean
% EMG: eegw = eeg;
eegwzm = eegw - mean(eegw);

% Initialize EEG data variable
% FIXME: Why 160? (0.800 flash time)
eegdata = zeros(5, 160);

if cues(1) == 0
    cues(1) = 1;
end

for j = 1:(times * 5)
    eegdata(stims(j), :) = eegdata(stims(j), :) + eegwzm(cues(j):cues(j) + 159);
end

eegdata = eegdata / times;

tops = zeros(1, 5);

for i = 1:5
    % 60:10:100 -> P300 (60th sample = 0.300 ms for sampling rate == 200)
    tops(1, i) = sqrt(sum((eegdata(i, 60:100).^2)) / (100-60));
    %tops(1, i) = (norm(p300_eeg) / sqrt(times)) * sign(sum(p300_eeg));
end

[C, I] = max(tops(1:5));

result = I;

assignin('base', 'eegdata', eegdata);

end




