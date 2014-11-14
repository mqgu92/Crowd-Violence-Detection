function [ OUTPUT ] = MD_TrajectoryShape( INPUTX, INPUTY, NORMALIZE )

%% MD_MovementPath
%   Calculates a vector from co-ordinates that describes
%   the motion path between frames.
%   Normalized by the sum of displacment maginitudes

% Time Frame
t = length(INPUTX);

% Calculate the X/Y movement between two points
diffSeries = zeros(t - 1,2);


diffSeries(:,1) =  diff(INPUTX);
diffSeries(:,2) =  diff(INPUTY);

if ~NORMALIZE    
    %%Calculate displacement
    xDisplacement = sum(diffSeries(:,1)); 
        if xDisplacement == 0, xDisplacement = 1;end
    yDisplacement = sum(diffSeries(:,2)); 
        if yDisplacement == 0, yDisplacement = 1;end


    %% Normalize each point by displacment
    T = zeros(t - 1,2);
    T(:,1) = diffSeries(:,1)./xDisplacement; 
    T(:,2) = diffSeries(:,2)./yDisplacement;
    T = T(1:end,:);

    OUTPUT = T(1:end,:);
else
    %% Don't Normalize
    T = zeros(t - 1,2);
    T(:,1) = diffSeries(:,1); 
    T(:,2) = diffSeries(:,2);
    OUTPUT = T(1:end,:);
    
end
end

