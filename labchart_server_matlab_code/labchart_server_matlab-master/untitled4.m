X=[];
y=[];

for i=1:length(result_val)
    score = result_val{i};
    posclass = categorical(1);
    labels = result_val_class{i};
    [prec, tpr, fpr, thresh] = prec_rec(score, label, 'plotPR',1)
%     [X,Y,T,AUC,OPTROCPT,SUBY,SUBYNAMES] = perfcurve(labels,score(2,:)-score(1,:),posclass);
    plot(X,Y)
end