function [ FLOWTRAJECTORY ] = MD_FollowSIFTFlowOpt( uFLOWS,vFLOWS )
%%    
%
%   FLOWS = {Umatrix,Vmatrix ; Umatrix,Vmatrix,Umatrix,Vmatrix}
%
%   Returns a Width by Height array containing 2 by temporal window paths
%%
       
        flowDime = size(uFLOWS{1}); 
        flowSize = flowDime(1) * flowDime(2);
        flowCount = length(uFLOWS);        
        FLOWTRAJECTORY = cell(flowDime);

        uuFLOWS =  zeros(flowDime(1),flowDime(2),flowCount);
        vvFLOWS =  zeros(flowDime(1),flowDime(2),flowCount);
        
        for i = 1 : flowCount
            uuFLOWS(:,:,i) = uFLOWS{i};
            vvFLOWS(:,:,i) = vFLOWS{i};
        end
        
         for y = 1 : flowDime(1)
            for x = 1: flowDime(2)
                %[y,x] = ind2sub(flowDime,i);
                XYTemp = zeros(flowCount,2);
                varx = x;
                vary = y;
                for j = 1 : flowCount
                    % Read Next Flow, Determine X, Y movements
 
                    
                    nx = uuFLOWS(y,x,j);
                    ny = vvFLOWS(y,x,j);
                    
                    varx = varx + nx;
                    vary = vary + ny;
                    
                    
                    %% Boundary Conditions, We use a 32 window
                    if varx < 1 + 32
                        varx = 1 + 32;
                    end
                    if vary < 1 + 32
                        vary = 1 + 32;
                    end
                    if varx > flowDime(2) - 32
                        varx = flowDime(2) - 32;
                    end
                    if vary > flowDime(1) - 32 
                        vary = flowDime(1) - 32;
                    end
                    
                    %% Assignment
                    XYTemp(j,1) = varx;
                    XYTemp(j,2) = vary;
                end 
            FLOWTRAJECTORY{y,x} = XYTemp;
            end
         end
        
        
        
        %XYTotal = reshape(XYTotal,1,prod(size(XYTotal)));
        
    
end

