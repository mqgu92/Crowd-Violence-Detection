function [ Significant, Normal ,DATA ] = PerformSignificance( SET1, SET2 )
 
 Set1Normal = kstest(SET1);
 Set2Normal = kstest(SET2);
 
 % Check if we have rejected the Null Hyposthesis (They are the same)
if Set1Normal == 0 && Set2Normal == 0
    Normal = true;
    % Test if the difference is significant
    disp('Using Students T-test');
    [h,p,ci,stats] = ttest2(SET1,SET2);
    Significant = h;
    DATA = {h,p,ci,stats};
else
    Normal = false;
    disp('Using Wilcoxin RankSum');
    [P,H] = ranksum(SET1,SET2);
    Significant = H;
    DATA = {P,H};
end
 
if Significant == 1
    disp('Null Hyp rejected, Therefore significantly different');
else
    disp('Null Hyp cannot be Rejected, Therefore similar sets');
end

end

