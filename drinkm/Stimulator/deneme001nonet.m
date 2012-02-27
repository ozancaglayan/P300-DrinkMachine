function deneme001nonet(times,runs,ftime,noftime,samplerate)
 
    Screen('Preference', 'SkipSyncTests', 1);
    % Choosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);
         
 bcolor  = [0 0 0];
    tcolor  = [0, 0, 255];
    w=Screen('OpenWindow', screenNumber);
      Screen('FillRect', w, bcolor);
    load('soundz.mat', 'soundz')
    
  
      

  
%     Screen('DrawText', w, 'connecting to other computer', 100, 100, tcolor);
%     Screen('Flip',w);
%     
%     ipA = '10.1.3.235'; portA = 9090;portA2=9092; 
%     ipB = '10.1.3.236'; portB = 9091;portB2=9093; 
%     udpA = udp(ipA,portB,'LocalPort',portA);
%     udpA2 = udp(ipA,portA2,'LocalPort',portB2);
%     fopen(udpA)
%     fopen(udpA2)
%      fprintf('ports opened\n');
%     
%     Screen('DrawText', w, 'ports opened', 100, 100, tcolor);
%     Screen('Flip',w);
% 
%      handshake(udpA,udpA2);
% 
% 
%    fprintf('sending data');
%         Screen('DrawText', w, 'sending initial values', 100, 100, tcolor);
%         Screen('Flip',w);
%             
%                 
%             fprintf(udpA,num2str(times))
%             fprintf(udpA,num2str(runs))
%             fprintf(udpA,num2str(ftime))
%             fprintf(udpA,num2str(noftime))
%             fprintf(udpA,num2str(samplerate))
% 
%             
%         fprintf('data sent');
%         Screen('DrawText', w, 'initial values sent', 100, 100, tcolor);
%         Screen('Flip',w);
% 
% 
%         
     
 
        
        
        %%
        
        
        
        

      Screen('DrawText', w, 'loading [_____]', 100, 100, tcolor);
   Screen('Flip',w);
   imgback = imread ('drinksback', 'JPG');
   texback=Screen('MakeTexture', w, double(imgback));
    
   Screen('DrawText', w, 'loading [-____]', 100, 100, tcolor);
   Screen('Flip',w);
   img1 = imread ('drinks1', 'JPG');
   tex1=Screen('MakeTexture', w, double(img1));
   
   Screen('DrawText', w, 'loading [--___]', 100, 100, tcolor);
   Screen('Flip',w);
   img2 = imread ('drinks2', 'JPG');
   tex2=Screen('MakeTexture', w, double(img2));
   
   Screen('DrawText', w, 'loading [---__]', 100, 100, tcolor);
   Screen('Flip',w);
   img3 = imread ('drinks3', 'JPG');
   tex3=Screen('MakeTexture', w, double(img3));
   
   Screen('DrawText', w, 'loading [----_]', 100, 100, tcolor);
   Screen('Flip',w);
   img4 = imread ('drinks4', 'JPG');
   tex4=Screen('MakeTexture', w, double(img4));
   
   Screen('DrawText', w, 'loading [-----]', 100, 100, tcolor);
   Screen('Flip',w);
   img5 = imread ('drinks5', 'JPG');
   tex5=Screen('MakeTexture', w, double(img5));
    
    
    A=[tex1,tex2,tex3,tex4,tex5]; 
 
  
mynoise(1,:) = MakeBeep(1000, 0.1, 8192);



  
    Stimulus = zeros(runs,times*5);
    
    % gecikmeler için cue noktalarý
    cues=zeros(runs,times*5);   
     
        

for k = 1:runs
    count=0;
%     Screen('DrawText', w, '5', 100, 100, tcolor);
%     Screen('Flip',w);
%     WaitSecs(1);
%     Screen('DrawText', w, '4', 100, 100, tcolor);
%     Screen('Flip',w);
%     WaitSecs(1);
%     Screen('DrawText', w, '3', 100, 100, tcolor);
%     Screen('Flip',w);
%     WaitSecs(1);
%     Screen('DrawText', w, '2', 100, 100, tcolor);
%     Screen('Flip',w);
%     WaitSecs(1);
    Screen('DrawText', w, '1', 100, 100, tcolor);
    Screen('Flip',w);
    Snd('Play',mynoise,8192,16);

    tic
    WaitSecs(1);

               

     for j = 1:times 
     
          R1=randperm(5); 
          
          for i = 1:5
                 


    randnum=R1(i);
    Screen('DrawTexture', w,A(randnum));
    count=count+1; 
    cues(k,count)=toc;
    Stimulus(k,count)=randnum;
    Screen('Flip',w); 
    sound(soundz(randnum,:)*0.3,16000); 
    WaitSecs(ftime);
    Screen('DrawTexture', w,texback);
    Screen('Flip',w);      
    WaitSecs(noftime);

  

          end     
     end

 
WaitSecs(3);


Snd('Quiet'); 

%%
%waiting for process
% Screen('DrawText', w, 'waiting for results', 100, 100, tcolor);
% Screen('Flip',w);
% handshake(udpA,udpA2);
% 
%         fprintf('sending data\n');
%                
% 
% for j = 1:times
% pause(0.1);
%             data=[k,j,Stimulus(k,(5*(j-1))+1:(5*(j-1))+5)]
%               fprintf(udpA,num2str(data))
% end
%   
%  pause(0.1);      
% 
%  for j = 1:times
%  pause(0.1);
%              cuedata=[k,j,cues(k,(5*(j-1))+1:(5*(j-1))+5)]
%                fprintf(udpA,num2str(cuedata))
%  end
%    
%             
%         fprintf('data sent\n');
% 
% 
% 
% result=fscanf(udpA2)
% Screen('DrawText', w, 'your choice is:', 100, 100, tcolor);
% Screen('DrawText', w, result, 100, 140, tfcolor);
% Screen('Flip',w);
% WaitSecs(1);  




end



Stimulus
cues
assignin('base','Stims',Stimulus);
assignin('base','Cues',cues); 

%%

    
% handshake(udpA,udpA2);
% for i = 1:runs
%  results(i)=fscanf(udpA2);   
% pause(0.1);           
% end
%        
% char(results)  
% Screen('DrawText', w, 'results:', 100, 100, tcolor);
% Screen('DrawText', w, char(results), 100, 140, tfcolor);
% Screen('Flip',w);
% kbwait

%%

% fclose(udpA)
% delete(udpA)
% fclose(udpA2)
% delete(udpA2)
% clear udpA udpA2



%%

 
  %  KbWait;
   

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end


 