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
          
splitgrid = [8 8];
        
        if ~bFineScale
            U1 = imresizeNN(U1,size(curIm));
            V1 = imresizeNN(V1,size(curIm));
        end
         USplit = MISC_splitMat(U1,splitgrid(1),...
                     splitgrid(2));
         VSplit = MISC_splitMat(V1,splitgrid(1),...
             splitgrid(2));
         
         UPhase = zeros(splitgrid(1),splitgrid(2));
         VPhase = zeros(splitgrid(1),splitgrid(2));
         
         EntireRotMap = atan2(V1,U1);
         EntireRotMap = mod(round((EntireRotMap .* 8) ./2*pi),8);
         
         for i = 1 : prod(splitgrid)
             UPhase(i) = mean(mean(USplit{i}));
             VPhase(i) = mean(mean(VSplit{i}));
         end
         
         MagMap = sqrt(UPhase.^2 + VPhase.^2);
         MagMap = MagMap/norm(MagMap);
         
         RPhase = zeros(splitgrid(1),splitgrid(2));
         EntireRotMap = atan2(V1,U1);
         EntireRotMap = mod(round((EntireRotMap .* 8) ./2*pi),8);
         RSplit = MISC_splitMat(EntireRotMap,splitgrid(1),...
            splitgrid(2));

         for i = 1 : prod(splitgrid)
             RPhase(i) = round(mean(mean(RSplit{i})));
         end
         
         
         groups = [];
         magthresh = 0.5;
         rotthresh = 1;
         neighborhood = [1 0; -1 0;0 1;0 -1];
         for i = 1: prod(splitgrid)
             [X,Y] = ind2sub(splitgrid,i);
             for n = 1: length(neighborhood)
                 Y2 = Y + neighborhood(n,1);
                 X2 = X + neighborhood(n,2);
                 
%                  if Y2 > 1 && Y2(1) < splitgrid(1) && ...
%                     X2 > 1 && X2 < splitgrid(2)
%                      if (MagMap(Y,X) > MagMap(Y2,X2) - magthresh ...
%                         && MagMap(Y,X) < MagMap(Y2,X2) + magthresh)
%                         groups = [groups;[X Y X2 Y2]];
%                      end
%                  end
                %Rotation Based Check
                 if Y2 > 1 && Y2(1) < splitgrid(1) && ...
                    X2 > 1 && X2 < splitgrid(2)
                     if (RPhase(Y,X) > RPhase(Y2,X2) - rotthresh ...
                        && RPhase(Y,X) < RPhase(Y2,X2) + rotthresh)
                        groups = [groups;[X Y X2 Y2]];
                     end
                 end
             end
         end
         
         groupscopy = groups;
         %Remove Mirrors
%           for i = 1: length(groups)
%               v = groups(i,[1 2]);
%               if groups(i,[4 3]) == v
%                  groups(i,:) = [-1 -1 -1 -1];
%               end
%           end
%           groups(groups(:,1) == -1,:) =[];
          
         for i = 1:length(groups)
            groups(i,1) = sub2ind(splitgrid,groups(i,1),groups(i,2));
            groups(i,2) = sub2ind(splitgrid,groups(i,3),groups(i,4));
         end
         
         assigned = [];
         
          groups = groups(:,[1 2]);
          groups = unique(groups,'rows');
         
        List =  groups;
        Groups = {};
        
        % Connect Paths
        while true
            if isempty(List)
                break;
            end
            Current = List(1,:);
            
            [ OUT ] = IterativePath( List, Current );
            out_PairsSize = size(OUT);
            % ONly add to group if a group exists
            if out_PairsSize(1) > 1
               Groups = [Groups;OUT]; 
               disp('Groups Exists');
            end
            
            %Remove Values that are now grouped

            for o = 1: out_PairsSize(1)
                List(ismember(List,OUT(o,:),'rows'),:) = [];
            end
        end
        
        
        
        colours = 1:-0.1:0;
       % colours = colours * 255;
        ImageSize = size(curIm);
        colIm = zeros(ImageSize(1),ImageSize(2),3);
        disp('Drawing Groups');
                    disp(num2str(length(Groups)));
        for i = 1:length(Groups)

            for s = 1 : length(Groups{i})
                GroupItem = Groups{i};
                [X,Y] = ind2sub(splitgrid,GroupItem(s,1));
                SegmentSize = size(cell2mat(USplit(Y,X)));
            colIm( ((X-1)* SegmentSize(1)) + 1 : ((X-1) * SegmentSize(1)) + SegmentSize(1),...
                ((Y-1) * SegmentSize(2) + 1): ((Y-1) * SegmentSize(2)) + SegmentSize(2) ,1) = colours(i);
            %            colIm( ((X-1)* SegmentSize(1)) + 1 : ((X-1) * SegmentSize(1)) + SegmentSize(1),...
            %    ((Y-1) * SegmentSize(2) + 1): ((Y-1) * SegmentSize(2)) + SegmentSize(2) ,2) = colours(i,2);
            %            colIm( ((X-1)* SegmentSize(1)) + 1 : ((X-1) * SegmentSize(1)) + SegmentSize(1),...
            %    ((Y-1) * SegmentSize(2) + 1): ((Y-1) * SegmentSize(2)) + SegmentSize(2) ,3) = colours(i,3);
            [X,Y] = ind2sub(splitgrid,GroupItem(s,2));
                SegmentSize = size(cell2mat(USplit(Y,X)));
            colIm( ((X-1)* SegmentSize(1)) + 1 : ((X-1) * SegmentSize(1)) + SegmentSize(1),...
                ((Y-1) * SegmentSize(2) + 1): ((Y-1) * SegmentSize(2)) + SegmentSize(2) ,1) = colours(i);               
            end
        end

        
%         TempImage = zeros(ImageSize(1),ImageSize(2),3);
%         TempImage(:,:,1) = curIm/255;
%         TempImage(:,:,2) = curIm/255;
%         TempImage(:,:,3) = curIm/255;
%         Final = (colIm(:,:,1) *0.25) + TempImage(:,:,1) ;
%         Final = (colIm(:,:,2) *0.25) + TempImage(:,:,2) ;
%         Final = (colIm(:,:,3) *0.25) + TempImage(:,:,3) ;
%         Split Frame into pieces and highlight differently

%         colIm(:,:,1) = (atan2(V1,U1)+ pi+0.000001)/(2*pi+0.00001);
         colIm(:,:,2) = min(1,0.7*sqrt(U1.^2 + V1.^2));
        colIm(:,:,3) = max(colIm(:,:,1),double(curIm)/256);
        set(hImObj ,'cdata',colIm);
    case 'gridsegmentation'      
        
        %% Segment Group
        
      
        colIm(:,:,1) = (atan2(V1,U1)+ pi+0.000001)/(2*pi+0.00001);
        colIm(:,:,2) = min(1,0.7*sqrt(U1.^2 + V1.^2));
        colIm(:,:,3) = max(colIm(:,:,2),double(curIm)/256);
        set(hImObj ,'cdata',hsv2rgb(colIm));
    otherwise %flow methods
        set(hImObj ,'cdata',curIm);
        set(hQvObjLines ,'UData', sc*U1, 'VData', sc*V1);
end
