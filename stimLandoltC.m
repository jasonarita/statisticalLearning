classdef stimLandoltC
    %STIMLANDOLTCSummary of this function goes here
    %   Detailed explanation goes here
    % stimLandoltC(location_pt, orientation_wd, inColor)
    % draw(winPtr)
    % draw(winPtr, gapLoc)
    % draw(winPtr, gapLoc, location)



    properties
        location_pt         = [100 100];
        orientation_wd      = 'down';
        gapSize_px          = 10;
        size_px             = 30;
        frameWidth_px       = 6;
        frameColor_wd       = 'red';
        
        xyMatrix;

    end % properties

    properties(Dependent = true)
        
        frameColor_rgb;
        
    end % dependent properties
    

    methods

        function obj = stimLandoltC(varargin)
            % constructor function for STIMLANDOLTC

            % DEFAULTS

            switch nargin
                
                case 0 
                    % use defaults
                case 2
                    
                    obj.location_pt         = varargin{1};
                    obj.orientation_wd      = varargin{2};

                case 3
                    
                    obj.location_pt         = varargin{1};
                    obj.orientation_wd      = varargin{2};
                    obj.frameColor_wd       = varargin{3};
                    
                case 4
                    
                    obj.location_pt         = varargin{1};
                    obj.orientation_wd      = varargin{2};
                    obj.frameColor_wd       = varargin{3};
                    
                    % Cortical Scaling
                    sizeScale           = varargin{4};
                    obj.size_px             = obj.size_px       * sizeScale;
                    obj.gapSize_px          = obj.gapSize_px    * sizeScale;
                    obj.frameWidth_px       = obj.frameWidth_px * sizeScale;
                otherwise
                    error('Wrong number of input arguments');
            end
            
            sizeC       = obj.size_px;
            sizeD       = obj.size_px - obj.frameWidth_px;
            gapsizeC    = obj.gapSize_px;
            gapLocation = obj.orientation_wd;
                        
            
            %Make the Landolt-C shape         

            
            switch gapLocation %boxes are always made top line(s), right line(s), bottom line(s), then left line(s)
                case 'up'
                    obj.xyMatrix=[-.5*sizeC, -.5*gapsizeC,  .5*gapsizeC,  .5*sizeC,     .5*sizeD, .5*sizeD,    -.5*sizeC, .5*sizeC,    -.5*sizeD, -.5*sizeD;... % x line-pts
                              -.5*sizeD, -.5*sizeD,    -.5*sizeD,    -.5*sizeD,    -.5*sizeC, .5*sizeC,     .5*sizeD, .5*sizeD,    -.5*sizeC,  .5*sizeC];  % y line-pts
                case 'right'
                    obj.xyMatrix=[-.5*sizeC,  .5*sizeC,    .5*sizeD, .5*sizeD,   .5*sizeD,   .5*sizeD,    -.5*sizeC, .5*sizeC,     -.5*sizeD, -.5*sizeD;...
                              -.5*sizeD, -.5*sizeD,   -.5*sizeC,-.5*gapsizeC,.5*gapsizeC,.5*sizeC,     .5*sizeD, .5*sizeD,     -.5*sizeC,  .5*sizeC];
                case 'down'
                    obj.xyMatrix=[-.5*sizeC,  .5*sizeC,    .5*sizeD, .5*sizeD,   -.5*sizeC, -.5*gapsizeC,.5*gapsizeC, .5*sizeC,     -.5*sizeD, -.5*sizeD;...
                              -.5*sizeD, -.5*sizeD,   -.5*sizeC, .5*sizeC,    .5*sizeD,  .5*sizeD,   .5*sizeD,    .5*sizeD,     -.5*sizeC,  .5*sizeC];
                case 'left'
                    obj.xyMatrix=[-.5*sizeC, .5*sizeC,     .5*sizeD,.5*sizeD,    -.5*sizeC,.5*sizeC,    -.5*sizeD,-.5*sizeD,  -.5*sizeD,  -.5*sizeD;...
                              -.5*sizeD,-.5*sizeD,    -.5*sizeC,.5*sizeC,     .5*sizeD,.5*sizeD,    -.5*sizeC,-.5*gapsizeC,.5*gapsizeC,.5*sizeC];
                otherwise
                    error('Input ErrorWrong stimulus gap location number');
            end

            %Create the position correction positions for the stimuli, based on the position matrix input
            X=1;    % array index for x-coordinate
            Y=2;    % array index for y-coordinate
            numLinePts      = size(obj.xyMatrix,2);
            positionMatrix  = [ repmat(obj.location_pt(X), [1 numLinePts]) ;  % x line-points
                                repmat(obj.location_pt(Y), [1 numLinePts])];  % y line-points
                            

                                     
            obj.xyMatrix        = round(obj.xyMatrix+positionMatrix);                                % set landolt-c matrix in final position            


        end % constructor method
        
        function obj    = set.frameWidth_px(obj, width_px)
            if(~mod(width_px, 2))
                obj.frameWidth_px = width_px;
            else
                error('FRAMEWIDTH_PX: frame width must be even number of pixels');              
            end
        end % set method
        
        function value  = get.frameColor_rgb(obj)
            
            value = seColor2RGB(obj.frameColor_wd);
            
        end % get method
            
        function draw(obj, winPtr, location_pt)           
            
            Screen('DrawLines', winPtr, obj.xyMatrix, obj.frameWidth_px, seColor2RGB(obj.frameColor_wd), location_pt);

        end % draw method
        
        function show(obj)
            
            try

                bgColor = 'white';
                [winPtr, ~, centerPt] = seSetupScreen(seColor2RGB(bgColor));
                Priority(MaxPriority(winPtr));

                % ---- INSERT DRAW COMMANDS ---- %
                                              
                obj.draw(winPtr, centerPt);
               
                
                % ------------------------------ %
                
                Screen('Flip', winPtr);     % flip/draw buffer to display monitor
                KbWait;
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);
                
            catch matlab_err
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
                
            end % try-catch
            
        end % method
        
    end % methods

end % class def

