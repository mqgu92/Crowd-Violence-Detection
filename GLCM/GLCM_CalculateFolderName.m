function [ FolderExtension ] = GLCM_CalculateFolderName( BASEOFFSET,LEVELS,IMRESIZE,~,~,SYMMETRY)
%   THIS IS OBSOLETE, C++ GLCM is faster than loading lots of .MAT files
%   ***********************************************************************
%   When saving or loading GLCM files you need to generate the folder name
%   using the parameters that generated the Co-Occurance Matrix
%


FolderExtension = ['o',sprintf('%d',reshape(BASEOFFSET,1,numel(BASEOFFSET))),...
        'l',sprintf('%d',LEVELS),...
        'i',num2str(IMRESIZE),...
        's',sprintf('%d',SYMMETRY)];
    FolderExtension(FolderExtension == ' ') = '';
    FolderExtension(FolderExtension == '.') = '_';

   
% ALTERNATE FORM
% FolderExtension = ['o',sprintf('%d',reshape(BASEOFFSET,1,numel(BASEOFFSET))),...
%         'l',sprintf('%d',LEVELS),...
%         'p',num2str(reshape(PYRAMID,1,numel(PYRAMID))),... 
%         'r',num2str(RANGE),...
%         'i',num2str(IMRESIZE),...
%         's',sprintf('%d',SYMMETRY)];
%     FolderExtension(FolderExtension == ' ') = '';
%     FolderExtension(FolderExtension == '.') = '_';

    
end

