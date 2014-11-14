function [ VideoList ] = FN_PopulateVTTList( BASEDIRSTR )

%FN_POPULATEVTTLIST A VTT list is a series of videos that have been split
%into three folders, Validation, Testing and Training; inside each of these
%are the classes and their respective samples

%Video List Format
% Class, Dir, Name, ext, MiscData

VideoList = {};

BaseDir = dir(BASEDIRSTR);
isSub = [BaseDir(:).isdir];
BaseDir = BaseDir(isSub);
BaseDir = BaseDir(ismember({BaseDir(:).name},{'Validation','Testing','Training' }));

if length(BaseDir) ~= 3
    disp('Training,Testing,Validation folders are missing, check spelling');
end

for f = 1 : 3
    
    CurrentSet = BaseDir(f).name;
    
    SetDirectory = dir(fullfile(BASEDIRSTR,CurrentSet));
    isSub = [SetDirectory(:).isdir];
    SetDirectory = SetDirectory(isSub);
    SetDirectory = SetDirectory(~ismember({SetDirectory(:).name},{'.','..'}));

    ClassList = {SetDirectory(:).name};
    
    for i = 1 : length(ClassList)
        SubDirStr = fullfile(BASEDIRSTR,CurrentSet,ClassList{i});
        SubDir = [dir(fullfile(SubDirStr,'*.mov'));...
            dir(fullfile(SubDirStr,'*.avi'));...
            dir(fullfile(SubDirStr,'*.mpg'))];
        SubDir = SubDir(~[SubDir(:).isdir]);
        
        
        for j = 1: length(SubDir)
            [PATHSTR,NAME,EXT] = fileparts(fullfile(SubDirStr,SubDir(j).name));
            
            VideoList = [VideoList;{ClassList{i},PATHSTR,NAME,EXT,CurrentSet}];
        end
    end
    
end

if isempty(VideoList)
    disp('Something has gone awry!');
end


end

