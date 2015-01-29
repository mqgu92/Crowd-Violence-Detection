function [ FLOWTRAJECTORY ] = MD_FollowSIFTFlow( FLOWS )
%%    
%
%   FLOWS = {Umatrix,Vmatrix ; Umatrix,Vmatrix,Umatrix,Vmatrix}
%
%   Returns a Width by Height array containing 2 by temporal window paths
%%
        flowSize = size(FLOWS{1,1}); 
        flowCount = length(FLOWS);        
        FLOWTRAJECTORY = cell(flowSize);

        for y = 1 : flowSize(1)
            for x = 1: flowSize(2)
                XYTemp = zeros(flowCount,2);
                varx = x;
                vary = y;
                for i = 1 : flowCount
                    % Read Next Flow, Determine X, Y movements
                    fx = FLOWS{i,1};
                    fy = FLOWS{i,2};
                    
                    nx = fx(y,x);
                    ny = fy(y,x);
                    
                    varx = varx + nx;
                    vary = vary + ny;
                    
                    
                    %% Boundary Conditions, We use a 32 window
                    if varx < 1 + 32
                        varx = 1 + 32;
                    end
                    if vary < 1 + 32
                        vary = 1 + 32;
                    end
                    if varx > flowSize(2) - 32
                        varx = flowSize(2) - 32;
                    end
                    if vary > flowSize(1) - 32 
                        vary = flowSize(1) - 32;
                    end
                    
                    %% Assignment
                    XYTemp(i,1) = varx;
                    XYTemp(i,2) = vary;
                end
                
                FLOWTRAJECTORY{y,x} = XYTemp;
            end
        end
        
        
        %XYTotal = reshape(XYTotal,1,prod(size(XYTotal)));
        
    
end

