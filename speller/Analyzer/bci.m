
function bci()
% Usage:
%   dll         fullpath to mpdev.dll (ie C:\mpdev.dll)
%   dothdir     directory where mdpev.h
%   mptype      enumerated value for MP device, refer to the documentation
%   mpmethod    enumerated value for MP communication method, refer to the
%   documentation
%   sn          Serial Number of the mp150 if necessary
    recorddatap('C:\WINDOWS\SYSTEM32\mpdev.dll', 'C:\Program Files\BIOPAC Systems, Inc\BIOPAC Hardware API 2.0\', 102, 10,'auto')
end



