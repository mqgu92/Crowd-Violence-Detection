%% Extract FLOWS2
%
%   Loads a video and extracts all flow information
%   which is then saved to a local FLOWS2/VideoName folder 
%

    videoDir = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet\VideoCutsSmall\';
    VideoName = 'Fight-WoodStreet.avi';    
    
    vidObj = VideoReader(strcat(videoDir,VideoName));
    numFrames = get(vidObj, 'NumberOfFrames');
    
    SIFTflowpara.alpha=2;
    SIFTflowpara.d=40;
    SIFTflowpara.gamma=0.005;
    SIFTflowpara.nlevels=4;
    SIFTflowpara.wsize=5;
    SIFTflowpara.topwsize=20;
    SIFTflowpara.nIterations=60;
    
    patchsize=8;
    gridspacing=1;

    im1 = read(vidObj,1);
    im1 = imfilter(im1,fspecial('gaussian',7,1.),'same','replicate');
    im1=imresize(im1,0.5,'bicubic');
        
    sift1 = dense_sift(im1,patchsize,gridspacing);
    
    for i = 1 : numFrames - 1
         disp(strcat(num2str(i),':',num2str(numFrames)));
        im2 = read(vidObj,i + 1);
        im2 = imfilter(im2,fspecial('gaussian',7,1.),'same','replicate');
        im2=imresize(im2,0.5,'bicubic');

        sift2 = dense_sift(im2,patchsize,gridspacing);

        vx1 = [];
        vy1 = [];

        n1 = num2str(i);
       
        fileName = strcat('FLOWS2/',VideoName,'/Flow-',n1,'-to-',n1);

        if exist(strcat(fileName,'.mat'),'file')
           % load(fileName);
        else
            
        [vx1,vy1,~]=SIFTflowc2f(sift1,sift2,SIFTflowpara);

        if ~exist(strcat('FLOWS2/', VideoName),'dir')
                mkdir(strcat('FLOWS2/', VideoName));
        end
        
        save(fileName,'vx1','vy1');

        end
        
        sift1 = sift2;
    end