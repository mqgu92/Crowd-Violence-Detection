%% PlayVideo
%
%   Plays a video using videofig and overlays the
%   current sequence class identified by a 'pred'
%   variable that contains the sequence classification for
%   each frame
%


%VideoName = '316 Queen St-20130427-211153Stable';
VideoName = 'o_308 St Mary St-20130504-2109542-FIGHT';
%VideoName = 'o_015 ST MARY ST-20130428-040033Edit';
%VideoName = 'o_o_012 WOOD ST-20130504-210955-Stable-FIGHT';
%VideoName = '316 Queen St-20130427-211153-FIGHT';
VideoName = '308 St Mary St-20121028-000002-FIGHT';
VideoName = '316 Queen St-20130427-211153-FIGHT';
VideoLocation = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VidCutSFormat\';
VideoExt = '.avi';
VideoFile = strcat(VideoLocation,VideoName,VideoExt)

VideoObj = videoReader(VideoFile);
numFrames = get(VideoObj, 'NumberOfFrames');

seenData = 1;
%h =figure;
frm = 1;

videofig(VideoObj.NumberOfFrames, @(frm) redraw(frm, VideoObj,predOut),24);

redraw(1,VideoObj,pred);