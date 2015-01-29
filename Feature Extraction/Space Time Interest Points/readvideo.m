function im_array = readvideo(filename,frames,override);
%READVIDEO  read video file
%  IM_ARRAY = READVIDEO(FILENAME, FRAMES) reads a video FILENAME into 
%  the cell array IM_ARRAY.  The Ith element of IM_ARRAY{I} will then 
%  contain the rgb image corresponding to the Ith frame of the video.  
%
%  FRAMES should be vector of frames to be read. Note sequences of 
%  continuous frame are read more quickly than isolated frames.
%
%  The code reads the video frames as 24-bit RGB images and uses the 
%  FFMPEG libraries libavformat and libavcodec to decode the video, see 
%  http://ffmpeg.sourceforge.net/ for more information and supported 
%  formats.
%
%  IM_ARRAY = READVIDEO(FILENAME, FRAMES, 'override') to load more than 100
%  frames at once.  Loading too many frames uses a lot of memory and can
%  hang your computer so use override with care.  You can change the
%  number of frames loadable before requiring 'override' by changing the 
%  max_limit variable in readvideo.m.
% 
%
%  Video frame numbers are indexed from 0 whereas the cell array
%  is indexed from 1.
%
%  E.g.  To read in frames 1-5 and 22 from a vob file, and view the 
%        ith frame:
%
%  im_array = readvideo('E:\Sequences\Wimbledon80\vts_01_2.vob',[1:5,22]);
%  imagesc(im_array{i});
% 
%
%  Gareth Loy & Josephine Sullivan, KTH, Stockholm, 2004.

% maximum number of frames that can be loaded at once without the override
% option:
max_limit = 100;

% check if file exists (readvideo_mex may seg fault if the file doesn't exist)
fid = fopen(filename, 'r');
if (fid == -1)
    error(sprintf('Can''t open file "%s" for reading;\n it may not exist, or you may not have read permission.', ...
        filename));
else
    fclose(fid);
end

if (nargin < 3) & (length(frames)>max_limit)
    error(sprintf('You have asked to load %g frames.  \nTo load more than %g frames you must use the override option.  \nSee help readvideo.', ...
        length(frames), max_limit));
end

%im_array = ReadVideo(filename,frames);
im_array = readvideo_mex(filename,frames);
