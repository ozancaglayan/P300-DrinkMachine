

function retval = recorddata(dll, dothdir, mptype, mpmethod, sn)
% MPDEVDEMO BIOPAC Hardware API Demonstration for MATLAB
% This function will illustrate how to use the BIOPAC Hardware API in
% MATLAB
% Usage:
%   retval      return value for diagnostic purposes
%   dll         fullpath to mpdev.dll (ie C:\mpdev.dll)
%   dothdir     directory where mdpev.h 
%   mptype      enumerated value for MP device, refer to the documentation
%   mpmethod    enumerated value for MP communication method, refer to the
%   documentation
%   sn          Serial Number of the mp150 if necessary  

libname = 'mpdev';
doth = 'mpdev.h';

%parameter error checking
if nargin < 5
    error('Not enough arguements. MPDEVDEMO requires 5 arguemnets');
end

if isnumeric(dll) || isnumeric(dothdir)
    error('DLL and Header Directory has to be string')
end

if exist(dll) ~= 3 && exist(dll) ~= 2
    error('DLL file does not exist');
end

if exist(strcat(dothdir,doth)) ~= 2
    error('Header file does not exist');
end
%end parameter check

%check if the library is already loaded
if libisloaded(libname)
    calllib(libname, 'disconnectMPDev');
    unloadlibrary(libname);
end

%turn off annoying enum warnings
warning off MATLAB:loadlibrary:enumexists;

%load the library
loadlibrary(dll,strcat(dothdir,doth));
fprintf(1,'\nMPDEV.DLL LOADED!!!\n');
libfunctions(libname, '-full');

%begin demonstration
try
   % fprintf(1,'Hit any key to continue...\n');
   % pause;
    
   
    
    
     %Connect
    fprintf(1,'Connecting...\n');

    [retval, sn] = calllib(libname,'connectMPDev',mptype,mpmethod,sn);

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Connect.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end

    fprintf(1,'Connected\n');












%%
ipA = '10.1.1.235'; portA = 9090;portA2 = 9092;
ipB = '10.1.3.236'; portB = 9091;portB2 = 9093;

udpB = udp(ipB,portA,'LocalPort',portB);
udpB2 = udp(ipB,portB2,'LocalPort',portA2);

fopen(udpB)
fopen(udpB2)
fprintf('1\n');


handshake(udpB,udpB2);

 times=str2double(fscanf(udpB))
runs=str2double(fscanf(udpB))
xftime=str2double(fscanf(udpB))
yftime=str2double(fscanf(udpB))
noftime=str2double(fscanf(udpB))
samplerate=str2double(fscanf(udpB))

recordtime=(6*(xftime+yftime+noftime+noftime))*times+4 %1 saniye baþta 3 sn sonda ekle (grafik gecýkmeleri)
samplestorecord=recordtime*samplerate



%%
    %Configure
    fprintf(1,'Setting Sample Rate\n');

    retval = calllib(libname, 'setSampleRate', (1000/samplerate));

    if ~strcmp(retval,'MPSUCCESS')
       fprintf(1,'Failed to Set Sample Rate.\n');
       calllib(libname, 'disconnectMPDev');
       return
    end

    fprintf(1,'Sample Rate Set\n');
    
    fprintf(1,'Setting to Acquire on Channel 1\n');

    aCH = [int32(1),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0),int32(0)];
    
    %if mptype is not MP150
    if mptype ~= 101
        %then it must be the mp35 (102) or mp36 (103)
        aCH = [int32(1),int32(0),int32(0),int32(0)];
    end
    
    [retval, aCH] = calllib(libname, 'setAcqChannels',aCH);

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Set Acq Channels.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
    
    fprintf(1,'Channels Set\n');

%%


    [retval, presets] = calllib(libname, 'loadXMLPresetFile','C:\Program Files\BIOPAC Systems, Inc\BIOPAC Hardware API 2.0\PresetFiles\channelpresets2.xml'); 
      if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Load Presets.\n');
        calllib(libname, 'disconnectMPDev');
        return
      end
   retval
presets

 [retval, preset] = calllib(libname, 'configChannelByPresetID',0,'a22'); 
      if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Load Presets.\n');
        calllib(libname, 'disconnectMPDev');
        return
      end
    retval
preset
 %set trigger

      [retval] = calllib(libname, 'setMPTrigger', 'MPTRIGEXT',false,1,1);

    if ~strcmp(retval,'MPSUCCESS')
       fprintf(1,'Failed to Set Trigger.\n');
       calllib(libname, 'disconnectMPDev');
       return
    end
