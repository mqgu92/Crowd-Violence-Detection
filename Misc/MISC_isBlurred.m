function [ ISBLURRED, METRIC ] = MISC_isBlurred( IMG, THRESHOLD )

% Edge Convolution
%fil = [0,1,0;1,-4,1;0,1,0];
fil = fspecial('laplacian');
METRIC = mean2(conv2(double(rgb2gray(IMG)),fil).^2);

if METRIC <  THRESHOLD
    ISBLURRED = true;
else
    ISBLURRED = false;
end

end

