function [ MIN,MEDIAN,MEAN,MAX,ISBLURRED ] = MISC_getAverageBlur( VIDEODIR,THRESH )

    vidObj = VideoReader(VIDEODIR);
    numFrames = get(vidObj, 'NumberOfFrames');
    
    ALL = zeros(1,numFrames);
    ISBLURRED = zeros(1,numFrames);
    for i = 1 : numFrames
        %disp(strcat(num2str(i),':',num2str(numFrames)));
        [ISBLURRED(i),ALL(i)] = MISC_isBlurred(read(vidObj,i),THRESH);
    end
    MIN = min(ALL);
    MEDIAN = median(ALL);
    MEAN = mean(ALL);
    MAX = max(ALL);
end

