for i =1 :573
distance(i) = (tpr(i)-1)^2+(fpr(i)-0)^2;
end
[tpr,fpr,thresholds] = roc(target,outpus);