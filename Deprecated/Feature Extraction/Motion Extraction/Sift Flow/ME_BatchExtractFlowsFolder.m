function ME_BatchExtractFlowsFolder( MAINDIR )
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
    VideoName = strcat(Class,vid,User,VidID);
    VideoName = strrep(VideoName, ' ', '_');
   % if length(VideoName) > 80
   %     VideoName = VideoName(1:80);
   % end
    VidGroup = Extract{i,7};
    Clas = strcat(num2str(VidGroup),'\',Class);
    found = false;   
    for k = 10 : length(VideoName)
        VName = VideoName(1:k);
        VName = strcat(VName,'.avi');

        if exist(VName, 'file')
            ME_ExtractOpticalFlows(VName,Clas,false);
            disp(strcat('Video Extracted: ',VideoName));
            found =  true;
        end

    end
    if ~found
        disp(strcat('Not Found: ',VideoName));
    end
    
end
    


end

