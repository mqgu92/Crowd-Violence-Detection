% myVidSetup- setups the video feed. 3 types are handled different,
% depending on the 'kindOfMovie' input arg. Can be 'file'(file on disk),
% 'synthetic'(manufactured test sequence) or 'camera' (setups the default 
% video input device for capturing video for this application)
function vid =  myVidSetup(kindOfMovie,movieType,width, height,camID)
vid.camID = camID;
if strcmpi(kindOfMovie, 'file')
        %we open the file for reading
        vid = VideoReader(movieType);
    elseif strcmpi(kindOfMovie, 'synthetic') 
        vid.Height = height;   vid.Width  = width;
        %this option just requires two fields in the 'vid' structure
    elseif strcmpi(kindOfMovie, 'camera')
        vid.bUseCam = 1; %matlab built in
        vid.Height = height;   vid.Width  = width;
%         first, reset image aqcuisition devices. This also tests if the
%         toolbox is available. 
    try
       imaqreset;
    catch %#ok<CTCH>
        fprintf('\nImage Aquisition toolbox not available! \n Looking for videoinput library(this is a windows ONLY library)... ');
        vid.bUseCam = 2; %videoInput
        try
            VI = vi_create();
            vi_delete(VI);
            fprintf('FOUND IT!\n');
        catch %#ok<CTCH>
            error('no library available for camera input');
        end
    end
    if(vid.bUseCam==1) %matlab built in

    %     get info on supported formats for this capture device
        dev_info = imaqhwinfo('winvideo',vid.camID);
        strVid = dev_info.SupportedFormats;
    
    %     strVid contains all the supported formats as strings , for example 
        %     'I420_320x240' is one such format. I want to pick the smallest
        %     resolution available, so I parse these strings in what follows
        splitStr = regexpi(strVid,'x|_','split');
        pickedFormat = 0;
        resolutionFormat = Inf;
        for ik = 1:length(strVid)
            resW = str2double(splitStr{ik}{2});
            resH = str2double(splitStr{ik}{3});
            if (resW > (vid.Width-1) )&&(resH > (vid.Height-1) )&& (resW*resH)<resolutionFormat
                resolutionFormat = (resW*resH);
                pickedFormat = ik;
            end
        end
        % pick the selected format, color and a region of interest:
        vid.camIn = videoinput('winvideo',vid.camID,strVid{pickedFormat});
        set(vid.camIn, 'ReturnedColorSpace', 'gray');
    %     set(vid.camIn, 'ReturnedColorSpace', 'rgb');

        set(vid.camIn, 'ROIPosition', [1 1 vid.Width vid.Height]);
        %let the video go on forever, grab one frame every update time, maximum framerate:
        triggerconfig(vid.camIn, 'manual');
        src = getselectedsource(vid.camIn);
        if isfield(get(src), 'FrameRate')
            frameRates = set(src, 'FrameRate');
            src.FrameRate = frameRates{1};    
        end
        %other things you may want to play around with on your system:
    %         set(getselectedsource(vid.camIn), 'Sharpness', 1);
    %         set(getselectedsource(vid.camIn), 'BacklightCompensation','off');
    %         set(getselectedsource(vid.camIn), 'WhiteBalanceMode','manual');    
    % if running with the camera, now we start it:
    start(vid.camIn);
    pause(0.001);
    else %if vid.bUseCam == 2 %using videoinput library
        vid.camIn = vi_create();
        numDevices = vi_list_devices(vid.camIn);
        if numDevices<1,    error('video input found no cameras');end
        vi_setup_deviceProper(vid.camIn, camID-1, vid.Height, vid.Width, 30);
    end 
end
