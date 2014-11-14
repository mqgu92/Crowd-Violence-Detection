function redraw(frame, vidObj,WindowSkip,Descriptors)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

%global ViewFigure;
global PlotFigure;
% Read frame
f3 = vidObj.read(frame);
%figure(ViewFigure);
imshow(f3);

hold on
 
if mod(frame,WindowSkip) == 0
    %Update the plot
    disp(1:frame/WindowSkip);
    
    plot(PlotFigure,1:frame/WindowSkip,Descriptors(1:frame/WindowSkip,2));
    %axis fill;
 end
 
hold off



end