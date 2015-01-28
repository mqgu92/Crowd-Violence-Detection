DATA_VIDEO_CHOSENSET = DATA_VIDEO_NXN;
q = 10;
VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

Videos = cell(9,1);
for i = 1 : 9
    VideoListItem = VideoList(i,:);
    Videos{i} =  VideoReader( strcat(fullfile(VideoListItem{2:3}),VideoListItem{4}));
end
hFig = figure(1);
set(hFig, 'Position', [0 0 1000 1000])
i2 = 0;
frames = 6*10; %30 seconds

outputVideo = zeros(999,999,3,frames);
writerObj = VideoWriter('out.avi') 
writerObj.FrameRate = 6;
open(writerObj);
while i2 < frames;
   
    i2 = i2+1;
    
    for i = 1 : 9
        V = Videos{i};
        subaxis(3,3,i,'Spacing', 0.01, 'Padding', 0, 'Margin', 0)
        image(V.read(i2))
        axis off;
       % axis tight;
       % set(gca, 'LooseInset', get(gca,'TightInset'))
    end
    A = getFrame(hFig);
    outputVideo(:,:,:,i2) = A.cdata;
    writeVideo(writerObj,A.cdata);
    
end

close(writerObj);