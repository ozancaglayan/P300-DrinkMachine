wfilter='db4';
average_signal = zeros(2, 180);
cnt=zeros(2,1);
for i = 20:stim_count
    clf;average_signal(stimulus(i) + 1, :) = average_signal(stimulus(i) + 1, :) + ceeg(1, cues(i):cues(i)+180-1);
    cnt(stimulus(i)+1) = cnt(stimulus(i)+1) + 1;
    % plot(average_signal(1,:)/cnt(1));hold on;
    % plot(average_signal(2,:)/cnt(2),'r');
    % %plot(aa);
    % axis([0 180 -.6 .4]);hold off
    % %waitforbuttonpress;
    % end
    a1 = average_signal(1,:) ./ cnt(1);
    a2 = average_signal(2,:) ./ cnt(2);
    if cnt(1) > 0
        [C,L] = wavedec(a1, 8, wfilter);
        D6    = wrcoef('d', C, L, wfilter, 6);
        D7    = wrcoef('d', C, L, wfilter, 7);
        D8    = wrcoef('d', C, L, wfilter, 8);
        eegw  = D8 + D6 + D7;
        eegwzm = eegw - mean(eegw);
        plot(eegwzm);
        axis([0 180 -.02 .02])
    end
    if cnt(2) > 0
        [C,L] = wavedec(a2, 8, wfilter);
        D6    = wrcoef('d', C, L, wfilter, 6);
        D7    = wrcoef('d', C, L, wfilter, 7);
        D8    = wrcoef('d', C, L, wfilter, 8);
        eegw  = D8 + D6 + D7;
        eegwzm = eegw - mean(eegw);
        hold;
        plot(eegwzm, 'r');
    end
    text(80, 0.01 ,sprintf('Stim count=%d cnt1=%d cnt2=%d', i, cnt(1), cnt(2)));
    waitforbuttonpress;
end
