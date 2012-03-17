function[result]= processdata(eeg,stims,cues,times)


tic

%eeg wavelet
[C,L] = wavedec(eeg,8,'db4');
D6 = wrcoef('d',C,L,'db4',6);
D7 = wrcoef('d',C,L,'db4',7);
D8 = wrcoef('d',C,L,'db4',8);
eegw=D8+D6+D7;

%eeg zero mean
eegwzm = eegw-mean(eegw);


%stim ve cue ayar
% stims=[];
% cues=[];
% data
% cuedata
% 
% for i = 1:times
% stims=[stims,data(i,3:14)]
% cues=[cues,int32(cuedata(i,3:14)*200)]
% end
%eeg 1 - 12 ayýrma

eegdata = zeros(12,160);


for j = 1:times*12
cues(j)
eegdata(stims(j),:)=eegdata(stims(j),:)+eegwzm(cues(j):cues(j)+159);

end
eegdata=eegdata/times;


tops=zeros(1,12);
for i = 1:12
   tops(1,i)=(norm(eegdata(i,60:10:100))/sqrt(times))*sign(sum(eegdata(i,60:10:100)));
end

[C,I]=max(tops(1:6));
[C,I2]=max(tops(7:12));

matrix = ['A','B','C','D','E','F';'G','H','I','J','K','L';'M','N','O','P','Q','R';'S','T','U','V','W','X';'Y','Z','1','2','3','4';'5','6','7','8','9','_'];

I
I2
matrix(I,I2)

result=matrix(I,I2);  
toc
assignin('base','eegdata', eegdata);
toc 
end




