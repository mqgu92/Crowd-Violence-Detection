function [ FLOWDIR ] = TEST_SetupTrajFlows( FLOWTYPE )

SIFTPATH = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet\SIFTFlows\';
OFPATH = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet\OpticalFlows\';
OViFFPATH = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet\OpticalViFFlows\';

switch(upper(FLOWTYPE))
    case 'SIFTFLOW'
        addpath(genpath(SIFTPATH));
        FLOWDIR = SIFTPATH;
    case 'OPTICALFLOW'
        addpath(genpath(OFPATH));
        FLOWDIR = OFPATH;
    case 'VIFFLOW'
        addpath(genpath(OViFFPATH));
        FLOWDIR = OViFFPATH;
end



end

