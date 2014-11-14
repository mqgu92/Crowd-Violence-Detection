function [ SCENE ] = GetViFDescriptors(FLOWDIR, VIDNAME ,WINDOW,WINDOWSKIP,X,Y,HISTSIZE)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%   Extracts Violent Flows descriptors from a video and returns a set of
%   described window samples
%
%   HISTSIZE: Number of bins used to store motion
%   X,Y:    Number of horizontal and vertical cells that make a frame
%   

disp(strcat('Next Video:',VIDNAME));

%WINDOW = 30;
FRAMES = 9999;

%% Step 1: Load Video Flows

%Check folder containing flows exists
if exist(strcat(FLOWDIR,VIDNAME),'dir') <= 0
    disp(strcat(FLOWDIR,VIDNAME));
    SCENE = 0;
    return;
end

% Find the number of flow files are present
dirInfo = dir(strcat(FLOWDIR,VIDNAME,'\*.mat'));
dirSize = size(dirInfo);


if FRAMES < dirSize(1)
    limit = FRAMES;
else
    limit = dirSize(1);
end

if WINDOW > limit 
    getIndex = 1:WINDOWSKIP:(limit - WINDOW) ;
    saveNumber = length(getIndex);
else
    getIndex = 1:WINDOWSKIP:(limit - WINDOW) ;
    saveNumber = length(getIndex);
end

bMapList = cell(limit,1); %Binary Maps

fileName = strcat(FLOWDIR,VIDNAME,'\',dirInfo(1).name);
load(fileName);

% Flow Vectors have different names based on the method that was used to
% extract them, vx1 and vy1 are SIFT Flow, U1 and V1 are Optical FLow 
if exist('vx1')
    UP = vx1; %Previous U Flows (t-1)
    VP = vy1; %Previous V Flows (t-1)
else
    UP = U1; %Previous U Flows (t-1)
    VP = V1; %Previous V Flows (t-1)
end

for i = 2 : limit;
    fileName = strcat(FLOWDIR,VIDNAME,'\',dirInfo(i).name);
    load(fileName);
    if exist('vx1')
        UN = vx1; %Previous U Flows (t-1)
        VN = vy1; %Previous V Flows (t-1)
    else
        UN = U1; %Previous U Flows (t-1)
        VN = V1; %Previous V Flows (t-1)
    end
    [ BINARYMAP, ~ ] = MD_UV2BinaryMap( UN,VN,UP,VP );
    
    VP = VN;
    UP = UN;
    
    % Split each binary map into X, by Y cells and store them
    bMapList{i - 1} = reshape(MISC_splitMat(BINARYMAP,X,Y),Y,X);
end



SCENE = cell(saveNumber,1); % Store windowed HOF and Path

tic;
for i = 1 : saveNumber;
    p = getIndex(i);
    %Each scene comprises of X*Y histograms of length HISTSIZE
    subScene = zeros(X*Y,HISTSIZE);
    
    %Each segment must be averaged and histogramed
    for k = 1: X*Y
        subMap = 0;
        
        % Sum each binary map cell over a series of frames
        for j = p:p + (WINDOW - 1 )
            bMap = bMapList{j};
            subMap = subMap + bMap{k};
        end
        
        % Represent a cell as a histogram of normalized values
        subMap = reshape(subMap,1,prod(size(subMap)));
        subHist = hist(subMap * (1/length(p:p + (WINDOW - 1) )), HISTSIZE);
        subScene(k,:) = subHist;
    end
    SCENE{i} = subScene;
end
end

