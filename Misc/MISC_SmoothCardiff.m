function [ CO,C TP,TN] = MISC_SmoothCardiff( ANNOTATIONS,FINAL,PROB,NOTFIGHTVAL,FIGHTVAL,SmoothingWindow,SmoothingVal,DataSplit )



OUTPUT = ones(length(ANNOTATIONS),1) * NOTFIGHTVAL;

for i = 1: length(ANNOTATIONS) - SmoothingWindow
   
        if sum( ismember(FINAL(i:i + SmoothingWindow),...
            FIGHTVAL)) > SmoothingVal
        OUTPUT(i + SmoothingWindow) = FIGHTVAL;
        end
end
OUTPUT = OUTPUT(SmoothingWindow:end);
ANNOTATIONS = ANNOTATIONS(SmoothingWindow:end);

CPerf = classperf(ANNOTATIONS, OUTPUT);
CO = CPerf.CorrectRate;s
C = confusionmat(ANNOTATIONS,OUTPUT);

[TP, TN] = MISC_PlotConfusion(C,DataSplit{1,5});

end


