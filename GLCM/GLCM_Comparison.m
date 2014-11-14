% Compare the number of GLCM matrices that can be computed within a single
% standard second

I = round(rand(320,320) * 256);
I = imread('circuit.tif');
% GLCM Parameters
BASEOFFSET = [-1 1];
SYMMETRY = false;
LEVELS = 8;
RANGE = [1 2];
OFFSET = GLCM_CalculateNeighbourhood(BASEOFFSET, RANGE);

matTotal = 0;
mexTotal = 0;
totalTime = 0;

while true
    if totalTime > 1
        break;
    end
    tic;
    [StandardGLCM, SI]= graycomatrix(I,...
        'Offset',OFFSET,...
        'Symmetric',SYMMETRY,...
        'NumLevels',LEVELS);
    totalTime = totalTime + toc;
    matTotal = matTotal + 1;
end
I = double(imread('circuit.tif'));
totalTime = 0;
totalComplete = 0;
while true
    if totalTime > 1
        break;
    end
    tic;
    % Reshape the Matrix to have a set number of gray levels
    GL = [min(I(:)) max(I(:))];
    NL = LEVELS;
    if GL(2) == GL(1)
        SI = ones(size(I));
    else
        slope = NL / (GL(2) - GL(1));
        intercept = 1 - (slope*(GL(1)));
        SI = floor(imlincomb(slope,I,intercept,'double'));
    end
    SI(SI > NL) = NL;
    SI(SI < 1) = 1;
    
    % Calculate GLCM.

    GLCMPartitionCollection = zeros(LEVELS,...
        LEVELS,...
        length(OFFSET));
    
    for g = 1: length(OFFSET)
        SUBOFFSET = OFFSET(g,:);
        GLCM_MEX = GLCMCPP(SI - 1, LEVELS,SUBOFFSET(1),SUBOFFSET(2));
        GLCMPartitionCollection(:,:,g) = GLCM_MEX;
    end
    totalTime = totalTime + toc;
    mexTotal = mexTotal + 1;
end


disp(['Mex Time:',num2str(mexTotal)]);
disp(['Mat Time:',num2str(matTotal)]);

clear all;