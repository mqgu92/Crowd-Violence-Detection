% Authors:
% Stefan M. Karlsson AND Josef Bigun 
function [dx, dy, dt,U1, V1] = vidProcessing2D(movieType, method,bFineScale,spdFactor, lagTime,CLASS)
% quick usage:
% vidProcessing(); - displays a sequence of test images
% vidProcessing(movieType); - same as above, but on video source indicated by the
% argument. movieType can be:
% 'synthetic' - generates a synthetic video on the fly
% 'camera' - generates video through a connected camera (requires image acquisition toolbox)
% 'cameraX' - where X is number indicating which of system cameras to use
% (default is 1). This is to be input into the string, such as e.g.: 
%         vidProcessing('camera1','edge');
% filename - name of video file in the current folder.
% example: vidProcessing('lipVid.avi'); - assumes an avi file is in the current folder
%
% explicit usage:
% [dx,dy,dt] = vidProcessing(movieType);
% Output dx, dy and dt are all WxH matrices containing the x, y, and t 
% partial derivatives over time. 
% W and H are the height and width of the video
%
% [dx,dy,dt] = vidProcessing(movieType, method); displays the same sequence, but
% with a method selected for analyzing the sequence.
% Valid options for 'method' are:
% - "LK"      (Lukas and Kanade)
% - "NOTHING" ([default] zero fields)
%
% There are 2 special aditional options for 'method', both of which 
% will not give flow output:
% - "gradient"    Displays the gradient values
% - "edge"        Displays the 2D edge detection
% 
% [dx,dy,dt] = vidProcessing('synthetic', method,spdFactor); 
% additionally sets a speed factor (spdFactor) to change the speed of the
% synthetic video generation (if spdFactor=2, then the synthetic sequence 
% is twice as fast)
% final argument "lagTime" is an optional additional lag-time in seconds,
% added as a pause between each frame updates

%ensure access to functions and scripts in the folder "helperFunctions"
addpath('helperFunctions');
global g; %contains shared information, ugly solution, but the fastest

ParseAndSetupScript; %script for parsing input and setup environment

vidObj = VideoReader(movieType);
% index variable for time:
t=1;
vFrames = vidObj.NumberOfFrames;
%from this point on, we handle the video by the object 'vid'. This is how
%we get the first frame:
curIm = generateFrame(vid, t,kindOfMovie,g.spdFactor,g.arrowKey);
% gradient calculations of the subvolume will be handled by the mex module 
% "Grad2D". It has a local copy internally of the previous frame, 
% which we initialize now
grad2Dm(curIm,bFineScale,1);
% 'targetFramerate', for displaying only
if strcmpi(kindOfMovie,'camera')
    targetFramerate = 200;%we just want to capture frames as fast as possible from cameras
else
    targetFramerate = 25; 
end
while t <= vFrames %%%%%% MAIN LOOP, runs until user shuts down the figure  %%%%%
    tic; %time each loop iteration;
    t=t+1;
    curIm = generateFrame(vid, t,kindOfMovie,g.spdFactor,g.arrowKey);

    [dy, dx, dt] = grad2Dm(curIm,bFineScale);

    switch method
        case 'edge'
            edgeIm = DoEdgeStrength(dx,dy);
        case 'gradient'%do nothing, gradient already given
        case 'flow1full'
            [U1, V1] = DoFlowT1(dx,dy,dt);
        otherwise %flow methods
            [U1, V1] = DoFlow(dx,dy,dt,method);
            

    end
    
%         n1 = MISC_Padzeros(t,8);
%        
%         fileName = fullfile('OPTICALFLOWS',CLASS,movieType,strcat('/Flow-',n1,'-to-',n1));
% 
%         if exist(strcat(fileName,'.mat'),'file')
%            % load(fileName);
%         else
%             
% 
%         if ~exist(strcat('OPTICALFLOWS/',CLASS),'dir')
%                 mkdir(strcat('OPTICALFLOWS/',CLASS));
%         end
%         
%         if ~exist(strcat('OPTICALFLOWS/',CLASS,'/', movieType),'dir')
%                 mkdir(strcat('OPTICALFLOWS/',CLASS,'/', movieType));
%         end
%         
%         save(fileName,'U1','V1');
% 
%         end
%         
    % first run is t==2, then setup graphics based on method and size of data 
    if t == 2,
        setupGraphicsScript; 
    end

    if ishandle(figH)%check if the figure is still open
        updateGraphicsScript;
    else%user has killed the main figure, break the loop and exit
        break;
    end

	%if paused, stay here:
    while (g.bPause && ishandle(figH)), pause(0.3);end

    % Pause to achieve target framerate, with some added lag time:
    timeToSpare = max(0.001, (1/targetFramerate) - toc + g.lagTime); 
    pause( timeToSpare); 

end  %%%%%%% END MAIN LOOP  %%%%%%%%%
close(figH);
% Clean up:
cleanUpScript;
