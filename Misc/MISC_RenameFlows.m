function MISC_RenameFlows( LowerDir )

    % Get all Sub-Directories
    d = dir(LowerDir);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';


    nameFolds(ismember(nameFolds,{'.','..'})) = [];
    
    for i = 1: length(nameFolds)
     %Perform MISC_RenameFlows
     subDir = strcat(LowerDir,'/',nameFolds{i});
        MISC_RenameFlows(subDir);
    end
       
    %Get all mat files
    m = dir(strcat(LowerDir,'\*.mat'));
    for i = 1 : length(m)
    %Extract number in name
    [PATHSTR,NAME,EXT] = fileparts( strcat(LowerDir,'/',m(i).name));
    s = regexp(NAME, '[-.]', 'split');
   
    if isnumeric(s{2})
        num = MISC_Padzeros(s{2},8);
    else
        num = MISC_Padzeros((sscanf(s{1},'Image_%f',[2,inf])),8);
    end
    num = MISC_Padzeros(s{2},8);
    newName = strcat(PATHSTR,'\',s{1},'-',num2str(num),'-to-',num2str(num),EXT);
    oldName = strcat(PATHSTR,'\',NAME,EXT);
    if ~exist(newName,'file')
    movefile(oldName,newName);
    end

    end
end