%retval





%%

for i = 1:runs
 
    
 % fprintf(1,'Hit any key to start data acq...\n');
 %  pause;   
    %Acquire
    fprintf(1,'Start Acquisition Daemon\n');
    
    retval = calllib(libname, 'startMPAcqDaemon');
  
    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Start Acquisition Daemon.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
    
 

      retval = calllib(libname, 'startAcquisition');

    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Failed to Start Acquisition.\n');
        calllib(libname, 'disconnectMPDev');
        return
    end
 
      fprintf(1,'Start Acquisition\n');
   
    %Download and Plot 1000 samples in realtime
  %  fprintf(1,'Download and Plot 1000 samples in Real-Time\n');
    numRead = 0;
    numValuesToRead = 50; %collect 1 second worth of data points per iteration
    remaining = samplestorecord; %collect 1000 samples per channel
    tbuff(1:numValuesToRead) = double(0); %initialize the correct amount of data
    bval = 0;
    offset = 1;
   
  %    figure;
     
    %loop until there still some data to acquire

 
    while(remaining > 0)
      
       if numValuesToRead > remaining
               numValuesToRead = remaining;
       end
       
       [retval, tbuff, numRead]  = calllib(libname, 'receiveMPData',tbuff, numValuesToRead, numRead);
    
       if ~strcmp(retval,'MPSUCCESS')
           fprintf(1,'Failed to receive MP data.\n');
           calllib(libname, 'disconnectMPDev');
           return
       else
            buff(offset:offset+double(numRead(1))-1) = tbuff(1:double(numRead(1))); 
            
            %Process
            len = length(buff);

%             X(1:len) = (1:len);
%             %plot graph
%             pause(1/100);
%            
%             
%             plot((1:50),buff(len-49:len),'g-'),axis([1 50 -100 100]);
%             title('Data Plot of for Channel 1');
%     
%             xlabel('Nth Sample');
       end
       offset = offset + double(numValuesToRead);
       remaining = remaining-double(numValuesToRead);
    end
    eeg(i,:)=buff;

   
   %stop acquisition
   fprintf(1,'Stop Acquisition\n');

   retval = calllib(libname, 'stopAcquisition');
   if ~strcmp(retval,'MPSUCCESS')
       fprintf(1,'Failed to Stop\n');
       calllib(libname, 'disconnectMPDev');
       return
   end
end







%%








   %disconnect
   fprintf(1,'Disconnecting...\n')
   retval = calllib(libname, 'disconnectMPDev');
    
    
   
    
   
    if ~strcmp(retval,'MPSUCCESS')
        fprintf(1,'Acquisition Daemon Demo Failed.\n');
        calllib(libname, 'disconnectMPDev')
    end
    
% %%


 assignin('base','eeg',eeg);
%
assignin('base','eeg',eeg);
assignin('base','times',times);
assignin('base','runs',runs);
assignin('base','xftime',xftime);
assignin('base','yftime',yftime);
assignin('base','noftime',noftime);
assignin('base','samplerate',samplerate);




handshake(udpB,udpB2);

data=[];
cuedata=[];

for i = 1:runs
for j = 1:times

pause(0.1)
data2=fscanf(udpB);
size(data2);
while(size(data2,2)<55)
data2=[' ',data2];
end
datanum=str2num(data2);
data=[data;datanum];
end
end

 pause(0.1)
 for i = 1:runs
 for j = 1:times
 
 pause(0.1)
 cuedata2=fscanf(udpB);
 size(cuedata2);
 while(size(cuedata2,2)<55);
 cuedata2=[' ',cuedata2];
 end
cuedatanum=str2num(cuedata2);
 cuedata=[cuedata;cuedatanum];
 end
 end



data
cuedata
fclose(udpB2)
fclose(udpB)
delete(udpB2)
delete(udpB)
clear udpB udpB2 






assignin('base','stims',data);
assignin('base','cues',cuedata);




catch
    %disonnect cleanly in case of system error
    calllib(libname, 'disconnectMPDev');
    unloadlibrary(libname);
    %return 'ERROR' and rethrow actual systerm error
    retval = 'ERROR';
    rethrow(lasterror);
fclose(udpB2)
fclose(udpB)
delete(udpB2)
delete(udpB)
clear udpB udpB2 


end

unloadlibrary(libname);


%fprintf(udpB2,'ok')
%% Clean Up Machine B




%clear 


