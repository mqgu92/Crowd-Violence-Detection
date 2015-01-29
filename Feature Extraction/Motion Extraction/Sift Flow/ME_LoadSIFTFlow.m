function [U,V] = ME_LoadSIFTFlow( FLOWDIR, VIDEONAME, FRAME )
%%
%
%   Using a list of video names, load SIFT FLOW at Frame 'FRAME'
%
%%

    if ~isnumeric(FRAME)
        return;
    end
    
    flowNum = num2str(FRAME);
    fileName = strcat(FLOWDIR,VIDEONAME,'/Flow-',flowNum,'-to-',flowNum);
    load(fileName);
    U = vx1;
    V = vy1;

end

