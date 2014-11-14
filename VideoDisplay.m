function VideoDisplay( VIDEO_DIR )
vidObj = videoReader(VIDEO_DIR);

numFrames = vidObj.NumberOfFrames;

Frame = read(vidObj,1);

outputFigure = imshow(Frame);

FrameTime = 1/vidObj.FrameRate;

for f = 2 : numFrames;
    tic;
    currentFrameStartTime = toc;
    Frame = read(vidObj,f);
    Frame = rgb2gray(Frame);
    
    Frame2 = read(vidObj,f - 1);
    Frame2 = rgb2gray(Frame2);
    
    FrameDiff = Frame - Frame2;
    while true
        currentFrameTime = toc - currentFrameStartTime;
        if currentFrameTime  >= FrameTime
            break;
        end
    end
    
    imageSize = size(Frame);
    output = zeros(imageSize(1),imageSize(2),3);
    output(:,:,1) = Frame;
    output(:,:,3) = FrameDiff;
    
    set(outputFigure,'cdata',output/256);
end


end

