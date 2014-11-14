function [ ALL_FEATURES, STRUCTURED_FEATURES,PATHS ] = TEST_TRAJHOF_EXTRACT( VIDLIST,FLOWDIR,FEATURES, WINDOW,WINDOWSKIP,PYRAMIDSTRUCT )
%%
%   Using the TRAJHOF method extract features
%
%
%%  GENERAL NOTES
%   SCENE - Collection of features that describe a video segment
%      NUMBER of SCENES per VID: (NUM of FRAMES - LARGEST WINDOW) / WINDOWSKIP;
%      
%% INPUT
%   VIDLIST: Information of Videos to load
%   FLOWDIR: Directory with video flow information
%   FEATURES: Number of features to extract per scene
%   WINDOW: Temporal length of a scene
%   WINDOWSKIP: How many frames to skip after each scene (1 = every frame)
%   PYRAMIDSTRUCT: How to sructure the position of features
%           [1,1] Is full frame, same as no pyramid
%           [2,2] Splits the frame into four segments, each feature is
%           saved into its approprate spatial location
%               You can use multiple pyramids at once [1,1;2,2]
%
%%  OUTPUT
%   ALL_FEATURES: Collection of all features FEATURES * SCENES
%       Mainly used for VOCAB generation and PCA analysis
%
%   STRUCTURED_FEATURES: Collection of features structures
%       ROW: VIDEO
%       COL1: Video Annotation Information
%       COL2: SCENE extracted from that video
%
%           EXAMPLE: [1,1;2,2] describes two pyramids, 1 by 1 and 2 by 2
%                   COL1: Stores all features as [1,1] is the entire frame
%                   COL2: Features in top right of frame
%                   COL3: Features in top left of frame
%                   COL4: Features in bottom right of frame
%                   COL5: Features in bottom left of frame
%
%%

%% Step 1: Load Flows
     totalTime = 0;
     vs = size(VIDLIST); % Number of Videos 

     ALL_FEATURES = cell(vs(1),2);
     STRUCTURED_FEATURES = cell(vs(1),2);
     
     
     
     for i = 1 : vs(1)
         tic;
         
         % Set window skip to default
         WS = WINDOWSKIP;
         % Check if we have a windowskip override
         if vs(2) == 6 
             if VIDLIST{i,6} ~= 0
                WS = VIDLIST{i,6};
             end
         end
         
         % Perform Feature Extraction
         [ VIDFEATURES,LEVELLIST] = GetVideoDescriptorsOptimize(FLOWDIR, VIDLIST{i,1},FEATURES,WINDOW,WS,PYRAMIDSTRUCT );
         if ~isempty(VIDFEATURES) && iscell(LEVELLIST) && ~isempty(LEVELLIST) 
             ALL_FEATURES{i,1} = VIDLIST(i,:);      
             ALL_FEATURES{i,2} = VIDFEATURES;       %All Features from that video
             
             STRUCTURED_FEATURES{i,1} = VIDLIST(i,:);
             STRUCTURED_FEATURES{i,2} = LEVELLIST;          % Features in pyramid structure
         else
             disp(['Empty ',num2str(i)]);
         end
         
         % Console Output for Progress
         currentTime = toc; totalTime = totalTime + currentTime;
         disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
     end
   



end

