classdef visualSearch_statLearning_trial < handle
    %
    % Experimentor Defined Variables:
    %
    
    properties
        
        % Experimentor Defined Variables
        subject_ID          = 999;
        trial_order_num     = 99;
        run_order_num       = 1;
        setSize             = 8;
        targetPresence      = 'present';
        targetLocation      = 3;
        targetOrientation   = 'down';
        objectColor         = 'magenta';
        ITI_range           = [.250 .500]
        ITI;
        
        accuracy            = NaN;          % subject's single trial accuracy {1 == correct || 0 == incorrect}
        resp_keyname        = 'No_Press';   % response key name
        resp_keycode;                       % response gamepad key number
        RT;                                 % subject's single trial response time
        
    end % properties
    
   
    
    properties (Hidden = true)
        event_code;
        cue_stim;                         % Cue    stimulus to draw
        searchStimuli;                    % Search stimulus to draw
        
        search_annulus_radius   = 200;
        
    end
    
    events
        calculateAccuracy
    end
    
    methods
        
        function obj   = visualSearch_statLearning_trial(varargin)
            
            switch nargin
                case 0
                    
                    
                case 9
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.event_code                  = varargin{3};
                    obj.setSize                     = varargin{4};
                    obj.targetPresence              = varargin{5};
                    obj.targetLocation              = varargin{6};
                    obj.targetOrientation           = varargin{7};
                    obj.ITI_range                   = varargin{8};
                    obj.search_annulus_radius       = varargin{9};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.searchStimuli                 = stimLandoltCArray.empty;
            
            
            %% Calculate inter-trial interval
            obj.ITI  = min(obj.ITI_range) + (rand * (max(obj.ITI_range)-min(obj.ITI_range))); % create random preCue ISI based min & max
            
            % Set up stimulus objects
            obj.searchStimuli = stimLandoltCArray(obj.setSize, obj.search_annulus_radius, obj.targetLocation, obj.targetOrientation, obj.objectColor); % , -7*pi/obj.setSize);
            
        end % constructor method
        
        function trial_obj = saveResponse(trial_obj, subject_response)
            
            trial_obj.resp_keyname    = subject_response.keyname;               % response key name
            trial_obj.resp_keycode    = subject_response.keycode;               % response gamepad key number
            trial_obj.RT              = subject_response.time;                  % subject's single trial response time
%             notify(trial_obj, 'calculateAccuracy');
            
        end       % method
    
        
    end % methods
    
end % classdef
