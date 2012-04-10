wfilter='db4';

n_window = 10;
window_size = stim_count/n_window;
average_signal = zeros(2, 180, n_window);

results = zeros(2, 180, n_window);

figure;
figure;

% 1 to 10
for i = 1:n_window
    cnt = zeros(2, 1);
    for j = ((i-1)*window_size + 1):(i * window_size)
        average_signal(stimulus(j) + 1, :, i) = average_signal(stimulus(j) + 1, :, i) + ceeg(1, cues(j):cues(j)+180-1);
        cnt(stimulus(j) + 1) = cnt(stimulus(j) + 1) + 1;
    end
    
    average_signal(1, :, i) = average_signal(1, :, i) ./ cnt(1);
    average_signal(2, :, i) = average_signal(2, :, i) ./ cnt(2);
    
    [C,L] = wavedec(average_signal(1, :, i), 8, wfilter);
    D6    = wrcoef('d', C, L, wfilter, 6);
    D7    = wrcoef('d', C, L, wfilter, 7);
    D8    = wrcoef('d', C, L, wfilter, 8);
    eegw1  = D8 + D6 + D7;
    eegwzm1 = eegw1 - mean(eegw1);
    
    results(1, :, i) = eegwzm1;
    
    [C,L] = wavedec(average_signal(2, :, i), 8, wfilter);
    D6    = wrcoef('d', C, L, wfilter, 6);
    D7    = wrcoef('d', C, L, wfilter, 7);
    D8    = wrcoef('d', C, L, wfilter, 8);
    eegw2  = D8 + D6 + D7;
    eegwzm2 = eegw2 - mean(eegw2);
    
    results(2, :, i) = eegwzm2;
    
    figure(1);
    subplot(5,2,i);
    plot(results(1, :, i));hold on;plot(results(2, :, i), 'r');
    title(sprintf('Plot for (%d:%d)', (i-1)*window_size + 1, (i * window_size)));
    axis([0 180 -.1 .1]);
    
    figure(2);
    subplot(5,2,i);
    plot(ceeg(1, (i-1)*window_size*180+1:i*window_size*180));
    axis([0 7200 -5 5]);
end
