function p300_graph(data, drinks)
colors = {'b', 'g', 'r', 'm', 'k'};
plot(data(1,:), colors{1});
grid on;
hold on;

for d = 2:length(drinks)
    plot(data(d, :), colors{d});
end

legend(drinks, 'Location', 'Best');
end