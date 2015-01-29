function result=read_image_sequence(name_prefix, format, i1, i2, colorflag, ffmpegflag)

%
%  read_mage_sequence(name_prefix, format, i1, i2, colorflag, ffmpegflag)
% 
%      reads images from a sequence, converts their values to 
%      (double)grey and returns a 3D x-y-t image array.
%      Names of image frames shall start with 'name_prefix'
%      followed by numbers from 'i1' to 'i2'.
%      Supported formats are 'avi', 'mpg', 'tif', 'jpg'.
%

if nargin<5 colorflag=0; end
if nargin<6 ffmpegflag=0; end

if strcmp(format,'avi') | strcmp(format,'mpg') | strcmp(format,'')
  if strcmp(format,'') fname=name_prefix;
  else fname=[name_prefix '.' format];
  end

  if strcmp(format,'avi')
    finfo=aviinfo(fname);
    if nargin<4 i1=1; i2=finfo.NumFrames; end
    if i1<0 i1=1; end, if i1>finfo.NumFrames i1=finfo.NumFrames; end
    if i2<0 i2=1; end, if i2>finfo.NumFrames i2=finfo.NumFrames; end
  end

  if ffmpegflag
    m=readvideo(fname,i1:i2,'override');
    if colorflag
      result=zeros([size(m{1}) length(m)]);
      for i=1:length(m)
        result(:,:,:,i)=double(m{i});
      end
    else
      result=zeros([size(m{1},1) size(m{1},2) length(m)]);
      for i=1:length(m)
        result(:,:,i)=il_rgb2gray(double(m{i}));
      end
    end
  else
    vidObj = VideoReader(fname);
    numFrames = get(vidObj, 'NumberOfFrames');
    
    if ~colorflag
      f0=rgb2gray(read(vidObj,1));
    else
      f0=double(read(vidObj,1));
    end
     result=zeros([size(f0),numFrames]);
    

    for i=1:numFrames
      if ~colorflag
        result(:,:,i)=  rgb2gray(read(vidObj,i));
      else
        result(:,:,:,i)= double(read(vidObj,i));
      end
    end
    
  end
else
  for i=i1:i2
    if strcmp(format,'tif')
      fname=sprintf('%s%03d.tif',name_prefix,i);
      img=double(imread(fname,'tiff'));
    elseif strcmp(format,'jpg')
      fname=sprintf('%s%03d.jpg',name_prefix,i);
      img=double(imread(fname,'jpg'));
    elseif strcmp(format,'png')
      fname=sprintf('%s%03d.png',name_prefix,i);
      img=double(imread(fname,'png'));
    else
      fprintf('The format is not recognized: %s\n',format)
      break
    end
    
    % reduce to grey if RGB
    if ndims(img)==3
      img=(img(:,:,1)+img(:,:,2)+img(:,:,3))/3;
    end
    
    [sy,sx]=size(img);  
    
    if i==i1
      result=zeros(sy,sx,i2-i1);
    end
    
    result(:,:,i)=img;
  end
end
