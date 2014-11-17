function [ GLCMPartitionCollection ] = GLCME_ComputeGLCM( IMAGE, GRID, OFFSETS,LEVELS)
%   Given an Input Image and a Division Grid, Calulate the GLCM Matrix
%
%
%
M = GRID(1); N = GRID(2);
RANGE = 1;
GLCMOUT = cell(M,N);

Image = IMAGE;
ISize = size(Image);
GLCMPartitionCollection = cell(M,N,length(OFFSETS));

            MinValue = min(IMAGE(:)); MaxValue = max(IMAGE(:));
            NL = LEVELS;
            IMAGE = round((IMAGE - MinValue ) * (NL ) / (MaxValue - MinValue));
            IMAGE(IMAGE > NL) = NL;
            IMAGE(IMAGE < 1) = 1;  
            
for g = 1: length(OFFSETS)
    % Each Offset value has it's own GLCM Matrix
    OFFSET = OFFSETS(g,:);
    
    GLCMData = cell(1,prod(GRID));
    
    for x = 1: N
        for y = 1: M
            
            
            [ XRange,YRange ] = MISC_SplitMatInd( Image,M,N,y,x );

            if OFFSET(1) >= 0
                if XRange(end) + RANGE * OFFSET(1) < ISize(2)
                    XRange = [XRange,XRange(end) + 1:XRange(end) + RANGE * OFFSET(1)];
                end
            else
                if XRange(1) + RANGE * OFFSET(1) > 0
                    XRange = [XRange(1) - RANGE:XRange(1) - 1,XRange];
                end
                
            end
            
            if OFFSET(2) >= 0
                if YRange(end) + RANGE * OFFSET(2) < ISize(1)
                    YRange = [YRange,YRange(end) + 1:YRange(end) + RANGE * OFFSET(2)];
                end
            else
                if YRange(1) + RANGE * OFFSET(2) > 0
                    YRange = [YRange(1) - RANGE*OFFSET(2) :YRange(1) - 1,YRange];
                end
            end
            I = IMAGE(YRange,XRange);
            
            % Scale Image Intensities

%             if MaxValue == MinValue
%                 SI = ones(size(I));
%             else
%                 slope = NL / (GL(2) - GL(1));
%                 intercept = 1 - (slope*(GL(1)));
%                 SI = floor(imlincomb(slope,I,intercept,'double'));
%             end
%             SI(SI > NL) = NL;
%             SI(SI < 1) = 1;
%             

%             % Compute GLCM

 
            GLCM_MEX = GLCMCPP(I - 1, LEVELS,OFFSET(1),OFFSET(2));
            GLCMData = GLCM_MEX;
            
            GLCMPartitionCollection{y,x,g} = GLCMData;
            
        end
    end
    
    
end



end

