% Update the graphics, depending on the "method" used
switch method
    case 'edge'
        set(hImObj ,'cdata',curIm);
        set(hImObjEdge ,'cdata',edgeIm);
    case 'gradient'
        set(hImObjDx,'cdata',dx);
        set(hImObjDy,'cdata',dy);
        set(hImObjDt,'cdata',dt);
        set(hImObj  ,'cdata',curIm);
    case 'flow1full'       
        if ~bFineScale
            U1 = imresizeNN(U1,size(curIm));
            V1 = imresizeNN(V1,size(curIm));
        end
        colIm(:,:,1) = (atan2(V1,U1)+ pi+0.000001)/(2*pi+0.00001);
        colIm(:,:,2) = min(1,0.7*sqrt(U1.^2 + V1.^2));
        colIm(:,:,3) = max(colIm(:,:,2),double(curIm)/256);
        set(hImObj ,'cdata',hsv2rgb(colIm));
    otherwise %flow methods
        set(hImObj ,'cdata',curIm);
        set(hQvObjLines ,'UData', sc*U1, 'VData', sc*V1);
end
