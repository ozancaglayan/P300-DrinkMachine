function  noflicker(w, x, y, xm, ym,bcolor,sqcolor,tcolor,rx1,rx2,ry1,ry2,textsize)
%FLASHER Summary of this function goes here
%   Detailed explanation goes here

  
    Screen('TextFont',w, 'Courier New');
    Screen('TextSize',w, textsize);
    Screen('TextStyle', w, 1);
    Screen('FillRect',w, sqcolor ,[rx1 ry1 rx2 ry2]);

    
    Screen('FillRect',w, bcolor ,[rx1  y+ym-5 rx2 y+ym+5]);
    Screen('FillRect',w, bcolor ,[rx1  y+2*ym-5 rx2 y+2*ym+5]);
    Screen('FillRect',w, bcolor ,[rx1  y+3*ym-5 rx2 y+3*ym+5]);
    Screen('FillRect',w, bcolor ,[rx1  y+4*ym-5 rx2 y+4*ym+5]);
    Screen('FillRect',w, bcolor ,[rx1  y+5*ym-5 rx2 y+5*ym+5]);
    
    Screen('FillRect',w, bcolor ,[x+xm-15 ry1 x+xm-5 ry2]);
    Screen('FillRect',w, bcolor ,[x+2*xm-15 ry1 x+(2*xm)-5 ry2]);
    Screen('FillRect',w, bcolor ,[x+3*xm-15 ry1 x+(3*xm)-5 ry2]);
    Screen('FillRect',w, bcolor ,[x+4*xm-15 ry1 x+(4*xm)-5 ry2]);
    Screen('FillRect',w, bcolor ,[x+5*xm-15 ry1 x+(5*xm)-5 ry2]);
    
    Screen('DrawText', w, 'A', (0*xm)+x, (0*ym)+y, tcolor);
    Screen('DrawText', w, 'B', (1*xm)+x, (0*ym)+y, tcolor);
    Screen('DrawText', w, 'C', (2*xm)+x, (0*ym)+y, tcolor);  
    Screen('DrawText', w, 'D', (3*xm)+x, (0*ym)+y, tcolor); 
    Screen('DrawText', w, 'E', (4*xm)+x, (0*ym)+y, tcolor); 
    Screen('DrawText', w, 'F', (5*xm)+x, (0*ym)+y, tcolor); 
    
    Screen('DrawText', w, 'G', (0*xm)+x, (1*ym)+y, tcolor);
    Screen('DrawText', w, 'H', (1*xm)+x, (1*ym)+y, tcolor);
    Screen('DrawText', w, 'I', (2*xm)+x, (1*ym)+y, tcolor);  
    Screen('DrawText', w, 'J', (3*xm)+x, (1*ym)+y, tcolor); 
    Screen('DrawText', w, 'K', (4*xm)+x, (1*ym)+y, tcolor); 
    Screen('DrawText', w, 'L', (5*xm)+x, (1*ym)+y, tcolor); 
    
    Screen('DrawText', w, 'M', (0*xm)+x, (2*ym)+y, tcolor);
    Screen('DrawText', w, 'N', (1*xm)+x, (2*ym)+y, tcolor);
    Screen('DrawText', w, 'O', (2*xm)+x, (2*ym)+y, tcolor);  
    Screen('DrawText', w, 'P', (3*xm)+x, (2*ym)+y, tcolor); 
    Screen('DrawText', w, 'Q', (4*xm)+x, (2*ym)+y, tcolor); 
    Screen('DrawText', w, 'R', (5*xm)+x, (2*ym)+y, tcolor); 
 
    Screen('DrawText', w, 'S', (0*xm)+x, (3*ym)+y, tcolor);
    Screen('DrawText', w, 'T', (1*xm)+x, (3*ym)+y, tcolor);
    Screen('DrawText', w, 'U', (2*xm)+x, (3*ym)+y, tcolor);  
    Screen('DrawText', w, 'V', (3*xm)+x, (3*ym)+y, tcolor); 
    Screen('DrawText', w, 'W', (4*xm)+x, (3*ym)+y, tcolor); 
    Screen('DrawText', w, 'X', (5*xm)+x, (3*ym)+y, tcolor); 
 
    Screen('DrawText', w, 'Y', (0*xm)+x, (4*ym)+y, tcolor);
    Screen('DrawText', w, 'Z', (1*xm)+x, (4*ym)+y, tcolor);
    Screen('DrawText', w, '1', (2*xm)+x, (4*ym)+y, tcolor);  
    Screen('DrawText', w, '2', (3*xm)+x, (4*ym)+y, tcolor); 
    Screen('DrawText', w, '3', (4*xm)+x, (4*ym)+y, tcolor); 
    Screen('DrawText', w, '4', (5*xm)+x, (4*ym)+y, tcolor); 

    Screen('DrawText', w, '5', (0*xm)+x, (5*ym)+y, tcolor);
    Screen('DrawText', w, '6', (1*xm)+x, (5*ym)+y, tcolor);
    Screen('DrawText', w, '7', (2*xm)+x, (5*ym)+y, tcolor);  
    Screen('DrawText', w, '8', (3*xm)+x, (5*ym)+y, tcolor); 
    Screen('DrawText', w, '9', (4*xm)+x, (5*ym)+y, tcolor); 
    Screen('DrawText', w, '0', (5*xm)+x, (5*ym)+y, tcolor); 

    
end












