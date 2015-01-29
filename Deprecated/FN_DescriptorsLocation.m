function [ DESCRIPTORLIST,RANGE ] = FN_DescriptorsLocation( VIDEOLIST,VIDEONAME,WINDOWSIZE,WINDOWSKIP, DESCRIPTORLIST )
% Given a list of videos, Windowskip and WindowSize determine which
% descriptors belong to which video,

RANGE = 0;  % DEFAULT VALUE

if nargin > 1
    % Only Calulate the descriptor list
    % Load Each Video in turn and extract the number of frames held
    [M, ~] = size(VIDEOLIST);
    
    EntireList = cell(M,2); %Column for total, column for range
    
    for i = 1: M
        % Determine the number of descriptors extracted given the parameters
        
        VideoListItem = VIDEOLIST(i,:);
        
        fullFileName = strcat(fullfile(VideoListItem{2:3}),VideoListItem{4});
        
        disp(fullFileName);
        
        VideoObj = videoReader(fullFileName);
        
        numFrames = get(VideoObj, 'NumberOfFrames');
        
        
        % Append to a list
        NumberOfDescriptors = 1:WINDOWSKIP:(numFrames - WINDOWSIZE );
        
        EntireList{i,1} = length(unique(NumberOfDescriptors));
        
        EntireList{i,2} = sum( [EntireList{ 1 : i - 1 ,1 },1] ) : sum([EntireList{ 1 : i, 1 }]);

    end
    
    %Clear Up
    DESCRIPTORLIST = EntireList;
    clearvars -except DESCRIPTORLIST VIDEOLIST VIDEONAME;
    
    % Locate the Video with the Video name and output a list
    if nargin == 4
        % Search
        VideoNames = VIDEOLIST(:,3);
        [~, ind] = max(~cellfun(@isempty,strfind(VideoNames,VIDEONAME)));
        RANGE = DESCRIPTORLIST(ind,2);
    end
    
else
    % Just search using a pre-defined list
        VideoNames = VIDEOLIST(:,3);
        [~, ind] = max(~cellfun(@isempty,strfind(VideoNames,VIDEONAME)));
        RANGE = DESCRIPTORLIST(ind,2);
end




end

