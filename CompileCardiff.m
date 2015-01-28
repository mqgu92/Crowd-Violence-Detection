VideoObj = VideoReader('E:\Datasets\Video\Queen.avi');

hFig = figure(1);
set(hFig, 'Position', [100 100 320 240])

frames =  2200; %30 seconds
outputVideo = zeros(240,320,3,frames);
writerObj = VideoWriter('Bad Mod Vjideo mean 4 4.avi') 
writerObj.FrameRate = 12;
open(writerObj);


RESULTS = round(mean(SVMOutput,2)); RESULTS = abs(RESULTS - 2);
%RESULTS = sum(SVMOutput,2); RESULTS(RESULTS ~= 3) = 0;RESULTS(RESULTS == 3) = 1;

THRESH = 3;
BUFFER = 8;
%RESULTS = rand(frames,1);
i2 = BUFFER + 850;
frameImage = VideoObj.read(i2);
h = image(frameImage);

while i2 < frames;
    
    CurrentFrame = 'Not Violent';
    
    i2 = i2+1;
    frameImage = VideoObj.read(i2);
    %Check the past BUFFER frames
    %   1 for fight, 0 for not fight
    if sum(RESULTS(i2 - BUFFER: i2)) > THRESH
        % Current frame is violence
        CurrentFrame = 'Violent';
        frameImage = imadjust(frameImage,[.2 .2 0; .9 1 1],[.3 .05 .05;.95 .95 .95 ]);
    end
    
    
    set(h ,'CData',frameImage);
    %image(frameImage) ; hold on
    
    rectangle('Position',[0,0,100,30],'FaceColor','y');
    text(5,15,CurrentFrame); 

        axis tight;
        set(gca, 'LooseInset', get(gca,'TightInset'))
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
   A = getframe(hFig);
   % outputVideo(:,:,:,i2) = A.cdata;
    writeVideo(writerObj,A.cdata);
    
end

close(writerObj);
