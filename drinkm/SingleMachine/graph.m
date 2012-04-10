function graph(eeg, cues, stims, drinks)
samplerate = 200;

plot(eeg, 'g-');
axis([0 length(eeg) -20 20]);
title('Single Run EEG Recording');
xlabel('Sample points');
ylabel('Amplitude');
hold on;
%plot(cues, 0, 'ko');

for i = 1:length(cues)
    text(cues(i), 0.4, strcat('\leftarrow ', drinks{stims(i)}), 'rotation', 90, 'FontSize', 12);
    cue_indicator = line([cues(i), cues(i)], [-0.80, 0.4]);
    set(cue_indicator, 'Color', [0.5 0.5 0.5]);
    % Calculate the area to be colored for flashed interval
    %flash_interval = [cues(i):cues(i)+samplerate*0.5];
    %nonflash_interval = [cues(i)+samplerate*0.5:cues(i)+samplerate*0.8];
    %flash_area = area(flash_interval, eeg(flash_interval));
    %nonflash_area = area(nonflash_interval, eeg(nonflash_interval));
    %set(flash_area, 'FaceColor', [1 0 0]);
    %set(nonflash_area, 'FaceColor', [0 1 0]);
end
end