
function handshake(udp1,udp2)
try  
  
    success=0;
 
    while (success==0)

     temp=fscanf(udp2);
        if (strcmp(temp,'')==true)
            pause(0.3);
            fprintf('could not read, waiting\n');
           fprintf(temp);
        else

        if (strcmp(temp(1:2),'ok')==true)
        fprintf(udp1,'ok')

        
        
        success=1;
      fprintf('handshake\n');
        end
        end
    end



    
catch
    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
    
end
