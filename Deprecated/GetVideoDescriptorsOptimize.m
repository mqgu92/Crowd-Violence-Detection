function [ ALLFEATURES,PYRAMID] = GetVideoDescriptorsOptimize(FLOWDIR, VIDNAME ,FEATURES,WINDOW,WINDOWSKIP,LEVELS)
%%
%   Trajectory Histogram of Flows feature extraction
%   
%   OUTPUT:
%       ALLFEATURES: Collection of all non-grouped features that are extracted
%       from the current sample
%       PYRAMID: Spatial Pyramid collection of grouped features,
%       parameter [1,1] is equal to no pyramid structure
%%
PYRAMID = {}; % Pyramid Output
PATHS = {}; % List of Trajectories
disp(strcat('Next Video:',VIDNAME));

FRAMES = 3000; % File loading limit

%% Step 1: Load pre-calculated Video Optical Flows

if exist(strcat(FLOWDIR,VIDNAME),'dir') <= 0
    % Flows don't exist so return nothing
    disp(strcat('RETURNED',FLOWDIR,VIDNAME));
    ALLFEATURES = 0;
    PYRAMID = 0;
    return;
end

% Load a list of flow files
dirInfo = dir(strcat(FLOWDIR,VIDNAME,'\*.mat'));
dirSize = size(dirInfo);

% Check if number of flows exceed load capacity 
if FRAMES < dirSize(1)
    limit = FRAMES;
else
    limit = dirSize(1); 
end

% U
getIndex = 1:WINDOWSKIP:(limit  - max(WINDOW) ) ;
saveNumber = length(getIndex);

% Flow Storage
uflows = cell(limit,1);
vflows = cell(limit,1);
% Flow Direction Map partition into 'b' bins
bMapList = cell(limit,1);
% Flow Magnitude map, the intensity of motion
mMapList = cell(limit,1);

for i = 1 : limit;
    fileName = strcat(FLOWDIR,VIDNAME,'\',dirInfo(i).name);
    load(fileName); % Load the flow file
    if exist('vx1')
        uflows {i} = vx1;   % Add u vector map to global list
        vflows {i} = vy1;   % Add v vector map to global list
    else
        uflows {i} = U1;   % Add u vector map to global list
        vflows {i} = V1;   % Add v vector map to global list
    end   

    
    % Calculate orientation and magnitude maps
    % oritentations are rounded into 8 direction(bins)
    [ ~,mMap,bMap ] = MD_UV2Maps( vflows {i},  uflows {i} , 0, 8 );
    bMapList{i} = bMap;
    mMapList{i} = mMap;
end

flowSize = size(uflows{1});
%% SETUP SPATIAL PYRAMID DATA STRUCTURE

ls = size(LEVELS);
PYRAMID = cell(1,ls(1));
for l = 1: length(PYRAMID)
    PYRAMID{l} = cell(saveNumber,LEVELS(l,1)*LEVELS(l,2));
end

%% Step 2: Extract Trajectory Descriptor and HOF Descriptor
ALLFEATURES = {};
tic; % Timer Start

for i = 1 : saveNumber;
    p = getIndex(i);
    BestIDX = 0;
   
   TrajHOF = cell(FEATURES,length(WINDOW));     
   MeanPath = zeros(FEATURES,2);
   for WIND = length(WINDOW): -1 : 1
       % Using optical flow vector maps create a list of paths that occur
       traj = MD_FollowSIFTFlowOpt( uflows(p:p + WINDOW(WIND) ), vflows(p:p + WINDOW(WIND)));
       
       if BestIDX ~= 0
            % If the path have already been determined then assign them for
            % further processing
            FLOWPATHS = reshape(traj,1,numel(traj));
            BestPaths = FLOWPATHS(BestIDX);
       else
           % Reduce the number of trajectories to 'FEATURES' 
           [BestPaths, BestIDX] = MD_BestPaths( traj,FEATURES);
       end
       
       %% Calculate the Histogram of Oriented Flows around the trajectory

       for j = 1 : length(BestPaths)
           bMapSeg = bMapList(p:p + WINDOW(WIND) );
           mMapSeg = mMapList(p:p + WINDOW(WIND) );
           currentPath = BestPaths{j};
           
           % Computer trajectory shape
           TT = MD_TrajectoryShape( round(currentPath(:,1)),round(currentPath(:,2)), true );
           % Re-arrange two vectors representing change in X and Y into a a
           % single 1d vector
           Traj = [TT(:,1)',TT(:,2)']; 
           
           % Calculate the HOF about the trajectory
           HOF = MD_TrajectoryHOFwBinMap(round(currentPath(:,1)),round(currentPath(:,2)),bMapSeg, mMapSeg);
           % Merge both Trajectory and HOF together
           TrajHOF{j,WIND} = [Traj,HOF];
           
           % Determine the position of the trajectory within the
           % frame based on displacement mean
           XPath = currentPath(:,1);XStart = round(mean(XPath));
           YPath = currentPath(:,2);YStart = round(mean(YPath));
           MeanPath(j,1) = XStart;
           MeanPath(j,2) = YStart;
           
       end       
   end
   
   %% FORMULATE THE FINAL DESCRIPTOR
   hs = size(TrajHOF);
   for k = 1: hs(1)
       % Features are store in { TRAJECTORY, HOF}, cell2mat will combine
       % them into a single vector
       TrajHOF{k} = cell2mat(TrajHOF(k,:));
       
       % Compute pyramid feature composition
       for l = 1: length(PYRAMID)
           % Determine Paths Place in LEVEL{1} using mean position
           XPoint =  MeanPath(k,1) / (flowSize(2)/LEVELS(l,1)) + 1;
           YPoint =  MeanPath(k,2) / (flowSize(1)/LEVELS(l,2)) + 1;
           
           % Conver 2D position into 1D index
           IND = sub2ind([LEVELS(l,2),LEVELS(l,1)],...
               min(max(1,round(YPoint)),LEVELS(l,2)),...
               min(max(1,round(XPoint)),LEVELS(l,1)));
           
           % Add the current feature to the cell in the pyramid
           SaveValues = PYRAMID{l}; % Extract existing data
           SaveValues{i,IND} = [SaveValues{i,IND};TrajHOF{k,1}]; % Add new
           PYRAMID{l} = SaveValues; % Re-assign amended data
       end
       
   % Add feature to a global scene collection
   ALLFEATURES = [ALLFEATURES;TrajHOF{k,1}];  
   end
   disp((i/saveNumber) * 100);
end
  disp(strcat('Tock-',num2str(toc)));
       
end

