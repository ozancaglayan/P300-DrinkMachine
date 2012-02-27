function deneme001(bcolor,sqcolor,fcolor,tcolor,tfcolor,x,y,xm,ym,textsize,times,runs,rand,xftime,yftime,noftime,samplerate)
try  
    Screen('Preference', 'SkipSyncTests', 1);
    % Choosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);
         
 %   tcolor  = [0, 0, 255];
 %   bcolor  = [0 0 0];
 %   fcolor  = [200 200 0];
 %   tfcolor = [255,255,255];
 %   sqcolor = [30,30,30];
    
    w=Screen('OpenWindow', screenNumber);
      Screen('FillRect', w, bcolor);
      
 %   x=400;
 %   y=200;
 %   xm=60;
 %   ym=60;

  
    Screen('DrawText', w, 'connecting to other computer', 100, 100, tcolor);
    Screen('Flip',w);
    
    ipA = '10.1.8.138'; portA = 9090;portA2=9092; 
    ipA = '10.1.1.93'; portB = 9091;portB2=9093; 
    udpA = udp(ipA,portB,'LocalPort',portA);
    udpA2 = udp(ipA,portA2,'LocalPort',portB2);
    fopen(udpA)
    fopen(udpA2)
     fprintf('ports opened\n');
    
    Screen('DrawText', w, 'ports opened', 100, 100, tcolor);
    Screen('Flip',w);

     handshake(udpA,udpA2);


   fprintf('sending data');
        Screen('DrawText', w, 'sending initial values', 100, 100, tcolor);
        Screen('Flip',w);
            
                
            fprintf(udpA,num2str(times))
            fprintf(udpA,num2str(runs))
            fprintf(udpA,num2str(xftime))
            fprintf(udpA,num2str(yftime))
            fprintf(udpA,num2str(noftime))
            fprintf(udpA,num2str(samplerate))

            
        fprintf('data sent');
        Screen('DrawText', w, 'initial values sent', 100, 100, tcolor);
        Screen('Flip',w);


        
     
 
        
        
        %%
        
        
        
        

    Screen('DrawText', w, 'loading [__________________]', 100, 100, tcolor);
    Screen('Flip',w);
    rx1=x-5; rx2=x+(6*xm)-15;
    ry1=y+5; ry2=y+(6*ym)-5;
    
 nof1 = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof1,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
 Screen('DrawText', nof1, 'Starting in secs: 1', 100, 100, tcolor); 
  Screen('DrawText', w, 'loading [-_________________]', 100, 100, tcolor);Screen('Flip',w);
  
  nof2 = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof2,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
 Screen('DrawText', nof2, 'Starting in secs: 2', 100, 100, tcolor); 
  Screen('DrawText', w, 'loading [--________________]', 100, 100, tcolor);Screen('Flip',w);
  
   nof3 = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof3,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
 Screen('DrawText', nof3, 'Starting in secs: 3', 100, 100, tcolor); 
  Screen('DrawText', w, 'loading [---_______________]', 100, 100, tcolor);Screen('Flip',w);
  
   nof4 = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof4,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
 Screen('DrawText', nof4, 'Starting in secs: 4', 100, 100, tcolor); 
  Screen('DrawText', w, 'loading [----______________]', 100, 100, tcolor);Screen('Flip',w);
  
   nof5 = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof5,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
 Screen('DrawText', nof5, 'Starting in secs: 5', 100, 100, tcolor); 
  Screen('DrawText', w, 'loading [-----_____________]', 100, 100, tcolor);Screen('Flip',w);
  
 nof = Screen('OpenOffscreenWindow', w,bcolor);
 noflicker(nof,x,y,xm,ym,bcolor,sqcolor,tcolor, rx1,rx2,ry1,ry2,textsize);
  Screen('DrawText', w, 'loading [------____________]', 100, 100, tcolor);Screen('Flip',w);
 xf0 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf0, x, y, xm, ym, 0,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [-------___________]', 100, 100, tcolor);Screen('Flip',w);
 
 xf1 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf1, x, y, xm, ym, 1,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [--------__________]', 100, 100, tcolor);Screen('Flip',w);
 
 xf2 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf2, x, y, xm, ym, 2,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [---------_________]', 100, 100, tcolor);Screen('Flip',w);
 
 xf3 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf3, x, y, xm, ym, 3,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [----------________]', 100, 100, tcolor);Screen('Flip',w);
  
 xf4 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf4, x, y, xm, ym, 4,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [-----------_______]', 100, 100, tcolor);Screen('Flip',w);
  
 xf5 = Screen('OpenOffscreenWindow', w,bcolor);
 xflicker(xf5, x, y, xm, ym, 5,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [------------______]', 100, 100, tcolor);Screen('Flip',w);
 
 yf0 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf0, x, y, xm, ym, 0,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [-------------_____]', 100, 100, tcolor);Screen('Flip',w);
  
 yf1 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf1, x, y, xm, ym, 1,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [--------------____]', 100, 100, tcolor);Screen('Flip',w);
  
 yf2 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf2, x, y, xm, ym, 2,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [---------------___]', 100, 100, tcolor);Screen('Flip',w);
  
 yf3 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf3, x, y, xm, ym, 3,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [----------------__]', 100, 100, tcolor);Screen('Flip',w);
 
 yf4 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf4, x, y, xm, ym, 4,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [-----------------_]', 100, 100, tcolor);Screen('Flip',w);
  
 yf5 = Screen('OpenOffscreenWindow', w,bcolor);
 yflicker(yf5, x, y, xm, ym, 5,bcolor,sqcolor,tcolor,tfcolor,fcolor,rx1,rx2,ry1,ry2,textsize)
  Screen('DrawText', w, 'loading [------------------]', 100, 100, tcolor);
    Screen('Flip',w);
 
  
mynoise(1,:) = MakeBeep(1000, 0.1, 8192);


 
 
   A=[xf0,xf1,xf2,xf3,xf4,xf5];  
   B=[yf0,yf1,yf2,yf3,yf4,yf5];   
  %  rect=Screen(w,'Rect');
  
  Stimulus = zeros(runs,times*12);
  count=0;
  
    % gecikmeler için cue noktalarý
    cues=zeros(runs,times*12);   
   
        

 for k = 1:runs
    cuenum=0;
    Screen('DrawTexture', w,nof5);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('DrawTexture', w,nof4);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('DrawTexture', w,nof3);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('DrawTexture', w,nof2);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('DrawTexture', w,nof1);
    Screen('Flip',w);
 Snd('Play',mynoise,8192,16);

    tic
    WaitSecs(1);


       if rand == 0 
           for j = 1:times    
            for i = 1:12  

            if (i<7)
             Screen('DrawTexture', w,A(i));

             Screen('Flip',w); 

            WaitSecs(xftime);

             Screen('DrawTexture', w,nof); 
             Screen('Flip',w); 
             WaitSecs(noftime);

            else

            Screen('DrawTexture', w,B(i-6));

             Screen('Flip',w);
              WaitSecs(yftime);
             Screen('DrawTexture', w,nof);

             Screen('Flip',w);
             WaitSecs(noftime);

           end
            end
           end
       end


               if rand == 1
               count=count+1;

               for j = 1:times 

               count2=(j*12)-11;
               R1=randperm(12);
               Stimulus(count,count2:count2+11)=R1;  
                for i = 1:12  
                  if (R1(i)<7)
   
                 Screen('DrawTexture', w,A(R1(i)));
 cuenum=cuenum+1; 
 cues(k,cuenum)=toc;
                 Screen('Flip',w); 

                  WaitSecs(xftime);


                 Screen('DrawTexture', w,nof);

                 Screen('Flip',w);  
                      WaitSecs(noftime);

                  else     

                   Screen('DrawTexture', w,B(R1(i)-6));
 cuenum=cuenum+1; 
 cues(k,cuenum)=toc;
                 Screen('Flip',w); 
                      WaitSecs(yftime);
                 Screen('DrawTexture', w,nof);

                 Screen('Flip',w); 
                    WaitSecs(noftime);    

                  end     
                end

               end  

             end

 Snd('Quiet'); 

%%
%waiting for process
Screen('DrawText', w, 'waiting for results', 100, 100, tcolor);
Screen('Flip',w);
handshake(udpA,udpA2);

        fprintf('sending data\n');
               

for j = 1:times
pause(0.1);
            data=[k,j,Stimulus(k,(12*(j-1))+1:(12*(j-1))+12)]
              fprintf(udpA,num2str(data))
end
  
 pause(0.1);      

 for j = 1:times
 pause(0.1);
             cuedata=[k,j,cues(k,(12*(j-1))+1:(12*(j-1))+12)]
               fprintf(udpA,num2str(cuedata))
 end
   
            
        fprintf('data sent\n');





result=fscanf(udpA2)
Screen('DrawText', w, 'your choice is:', 100, 100, tcolor);
Screen('DrawText', w, result, 100, 140, tfcolor);
Screen('Flip',w);
WaitSecs(1);  




 end



 Stimulus
assignin('base','Stims',Stimulus);
assignin('base','Cues',cues); 

%%

    
handshake(udpA,udpA2);
for i = 1:runs
 results(i)=fscanf(udpA2);   
pause(0.1);           
end
       
char(results)  
Screen('DrawText', w, 'results:', 100, 100, tcolor);
Screen('DrawText', w, char(results), 100, 140, tfcolor);
Screen('Flip',w);
kbwait

%%

fclose(udpA)
delete(udpA)
fclose(udpA2)
delete(udpA2)
clear udpA udpA2



%%

 
  %  KbWait;
    Screen('CloseAll');
catch
    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end


 