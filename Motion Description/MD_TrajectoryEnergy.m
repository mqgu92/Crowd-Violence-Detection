function [ ENERGY ] = MD_TrajectoryEnergy( TRAJECTORY )
%MD_TRAJECTORYENERGY Summary of this function goes here
%
%   Using a trajectory path determine the energy it holds
%   
%   Absolute Difference between adjacent pairs
%   Diff(X) + Diff(Y)
%%
%ENERGY = sum(abs(diff(TRAJECTORY(:,1)))) + sum(abs(diff(TRAJECTORY(:,2))));
ENERGY = sum(sum(abs(diff(TRAJECTORY,1,1))));

end

