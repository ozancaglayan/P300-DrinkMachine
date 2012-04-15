function p300_graph(data)
colors = {'b', 'c', 'r', 'm', 'k'};
drinks = {'Su', 'Kahve', 'Çay', 'Soda', 'Bira'};
plot(data(1,:), colors{1});
grid on;
hold on;

xlabel('800 ms''lik pencere');
ylabel('Genlik');

for d = 2:length(drinks)
    plot(data(d, :), colors{d});
end

legend(drinks, 'Location', 'Best');
end