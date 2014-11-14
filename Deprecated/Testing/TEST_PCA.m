function TEST_PCA( ALL_FEATURES,ALL_CLASSES, SAVENAME,BASE )
%%
%
%
%
%%
    if nargin <3
        BASE = '';
    end
    PCADATA = cell2mat(ALL_FEATURES);
    % PCA
    [COEFF2,SCORE2, e] = princomp(PCADATA);
    red_dim = SCORE2(:,1:3);
    [g gn] = grp2idx(ALL_CLASSES);
    
    % Scatter graph based on Fight/NotFight
    PCAScatter = figure,gscatter(red_dim(:,1),red_dim(:,2),g,'br','oo');
    legend(gn);
     
    xlabel('1st Scaled Coordinate');
    ylabel('2nd Scaled Coordinate');
    
    name = strcat(BASE,'PCA [TwoClass]',SAVENAME);
    saveas(PCAScatter,name,'fig')
    saveas(PCAScatter,name,'jpg')
    set(PCAScatter,'Visible','off')

    
    PCAScatter3 = figure,gscatter3(red_dim(:,1),red_dim(:,2),red_dim(:,3),g);
    legend(gn);
     
    xlabel('1st Scaled Coordinate');
    ylabel('2nd Scaled Coordinate');
    
    name = strcat(BASE,'PCA [TwoClass 3D] ',SAVENAME);
    saveas(PCAScatter3,name,'fig')
    saveas(PCAScatter3,name,'jpg')
    set(PCAScatter3,'Visible','off')
    
    % Eigen Weights
    if length(e) < 20
     EigenBar = figure,bar(e(1:end));
    else
      EigenBar = figure,bar(e(1:20));  
    end
    xlabel('Coordinate Index');
    ylabel('Eigenvalue');
    name = strcat(BASE,'PCA [EigenValue]',SAVENAME);
    saveas(EigenBar,name,'fig')
    saveas(EigenBar,name,'jpg')
    set(EigenBar,'Visible','off')
    clearvars EigenBar name PCAScatter COEFF2 SCORE2 e red_dim;
end

