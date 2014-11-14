function ME_BatchExtractFlows( VIDEOLIST )
%%
%
%   Function used to extract SIFTFlow data from a large set of videos
%   Data will be saved in a FLOWS folder
%
%%

for i = 1 : length(VIDEOLIST)

    VideoDir = VIDEOLIST{i};
    if exist(VideoDir, 'file')
        ME_ExtractFlows(VideoDir,'');
        disp(strcat('Video Extracted: ',VideoDir));
    else
        disp(strcat('Video Does not Exist: ',VideoDir));
    end


    
end
    


end

