function newIm = generateFrame(vid, t,kindOfMovie,spdFactor,arrowKey)
persistent iix iiy k prevT rotAn P0 inertia;
if nargin<4
    spdFactor = [1,0];end
if nargin<5
    arrowKey = [0,0];end


if strcmp(kindOfMovie,'file') 
    %get frame at t in video file, where t is "bouncing" forward and
    %backward (thus, video is played for infinity, by playing itself backwards half of the time)
    t=varyT(round(t),vid.NumberOfFrames);
    newIm = rgb2gray(read(vid, t));
elseif strcmpi(kindOfMovie,'synthetic')  % generate test image:
    
    spd    = 1/150; %constant factor to speed of motion of the patterns generated

    cen1   = 0.4;          %centre ofsets of circles
    cW     = 0.3;          %radius of circles
    cFuz   = 1;           %fuzziness of the boundary
    cDetail= 0.6;          %detail of the interior pattern(frequency of sinusoids)

    if t==1 || isempty(iix)
        [iix,iiy] = meshgrid(linspace(-1,1,vid.Height));
        k = t; %local time;
        prevT = t-1;
        rotAn = 0;
        P0         = [0,0];
        inertia  = [0,0];
    end
    
    k     = k     + (t-prevT)*spdFactor(1)*spd; %local time
    rotAn = rotAn + (t-prevT)*spdFactor(2)*spd;%rotation angle update
	prevT = t;

	arrowKeySpd = 0.0029;
	inertia = (inertia-0.00012*sign(inertia))*0.988  + arrowKey*arrowKeySpd;
    totInertia = sqrt(sum(inertia.^2));
    maxInertia = 0.045;
    if totInertia > maxInertia
        inertia = maxInertia*inertia/totInertia;
    end

    P0 = P0 + inertia;
   
    
     PtX = 0.36*sin(pi*(k+0.5)*2)/2 + P0(1); %"figure eight" path in x and y, 
     PtY =-0.36*cos(pi*(k+0.5)  )   + P0(2); %as function of local time
    
     
     
     %rotation and translation, composite transform:
     iX = cos(rotAn)*(iix+PtX) + sin(rotAn)*(iiy+PtY);
     iY = sin(rotAn)*(iix+PtX) - cos(rotAn)*(iiy+PtY);
    
%      generate the textured disks:
   newIm = uint8(... 
     250*                                                        sig(cW^2-(iX-cen1).^2-(iY-cen1).^2, cFuz*cW/50)+... disk blank          
     128*(1+                             cos(iX*cDetail*20*pi)).*sig(cW^2-(iX-cen1).^2-(iY+cen1).^2, cFuz*cW/50)+... disk vertical lines
     128*(1+cos(iY*cDetail*20*pi)                             ).*sig(cW^2-(iX+cen1).^2-(iY-cen1).^2, cFuz*cW/50)+... disk horizontal lines
     185*(0.4+cos(2+iY*cDetail*16*pi).*cos(2+iX*cDetail*16*pi)).*sig(cW^2-(iX+cen1).^2-(iY+cen1).^2, cFuz*cW/50));  %disk checkerboard
     
else %if strcmpi(kindOfMovie,'camera')  % capture from camera:
    if vid.bUseCam==2 %videoinput lib:
        vi_is_frame_new(vid.camIn, vid.camID-1);
        newIm  = vi_get_pixelsProper(vid.camIn, vid.camID-1,vid.Height,vid.Width);
    else %image aqcuisition toolbox:
        newIm = flipdim(squeeze(getsnapshot(vid.camIn)),2);
    end
end
