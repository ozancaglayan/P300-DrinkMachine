function graph(eeg, cues, stims)
drinks = {'Su', 'Kahve', 'Çay', 'Soda', 'Bira'};

plot(eeg, 'b-');
axis([0 length(eeg) -20 20]);
xlabel('Örnekler');
ylabel('Genlik');
hold on;

for i = 1:length(cues)
    text(cues(i), 0.4, strcat('\leftarrow ', drinks{stims(i)}), 'rotation', 90, 'FontSize', 12);
    cue_indicator = line([cues(i), cues(i)], [-0.80, 0.4]);
    set(cue_indicator, 'Color', [0.5 0.5 0.5]);
end
end