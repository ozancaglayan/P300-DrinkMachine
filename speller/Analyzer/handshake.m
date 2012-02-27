

function handshake(udp1,udp2)

try
 %%
success=0;

while (success==0)
fprintf(udp2,'ok')
pause(0.3);
temp=fscanf(udp1);
fprintf(1, temp);
if (strcmp(temp,'')==true)
fprintf('couldnt read waiting \n');
fprintf(temp);
else
if (strcmp(temp(1:2),'ok')==true)
success=1;
fprintf('handshake\n');
end
end
end

 


catch
   
end




