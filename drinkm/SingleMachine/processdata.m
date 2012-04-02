function[result] = processdata(eeg, stims, cues, times)

% EEG wavelet
[C,L] = wavedec(eeg, 8, 'db4');
D6    = wrcoef('d', C, L, 'db4', 6);
D7    = wrcoef('d', C, L, 'db4', 7);
D8    = wrcoef('d', C, L, 'db4', 8);
eegw  = D8 + D6 + D7;

% EEG zero mean
eegwzm = eegw - mean(eegw);

% Initialize EEG data variable
eegdata = zeros(5, 160);

for j = 1:(times * 5)
    eegdata(stims(j), :) = eegdata(stims(j), :) + eegwzm(cues(j):cues(j) + 159);
end

eegdata = eegdata / times;

tops = zeros(1, 5);

for i = 1:5
    tops(1, i) = (norm(eegdata(i, 60:10:100)) / sqrt(times)) * sign(sum(eegdata(i, 60:10:100)));
end

[C, I] = max(tops(1:5));

result = I;

assignin('base', 'eegdata', eegdata);

end




