function [ VOLUME ] = GLCM_Scale_Intenities( VOLUME,NL, HIGH, LOW )
%GLCM_SCALE_INTENITIES GLCM requires that an grey-levels are scaled into NL
% number of intensities; this function cycles through each frame and scales
% it appropriately.

custom = true;
if nargin < 4
    custom = false; % Use frame min/max for scaling
end

[~,~,T] = size(VOLUME);

for i = 1: T
    current_frame = VOLUME(:,:,i);
    
    if ~custom
        low = min(current_frame(:));
        high = max(current_frame(:));
    else
        low = LOW;
        high = HIGH;
    end
    
    if high - low ~= 0
        current_frame = round((current_frame - low ) * (NL ) / (high - low));
    else
        current_frame = (current_frame - low ) * (NL);
    end
    current_frame(current_frame > NL) = NL;
    current_frame(current_frame < 1) = 1;
    
    VOLUME(:,:,i) = current_frame;
end


end

