function[eegdata] = processdata(eeg, stims, cues, sample_rate, ftime, noftime, wfilter)

% EEG wavelet
[C,L] = wavedec(eeg, 8, wfilter);
D6    = wrcoef('d', C, L, wfilter, 6);
D7    = wrcoef('d', C, L, wfilter, 7);
D8    = wrcoef('d', C, L, wfilter, 8);
eegw  = D8 + D6 + D7;

% EEG zero mean
eegwzm = eegw - mean(eegw);

% Initialize EEG data variable
window_length = (noftime + ftime) * sample_rate;
eegdata = zeros(2, window_length);

for j = 1:2
    eegdata(stims(j)+1, :) = eegdata(stims(j)+1, :) + eegwzm(cues(j):cues(j) + window_length - 1);
end

end




