classdef stimLandoltCArray
    %STIMARRAY Summary of this function goes here
    %   stimArray(centerPt, targ_orientation, targBoxNum, exptVars)

    properties

        stims;
        centerLoc_pt;
        arrayRadius;
         
        targetLocation;
        targetOrientation;
        targetColor;
        distractor_orientations;
        jitter_px; 
        
        xyMatrix;
        colorMatrix;
    end % properties
    
    
    properties(Dependent = true)
        
        numStim;
        
    end


    methods
        
        function obj    = stimLandoltCArray(varargin)
            % obj = stimArray(centerPt, exptVars)
            % obj = stimArray(centerPt, TargetPresence, targetBoxNum, exptVars)
            numStim                         = 8;
            sizeScale                       = 1;

            obj.xyMatrix                    = [];
            obj.colorMatrix                 = [];
            obj.centerLoc_pt                = [0,0];
            obj.arrayRadius                 = 200;
            radius_shift                    = -5*pi/numStim;
            
            obj.distractor_orientations     = {'left', 'right'};
            distractor_color                = 'black';
            
            obj.targetLocation              = 8;
            obj.targetOrientation           = 'up';
            obj.targetColor                 = distractor_color;
            
            
            switch nargin
                case 0
                    
                case 2
                    
                    numStim             = varargin{1};
                    obj.arrayRadius     = varargin{2};
                    
                case 5
                    numStim                 = varargin{1};
                    obj.arrayRadius         = varargin{2};
                    obj.targetLocation      = varargin{3};
                    obj.targetOrientation   = varargin{4};
                    obj.targetColor         = varargin{5};
                    
%                 case 4
%                     numStim             = varargin{1};
%                     obj.arrayRadius         = varargin{2};
%                     
%                     if(isstruct(varargin{3}))
%                         uniqueLandoltCs = varargin{3};
%                     elseif(isnumeric(varargin{3}))
%                         sizeScale       = varargin{3};
%                     end
%                     
%                     radius_shift        = varargin{4}; % overrides radius shift
                    
                otherwise
                    error('Wrong number of input arguments');
            end







            %% ------------------
            % Create Stim:
            % -------------------
            
            obj.stims                   = cell(numStim, 1); % initial stimArray
            obj.jitter_px               = 0;            
            obj.xyMatrix                = [];
                         
            
            % Set DISTRACTOR stimuli
            for stimNum = 1:numStim
                
                % Set distractor LOCATION
                X=1;    % array index for x-coordinate
                Y=2;    % array index for y-coordinate
                obj_locPt   = radialCoordinate(stimNum, numStim, obj.centerLoc_pt, obj.arrayRadius, radius_shift);
                obj_locPt(X) = obj_locPt(X) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                obj_locPt(Y) = obj_locPt(Y) + round(rand * (obj.jitter_px - -obj.jitter_px) + -obj.jitter_px);
                
                if(stimNum == obj.targetLocation)
                    % Set TARGET ORIENTATION
                    landoltC_orientation        = obj.targetOrientation;
                else
                    % Set DISTRACTOR ORIENTATION
                    numDistractor_orientations  = length(obj.distractor_orientations);
                    landoltC_orientation        = obj.distractor_orientations{round(rand*(numDistractor_orientations-1)+1)};
                end
                
                % Set distractor COLOR
                landoltC_color              = distractor_color;
                
                % create Landolt-C object
                obj.stims{stimNum}  = stimLandoltC(obj_locPt, landoltC_orientation, landoltC_color, sizeScale);
                
                
                obj.xyMatrix        = [obj.xyMatrix     obj.stims{stimNum}.xyMatrix];
                obj.colorMatrix     = [obj.colorMatrix  repmat(obj.stims{stimNum}.frameColor_rgb', [1 length(obj.stims{stimNum}.xyMatrix)])];

            end % stim loop
            
            
        end

        function value  = get.numStim(obj)
            
            value = length(obj.stims);
            
        end % get method
        
        function draw(obj, varargin)
                       
            switch nargin
                
                case 2 
                    winPtr = varargin{1};
            
                    Screen('DrawLines', winPtr, obj.xyMatrix, obj.stims{1}.frameWidth_px, obj.colorMatrix, obj.centerLoc_pt);
           
                case 3
                    
                    winPtr          = varargin{1};
                    new_location_pt = varargin{2};
                    Screen('DrawLines', winPtr, obj.xyMatrix, obj.stims{1}.frameWidth_px, obj.colorMatrix, new_location_pt);
                    
                otherwise
                    error('Wrong number of input arguments');
                    
            end
                    
        end % draw method

        function value  = show(obj)
            
            try
                bgColor = 'white';
                [winPtr, winRect, center_pt] = seSetupScreen(seColor2RGB(bgColor)); %#ok<ASGLU>
                Priority(MaxPriority(winPtr));

                % INSERT DRAW COMMANDS
                        
                
                keyIsDown = false;
                counter   = 1;
                
                while(~keyIsDown)
                
                tic;
                obj.draw(winPtr, center_pt);
                value(counter) = toc; %#ok<AGROW>
                
                % ----------------------
                
                Screen('Flip', winPtr);     % flip/draw buffer to display monitor
                
                keyIsDown   = KbCheck;
                counter     = counter + 1;
                end
                
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);

                
            catch matlab_err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
            end
            
        end % method
        
    end % methods

    
end % class def


function outputLoc_pt = radialCoordinate(varargin)
%RADIALCOORDINATE
% returns cartesian coordinate position of a point on a circle defined by
% RADIUS pixels away from a center.
% 
%   outputLoc_pt = radialCoordinate(stimNum, numStim, radius)
%   outputLoc_pt = radialCoordinate(stimNum, numStim, centerLoc_pt, radius)

% Defaults
radius_shift        = -pi/2;

switch nargin
    
    case 3
        
        stimNum         = varargin{1};
        numStim         = varargin{2};
        radius          = varargin{3};
        centerLoc_pt    = [0,0];
        
    case 4
        
        stimNum 	   = varargin{1};
        numStim        = varargin{2};
        centerLoc_pt   = varargin{3};
        radius         = varargin{4};
        
    case 5
        
        stimNum 	   = varargin{1};
        numStim        = varargin{2};
        centerLoc_pt   = varargin{3};
        radius         = varargin{4};
        radius_shift   = varargin{5};   % overrides RADIUS_SHIFT
        
    otherwise
        error('Wrong number of input arguments');
end
X=1;    % array index for x-coordinate 
Y=2;    % array index for y-coordinate

% Calculate location
radIncr         = (2 * pi)/numStim;   % spacing between stimuli (in radians)

outputLoc_pt = ...
    [ round(centerLoc_pt(X) + cos((stimNum * radIncr) + radius_shift) * radius)     ... % x-coord
    , round(centerLoc_pt(Y) + sin((stimNum * radIncr) + radius_shift) * radius)     ... % y-coord
    ];

end
