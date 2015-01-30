function ME_BatchExtractOpticalFlow( MAINDIR )
%%
%
%   READ CSV file
%
%%

%Extract directories in main dir
%dirInfo = dir(MAINDIR);
%isub = [dirInfo(:).isdir]; %# returns logical vector
%nameFolds = {dirInfo(isub).name}';
%nameFolds(ismember(nameFolds,{'.','..'})) = [];

Violence = MISC_readcvs('Violence.csv',',');
Violence = Violence(2:end,:);
NonViolence = MISC_readcvs('NonViolence.csv',',');
NonViolence = NonViolence(2:end,:);

Extract = [NonViolence];

for i = 1 : length(Extract)

    Class = strcat(Extract{i,1},'__');
    vid = strcat(Extract{i,2},'__');
    User = strcat(Extract{i,3},'__');
    VidID = Extract{i,4};
    VidGroup = Extract{i,7};
    VideoName = strcat(Class,vid,User,VidID);
    VideoName = strrep(VideoName, ' ', '_');
    %if length(VideoName) > 80
    %    VideoName = VideoName(1:80);
    %end
    %VName = strcat(VideoName,'.avi');
    Clas = strcat(num2str(VidGroup),'\',Class);
    found = false;
    for k = 10 : length(VideoName)
        VName = VideoName(1:k);
        VName = strcat(VName,'.avi');
        
        if exist(VName, 'file')

            
            bFineScale = 1;
            method = 'flow1full';   %% Tikhonov-regularized and vectorized method
            [dx, dy, dt, U, V] = vidProcessing2D(VName, 'flow1full', bFineScale,[0.2 0],0,Clas);
            found =  true;


            disp(strcat('Video Extracted: ',VideoName));
            
        end
    
    end
    if ~found
        disp(strcat('Not Found: ',VideoName));
    end
    
end
    


end