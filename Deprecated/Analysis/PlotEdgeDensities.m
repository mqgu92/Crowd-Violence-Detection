 VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\Video\';
addpath('Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\')
 VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Hockey DataSet\SIFTFlows\FLOWS\Cross\' );
 CLASS = 'Fight';
 
%  VIDLIST  = vidListGenFNHockey( 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\SIFTFlows\' );
%    VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\Cardiff DataSet Four\VideoCutsSmall\';
     % VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';
      
%VIDLIST  = vidListGenFNHockey('Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\SIFTFlows\' );
%VIDDIR = 'Z:\Summer Project\You can (not) redo\DATA\ViF Dataset\Videos - Copy';

     addpath(VIDDIR);
% VIDLIST = VIDLIST(find(ismember(VIDLIST(:,3),CLASS)),:);

EDGEStats = zeros(length(VIDLIST),2);
ORIENTSeries = {};
BINS = 8;
ORIENTMean = zeros(length(VIDLIST),BINS);
ORIENTVar = zeros(length(VIDLIST),BINS);
 for v = 1 : length(VIDLIST)
     disp(num2str(v));
        [PATHSTR,NAME,EXT] = fileparts(VIDLIST{v,1});
        [ EdgeCol Orient] = GetEdgeDensities( [VIDDIR,'\',NAME,'.avi'],true ,BINS);
        
        EDGEStats(v,1) = EdgeCol{2};
        EDGEStats(v,2) = EdgeCol{3};
        
        ORIENTSeries = [ORIENTSeries;Orient{1}];
        ORIENTMean(v,1:BINS) = Orient{2};
        ORIENTVar(v,1:BINS) = Orient{3};
        
 end
 
 
 METRIC = EDGEStats(:,1);
 METRICVAR = EDGEStats(:,2);
 
 FIGHTEND = 501
 
 FM = zeros(FIGHTEND-1,1) + mean(METRIC(1:FIGHTEND - 1));
 NFM = zeros(length(METRIC(FIGHTEND:end)),1) + mean(METRIC(FIGHTEND:end));
 
 F = METRIC; F(FIGHTEND:end) = 0;
 NF = METRIC; NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Normalized Edge Count');
 title('Average Edge Count per Video');
 axis tight
  %% Test is distributions are normal
 

 
 
 FM = zeros(FIGHTEND-1,1) + mean(sqrt(METRICVAR(1:FIGHTEND - 1)));
 NFM = zeros(length(METRICVAR(FIGHTEND:end)),1) + mean(sqrt(METRICVAR(FIGHTEND:end)));
 
 F = sqrt(METRICVAR); F(FIGHTEND:end) = 0;
 NF = sqrt(METRICVAR); NF(1:FIGHTEND - 1) = 0;
 figure,bar(F,'b'); hold on; bar(NF,'g','EdgeColor','g');hold on; plot([FM;NFM],'r')
 xlabel('Video Sample (Violence, Non-Violence)');
 ylabel('Edge Variance');
 title('Edge Count Variance per Video');
 axis tight
 
 % Anova 
 %F = METRIC(FIGHTEND:end); NF = METRIC(1:FIGHTEND - 1);
 %p = anova1([F;NF],[zeros(length(F),1);ones(length(NF),1)]);
 
 % Other Null Tests
[ Significant,Normal, DATA ] = PerformSignificance( METRIC(FIGHTEND:end), METRIC(1:FIGHTEND - 1) );
[ Significant,Normal, DATA ] = PerformSignificance( METRICVAR(FIGHTEND:end), METRICVAR(1:FIGHTEND - 1) );
