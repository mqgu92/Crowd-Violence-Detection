%
%   REturns the ROC plots for the old method of testing the Cardiff dataset
%


%% MBP SUBNAME
IMSIZE = [150,150];
MATRIXSIZE = 3;
TIMESTEP = [1,4,8,16];
THRESH = 5;
FRAMEJUMP = 5;
BASE = false;

    subName = strcat('[',num2str(IMSIZE),'IS,',...
    num2str(MATRIXSIZE),'MS,[',...
    num2str(TIMESTEP),']TS,',...
    num2str(THRESH),'T,',...
    num2str(FRAMEJUMP),'FJ,',...
    num2str(BASE),'B,',...
    'MBP]');

     words = 500;        %   Vocab
     features = 250;     %   Feature points per scene
     trainperc = 0.70;   %   Percentage of data to train
     seqLength = [5,15,30];     
     windowskip = 40;
     trajSpatial = 5;
     accessMethod = 'RANDOM';
     pyr = [1,1];
     
    subName = strcat('[',num2str(words),'Wo,',...
    num2str(features),'F,',...
    num2str(seqLength),'W,',...
    num2str(windowskip),'WS,',...
    num2str(pyr),'PYR,',...
    'SF]');
subName = '[1000Wo,250F,15  30W,15WS,1  1PYR,SF]';
METHOD = 'TrajHoF';
RESULTSNAME = strcat(METHOD,{' '},'RESULTS',subName);
STREAMRESULTSNAME = strcat(METHOD,{' '},'STREAM RESULTS',subName);

%% Oniel 
%load(strcat(RESULTSNAME{1},'-NO ONIEL.mat'));
load(strcat(STREAMRESULTSNAME{1},'-NO-ONIELSVM.mat'));
desc = ones(1,length(PLIST)); desc(1020:1450) = 2;
[X,Y,T,ONIELAUC] = perfcurve( desc , mean(cell2mat(PROB),2) ,2 );
figure, plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(ONIELAUC)));
%% WOOD 
%load(strcat(RESULTSNAME{1},'-NO ONIEL.mat'));
load(strcat(STREAMRESULTSNAME{1},'-NO-WOODSVM.mat'));
desc = ones(1,length(PLIST)); desc(1175:1300) = 2;
[X,Y,T,WOODAUC] = perfcurve( desc , mean(cell2mat(PROB),2) , 2);
figure, plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(WOODAUC)));
%% BAD 
%load(strcat(RESULTSNAME{1},'-NO ONIEL.mat'));
load(strcat(STREAMRESULTSNAME{1},'-NO-BADSVM.mat'));
desc = ones(1,length(PLIST)); desc(1076:1164) = 2;
[X,Y,T,BADAUC] = perfcurve( desc , mean(cell2mat(PROB),2) , 2 );
figure, plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(BADAUC)));
%% STAND 
%load(strcat(RESULTSNAME{1},'-NO ONIEL.mat'));
load(strcat(STREAMRESULTSNAME{1},'-NO-STANDUPSVM.mat'));
desc = ones(1,length(PLIST)); desc(126:233) = 2;
[X,Y,T,STANDAUC] = perfcurve( desc , mean(cell2mat(PROB),2) , 2 );
figure, plot(X,Y);
xlabel('False positive rate'); 
ylabel('True positive rate');
title(strcat('AUC: ',num2str(STANDAUC)));