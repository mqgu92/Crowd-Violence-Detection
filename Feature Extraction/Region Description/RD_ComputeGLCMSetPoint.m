function [ OUTPUT ] = RD_ComputeGLCMSetPoint( VOLUME, OFFSETS,LEVELS )
%   Computes GLCM matrices for each temporal plane in a spatio-temporal
%   volume of video data

% Scale Image
[~,~,T] = size(VOLUME);
[M,~] = size(OFFSETS);
OUTPUT = zeros(LEVELS,LEVELS,T);
for i = 1: T
    current_frame = VOLUME(:,:,i);
    
    GLCM_frame = zeros(LEVELS,LEVELS,M);
    for o = 1: M 
        OFFSET = OFFSETS(o,:);
        GLCM_MEX = GLCMCPP(current_frame, LEVELS,OFFSET(1),OFFSET(2));
        GLCM_frame(:,:,o) = GLCM_MEX;
    end
    OUTPUT(:,:,i) = sum(GLCM_frame,3);
end



