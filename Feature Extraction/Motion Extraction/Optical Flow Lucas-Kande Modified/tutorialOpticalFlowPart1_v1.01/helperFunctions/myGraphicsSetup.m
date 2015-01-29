function [hImObj,hQvObjLines] =  myGraphicsSetup(vid,kindOfMovie,flowRes)

    imSize = vid.Height;
    figure('NumberTitle','off');
    curIm = generateFrame(vid, 1,kindOfMovie);
    hImObj   = imagesc( curIm,[0,250]);
    colormap gray;axis off;axis manual;axis image;
    hold on;
    axisInterval = linspace(1,imSize,flowRes+2);
    axisInterval = axisInterval(2:end-1) ;

    hQvObjLines = quiver(axisInterval,axisInterval, zeros(flowRes),  zeros(flowRes),0 ,'m','MaxHeadSize',5,'Color',[.9 .2 .1]);%, 'LineWidth', 1);
    axis image;