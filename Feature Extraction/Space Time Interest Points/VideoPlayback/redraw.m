function redraw(frame, vidObj,pred)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
f3 = vidObj.read(frame);

% Get edge
%f2 = text(5.5,125,num2str(pred(frame)));

%f2 = frame2im(getframe(f2));

% Overlay edge on original image
%f3 = bsxfun(@plus, f,  uint8(255*f2));

% Display
foffset = 0;
imshow(f3);% axis image off
a = frame - foffset;

 
    string = '';
    
    switch pred(frame)
        case 1
            string = 'Fight';
        case 2
            string = 'NotFight';
    end

 
 %% Get Past 30 frame status
 if frame > 30
 pastThirty = pred(a - 30 : a);
 if sum(ismember(pastThirty,[1])) >= 15
     %if ismember(pred(frame),[11,12])
         
        imshow(f3(:,:,1) + 50 );% axis image off
     %end
 end
 end
  text(30,50,strcat('\fontsize{16}\color{magenta}',string));
 

text(30,20,strcat('\fontsize{16}\color{magenta}',num2str(frame)));

%if ismember(frame,seenData)
%text(30,80,strcat('\fontsize{16}\color{magenta}','SEEN DATA'));
%end


%frameInfo = getframe();

%nn = sprintf('%6.6d',frame);
%B = imresize(frameInfo.cdata, [369,560]);
%imwrite(B,strcat('G:\VideoOut\VidWood15-se\',num2str(nn),'.png'));

end