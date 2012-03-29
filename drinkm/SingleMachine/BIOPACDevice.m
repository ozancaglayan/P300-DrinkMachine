classdef BIOPACDevice < handle
    properties(GetAccess = 'public', SetAccess = 'private')
        % Folder where the library and the header resides
        lib_path = 'C:\BHAPI\';
        lib_handle = 'mpdev';
        
        % Channel mask for setAcqChannels()
        channel_mask;

        % Some enumerations from mpdev.h
        enum_info;
        
        % Reading related stuff
        buffer;
        buffer_size;
        samples_read = 0;
        
        % Default sample rate is 200Hz
        sample_rate = 1000/200;

        % Default preset is EEG, single channel
        % Length of this cell array also defines the channel number
        ch_presets = {'a22'};
        
        % XML preset file is by default in the same directory
        xml_presets = 'PresetFiles\channelpresets.xml';
        
        % Device type and connection method
        mp_type;
        mp_method;
    end
    
    methods
        function obj = BIOPACDevice(lib_path, mp_type, mp_method, ...
                                    sample_rate, ch_presets)
                                
            % Call prototype functions to get the enumerations
            [~, ~, obj.enum_info, ~] = mpdevproto();

            % Constructor
            if nargin > 0
                obj.lib_path = lib_path;
                obj.sample_rate = double(1000/sample_rate);
                obj.buffer_size = sample_rate * length(ch_presets);
                obj.buffer(1:obj.buffer_size) = double(0);
                obj.ch_presets = ch_presets;
                
                switch lower(mp_type)
                    case 'mp150'
                        obj.mp_type = obj.enum_info.MP_TYPE.MP150;
                        obj.channel_mask = zeros(1, 16);
                    case 'mp35'
                        obj.mp_type = obj.enum_info.MP_TYPE.MP35;
                        obj.channel_mask = zeros(1, 4);
                    case 'mp36'
                        obj.mp_type = obj.enum_info.MP_TYPE.MP36;
                        obj.channel_mask = zeros(1, 4);
                end
                
                switch lower(mp_method)
                    case 'usb'
                        obj.mp_method = obj.enum_info.MP_COM_TYPE.MPUSB;
                    case 'udp'
                        obj.mp_method = obj.enum_info.MP_COM_TYPE.MPUDP;
                end
                
                % Init channel mask for setAcqChannels()
                for i = 1:length(ch_presets)
                    obj.channel_mask(i) = 1;
                end
            end
            
            % Load the library using prototype file
            loadlibrary(strcat(obj.lib_path, 'mpdev.dll'), @mpdevproto);
            
            % Init the device
            obj.connect();
            obj.loadXMLPresetFile();
            obj.configureChannelsByPresetID();
            obj.setSampleRate();
            obj.setAcquisitionChannels();
            obj.startMpAcqDaemon();
        end
        
        function delete(obj)
            % This is called when you issue a 'clear' command in MATLAB
            obj.disconnect();
            obj.unload();
        end
        
        function retval = wrap_calllib(obj, varargin)
            [call_stack, ~] = dbstack(1);
            retval = calllib(obj.lib_handle, varargin{:});
            if ~strcmp(retval, {'MPSUCCESS', 'MPREADY', 'MPBUSY'})
                fprintf(1, 'ERROR: %s() returned ''%s''.\n', call_stack.name, retval);
            end
        end
        
        function unload(obj)
            if libisloaded(obj.lib_handle)
                unloadlibrary(obj.lib_handle)
            end
        end
        
        function retval = connect(obj)
            retval = obj.wrap_calllib('connectMPDev', obj.mp_type, obj.mp_method, 'auto');
        end

        function retval = disconnect(obj)
            retval = obj.wrap_calllib('disconnectMPDev');
        end
        
        function retval = configureChannelsByPresetID(obj)
            for i = 1:length(obj.ch_presets)
                retval = obj.wrap_calllib('configChannelByPresetID', i-1, obj.ch_presets{i});
            end
        end
        
        function retval = loadXMLPresetFile(obj)
            retval = obj.wrap_calllib('loadXMLPresetFile', obj.xml_presets);
        end
        
        function retval = status(obj)
            retval = obj.wrap_calllib('getStatusMPDev');
        end
        
        function retval = setAcquisitionChannels(obj)
            retval = obj.wrap_calllib('setAcqChannels', obj.channel_mask);
        end
        
        function retval = receiveData(obj)
            %[retval, buff, ~, samplesRead] = obj.wrap_calllib('receiveMPData', buff, samplesRequested, samplesRead);
            [retval, obj.buffer, obj.samples_read] = calllib(obj.lib_handle, ...
                'receiveMPData', obj.buffer, obj.buffer_size, obj.samples_read);
        end
        
        function retval = getChannelData(obj, ch_number)
            retval = obj.buffer(ch_number:length(obj.ch_presets):obj.buffer_size);
        end
        
        function retval = setSampleRate(obj)
            retval = obj.wrap_calllib('setSampleRate', double(obj.sample_rate));
        end
        
        function retval = startAcquisition(obj)
            retval = obj.wrap_calllib('startAcquisition');
        end
        
        function retval = stopAcquisition(obj)
            retval = obj.wrap_calllib('stopAcquisition');
        end
        
        function retval = startMpAcqDaemon(obj)
            retval = obj.wrap_calllib('startMPAcqDaemon');
        end
    end
end