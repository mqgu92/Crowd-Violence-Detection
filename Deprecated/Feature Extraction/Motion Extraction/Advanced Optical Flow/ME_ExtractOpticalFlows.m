function ME_ExtractOpticalFlows( VIDEODIR,CLASS,RESIZE )
    
    [a,b,c] = fileparts(VIDEODIR);
    VideoName = b;

    vidObj = VideoReader(VIDEODIR);
    numFrames = get(vidObj, 'NumberOfFrames');
    
    % set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
    alpha = 0.012;
    ratio = 0.75;
    minWidth = 20;
    nOuterFPIterations = 7;
    nInnerFPIterations = 1;
    nSORIterations = 30;

    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
    
    im1 = read(vidObj,1);
    im1 = imfilter(im1,fspecial('gaussian',7,1.),'same','replicate');
    if RESIZE
        im1=imresize(im1,0.5,'bicubic');
    end
    
    for i = 1 : numFrames - 1
         disp(strcat(num2str(i),':',num2str(numFrames)));
        im2 = read(vidObj,i + 1);
        im2 = imfilter(im2,fspecial('gaussian',7,1.),'same','replicate');
        
        if RESIZE
            im2=imresize(im2,0.5,'bicubic');
        end
        

        n1 = MISC_Padzeros(i,8);
       
        fileName = strcat('OPTICALVIFFLOWSNotFight/',CLASS,'/',VideoName,'/Flow-',n1,'-to-',n1);

        if exist(strcat(fileName,'.mat'),'file')
           % load(fileName);
        else
            
        [vx1,vy1,~] = Coarse2FineTwoFrames(im1,im2,para);

        if ~exist(strcat('OPTICALVIFFLOWSNotFight/',CLASS),'dir')
                mkdir(strcat('OPTICALVIFFLOWSNotFight/',CLASS));
        end
        
        if ~exist(strcat('OPTICALVIFFLOWSNotFight/',CLASS,'/', VideoName),'dir')
                mkdir(strcat('OPTICALVIFFLOWSNotFight/',CLASS,'/', VideoName));
        end
        
        save(fileName,'vx1','vy1');

        end
        
        im1 = im2;
        
    end
end

