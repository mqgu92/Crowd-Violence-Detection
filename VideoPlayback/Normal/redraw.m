function redraw(frame, vidObj)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f3 = vidObj.read(frame);

imshow(f3);% axis image off
 hold on
 %plot(1:frame,Descriptors(1:frame,1));
hold off
%nn = sprintf('%6.6d',frame);
%B = imresize(frameInfo.cdata, [369,560]);
%imwrite(B,strcat('G:\VideoOut\VidWood15-se\',num2str(nn),'.png'));

end