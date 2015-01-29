P = [1 1; 2 2; 3 3; 4 4];
LEVELS = 5;
RANGE = 12;
MaxEven = [4 4];
MaxOdd = [6 6];
OFFSET = [1 1];
Image = double(imread('circuit.tif'));
ISize = size(Image);

GLCMSplit = cell(4, 4);
%figure,image(Image)
for x = 1: 15
    for y = 1: 15
   
       
        [ XRange,YRange ] = MISC_SplitMatInd( Image,15,15,y,x );
      
              
        
        if OFFSET(1) > 0
            if XRange(end) + RANGE * OFFSET(1) < ISize(2)
                XRange = [XRange,XRange(end) + 1:XRange(end) + RANGE * OFFSET(1)];
            end
        else
            if XRange(1) + RANGE * OFFSET(1) > 0
                XRange = [XRange(1) - RANGE:XRange(1) - 1,XRange];
            end
            
        end
        if OFFSET(2) > 0
            if YRange(end) + RANGE * OFFSET(2) < ISize(1)
                YRange = [YRange,YRange(end) + 1:YRange(end) + RANGE * OFFSET(2)];
            end
        else
            if YRange(1) + RANGE * OFFSET(2) > 0
                YRange = [YRange(1) - RANGE*OFFSET(2) :YRange(1) - 1,YRange];
            end
        end
    I = Image(YRange,XRange);
    %figure,image(I)

    % Mex Method
    GL = [min(Image(:)) max(Image(:))];
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
    GLCMSplit{y,x} = GLCMCPP(SI - 1, LEVELS, RANGE *OFFSET(1), RANGE *OFFSET(2));
    
    end
   
end

I = Image;

    % Mex Method
    GL = [min(Image(:)) max(Image(:))];
    NL = LEVELS;
    if GL(2) == GL(1)
        SI = ones(size());
    else
        slope = NL / (GL(2) - GL(1));
        intercept = 1 - (slope*(GL(1)));
        SI = floor(imlincomb(slope,I,intercept,'double'));
    end
    SI(SI > NL) = NL;
    SI(SI < 1) = 1;
    G2 = GLCMCPP(SI - 1, LEVELS, RANGE *OFFSET(1), RANGE *OFFSET(2));

all = sum(cat(3,GLCMSplit{:}),3);
all = sum(all,3);
qqq = G2 - all