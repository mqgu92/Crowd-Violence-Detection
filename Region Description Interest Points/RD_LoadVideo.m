function [ EntireVideo ,numFrames] = RD_LoadVideo( VIDEOLISTITEM,RESIZEVALUE )

fullFileName = strcat(fullfile(VIDEOLISTITEM{2:3}),VIDEOLISTITEM{4});

disp(['Processing Video: ',fullFileName]);

%% Load the Video File Into Matlab
disp('Loading Video');
tic;
vidObj = VideoReader(fullFileName);
numFrames = get(vidObj, 'NumberOfFrames');

frame = rgb2gray(read(vidObj,1));
frame = imresize(frame,RESIZEVALUE);
frameSize = size(frame);
EntireVideo = zeros(frameSize(1),frameSize(2),numFrames) ;

for v = 1: numFrames;
    EntireVideo(:,:,v) = imresize(rgb2gray(read(vidObj,v)),RESIZEVALUE);
end

disp(['Loading Complete:',num2str(toc)]);
end

