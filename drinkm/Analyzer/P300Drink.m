% Entry point for the P300 Drink Experiment
                
function P300Drink()

% Define some enumerations from mpdev.h for readability
MPTYPE      = struct('MP150', 101, 'MP35', 102, 'MP36', 103);
MPCOMTYPE   = struct('MPUSB', 10, 'MPUDP', 11);

% Call recorddatap()
recorddatap('C:\BHAPI\mpdev.dll', 'C:\BHAPI\', MPTYPE.MP35, MPCOMTYPE.MPUSB, 'auto');

end