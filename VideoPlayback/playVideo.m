%% PlayVideo
% Generate Video List
VideoNumber = 58;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

VideoListItem = VideoList(VideoNumber,:);
DescriptorRange = DescriptorList{VideoNumber,2};
fullFileName = strcat(fullfile(VideoListItem{2:3}),VideoListItem{4});

disp(['Processing Video: ',fullFileName]);

VideoObj = videoReader(fullFileName);
numFrames = get(VideoObj, 'NumberOfFrames');

%global ViewFigure;
global PlotFigure;

%figure,ViewFigure = gca;
figure,PlotFigure = gca;
frm = 1;



%Make Sure we Have non-PCA descriptors
if ~isempty(GEPNonPCADescriptors)
    
    SubDescriptors = GEPNonPCADescriptors(DescriptorRange,:);
    
    videofig(VideoObj.NumberOfFrames,...
        @(frm) ...
            redraw(frm,...
            VideoObj,...
            WINDOWSKIP,...
            SubDescriptors)...
        ,24);
else
    error('Descriptor Information is Missing');
end
redraw(1,VideoObj,WINDOWSKIP,SubDescriptors);