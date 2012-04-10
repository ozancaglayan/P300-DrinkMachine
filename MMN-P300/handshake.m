% Helper function for UDP handshake between the 2 computers
function handshake(udp1, udp2)

success = 0;

try    
    while (success == 0)
        fprintf(udp2, 'ok')
        pause(0.3);
        temp = fscanf(udp1);
        if (strcmp(temp, '') == true)
            fprintf('handshake(): Couldn''t read the answer, waiting.\n');
            fprintf(temp);
        else
            if (strcmp(temp(1:2), 'ok') == true)
                success = 1;
                fprintf('handshake(): Success.\n');
            end
        end
    end
catch err
    % Error caught, print the message.
    fprintf('handshake(): %s', err.message);
end