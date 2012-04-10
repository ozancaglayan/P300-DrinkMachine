function p300_graph(data, drinks)
colors = {'b', 'g', 'r', 'm', 'k'};
plot(data(1,:), colors{1});
%grid on;
hold on;

for d = 2:length(drinks)
    plot(data(d, :), colors{d});
end

% Add P300 markers
%line([60, 60], [-1, 1]);
%line([100, 100], [-1, 1]);
%text(60, 1, strcat('\leftarrow ', '300ms'), 'rotation', 90, 'FontSize', 12);
%text(100, 1, strcat('\leftarrow ', '500ms'), 'rotation', 90, 'FontSize', 12);

legend(drinks, 'Location', 'Best');
end