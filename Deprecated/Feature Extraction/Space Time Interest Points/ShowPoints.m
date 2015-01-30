VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VidCutSFormat\';

VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\';
VIDNAME = 'fi66_xvid';
VIDEXT = 'avi';
FOLDER = 'HOCKEY2';


[pos1,val1,dscr1]=readstips_text([FOLDER,'\',VIDNAME,'-STIP.txt']);
f1=read_image_sequence(strcat(VIDDIR,VIDNAME),VIDEXT,0,0,0,0);
showcirclefeatures_xyt(f1,pos1);


vidObj = videoReader(strcat(VIDDIR,VIDNAME,'.',VIDEXT));
i = vidObj.NumberOfFrames;
ImageBase = read(vidObj,1);

I = zeros([size(rgb2gray(ImageBase)),i]);
for q = 1 : i
    I(:,:,q) = rgb2gray(read(vidObj,q));
end