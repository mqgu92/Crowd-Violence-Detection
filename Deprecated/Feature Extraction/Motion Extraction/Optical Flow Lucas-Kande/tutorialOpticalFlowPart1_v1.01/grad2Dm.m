function [Iy, Ix, It] = grad2Dm(imNew,bFineScale,bInitialize)
persistent siz gx gg imPrev; %filters and previous image

% initialize persistent variables, these will remain between calls 
if nargin>2 && bInitialize
    %make the filters gx (for x-derivative) and gg (for smoothing)
    [gx, gg]= makeFilters(); 
    if bFineScale
        %if we will use a fine scale for derivatives, then we set
        %the size to be that of the original video
       siz = size(imNew);
       %imPrev will contain the previous image, we use single precision for
       %faster calculations
       imPrev= single(imNew);
    else% if ~bFineScale
        %if we use a coarse scale, set the size to half of the original:
        siz = floor(size(imNew)/2);
        %initialize imPrev to half the size
        imPrev = imresizeNN(single(imNew),siz);
    end
end

%%% resample image to right resolution, depending on the scale we chose:
if ~bFineScale
    imNew = imresizeNN(conv2(single(imNew),gg,'same'),siz);
else
    imNew = single(imNew);
end

%%%% calculate the derivatives explicitly. We use small filters here, so it
%%%% makes sense to use explicit convolutions. 
%%%% TODO, implement the derivatives by convolutions. Use the conv2 function 
%%%% as it is the fastest
%%%% 
%%%% get "Ix" as convolution using gx, make sure that Ix is the same
%%%% size as the video. Iy is similar, but use "gx'" as filter instead
Ix    = conv2(imNew,gx ,'same'); %L1
Iy    = conv2(imNew,gx','same'); %L2

%%%nex you should estimate "It", the temporal derivative. Do this by the
%%%following steps
%%%   first, we smooth the new image, replacing the original data:
imNew = conv2(imNew,gg ,'same'); 

%%%now, assume that the previous image was smoothed as well. How do we
%%%estimate derivative in time? Use imNew(the new image) and imPrev (the
%%%previous image) in the most simplest possible way to estimate temporal
%%%derivative
It    = imNew - imPrev; %L3

% finally, store away the current image for use on next frame
imPrev = imNew;

%%%% a local helper function  %%%%%
function  [gx, gg]= makeFilters()
    x     = meshgrid(-1:1);
    gg    = single(gaussgen(0.67,3)'*gaussgen(0.67,3));
    gx    = single(-x.*gg*3);

