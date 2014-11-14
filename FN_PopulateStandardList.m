function [ VideoList ] = FN_PopulateStandardList( BASEDIRSTR,FOLDS )
%Provide the base folder that contains sub folders for different classes of
%video data.

%Video List Format
% Class, Dir, Name, ext, MiscData

VideoList = {};

%BASEDIRSTR = 'C:\Users\kaelon\Documents\Code Submission\Crowd-Activity';


BaseDir = dir(BASEDIRSTR);
isSub = [BaseDir(:).isdir];
BaseDir = BaseDir(isSub);
BaseDir = BaseDir(~ismember({BaseDir(:).name},{'.','..'}));

ClassList = {BaseDir(:).name};

for i = 1 : length(ClassList)
    SubDirStr = fullfile(BASEDIRSTR,ClassList{i});
    SubDir = [dir(fullfile(SubDirStr,'*.mov'));...
        dir(fullfile(SubDirStr,'*.avi'));...
        dir(fullfile(SubDirStr,'*.mpg'))];
    SubDir = SubDir(~[SubDir(:).isdir]);

    
    for j = 1: length(SubDir)
        [PATHSTR,NAME,EXT] = fileparts(fullfile(SubDirStr,SubDir(j).name));

        VideoList = [VideoList;{ClassList{i},PATHSTR,NAME,EXT, mod(j,FOLDS) + 1}];
    end
end

if isempty(VideoList)
    disp('Something has gone awry!');
end


end

