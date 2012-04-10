% Entry point for the MMN experiment
                
function mmn_p300()

% Define some enumerations from mpdev.h for readability
MPTYPE      = struct('MP150', 101, 'MP35', 102, 'MP36', 103);
MPCOMTYPE   = struct('MPUSB', 10, 'MPUDP', 11);

% Call recorddatap()
recorddatap('C:\BHAPI\mpdev.dll', 'C:\BHAPI\', MPTYPE.MP35, MPCOMTYPE.MPUSB, 'auto');

end