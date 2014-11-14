%% PlayVideo
% Generate Video List
VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

VideoListItem = VideoList(1,:);

fullFileName = strcat(fullfile(VideoListItem{2:3}),VideoListItem{4});

disp(['Processing Video: ',fullFileName]);

VideoObj = videoReader(fullFileName);
numFrames = get(VideoObj, 'NumberOfFrames');

seenData = 1;
h =figure;
frm = 1;

videofig(VideoObj.NumberOfFrames, @(frm) redraw(frm, VideoObj),24);

redraw(1,VideoObj);