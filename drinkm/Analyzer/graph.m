function graph(eeg, cues, stims, drinks)
plot(eeg, 'g-');
grid on;
hold on;
%plot(cues, 0, 'ks');
for i = 1:length(cues)
    text(cues(i), 0, drinks{stims(i)}, 'rotation', 45);
end
end