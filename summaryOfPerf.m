function [sens, spec, ppv, npv, acc, fscore, AUC, str,optimalthresh] = summaryOfPerf(singleClassLabels, dec_values, positive_class, ...
                                                                    label, printFlag, plotFlag, optimalThreshIn,nameFile)
%% Obtain classification scores from learning algorithms
% en [X,Y] = perfcurve(labels,scores,posclass)
% INPUTS: singleClassLabels = Ground truth labels -> = labels
%         dec_values = Decision results -> = scores
%         label = string -> empty []
%         printFlag = Boolean to display results in command line
%         plotFlag = Boolean to plot accuracy and ROC
%         optimalThreshIn = Optimal threshold -> empty []
%         nameFile = String name of file -> empty []
%
% Outputs: sens = Sensitivity 
%          spec = Specificity
%          ppv = Positive predictive value 
%          npv = Negative predictive value
%          acc = accuracy
%          fscore = F1-score
%          AUC = Area under the curve
%          str = String with results
%          optimalthresh = Optimal threhsold (if not provided)
  
%%
  % Convert to double if labels are categorical
 if isa(singleClassLabels,'categorical')
     singleClassLabels = cast(singleClassLabels,'double')-1;
     %dec_values = cast(dec_values,'double')-1;
     positive_class = 1;
 end
                                                                
 singleClassLabels = double(singleClassLabels(:));
 dec_values = dec_values(:);
predict_label = zeros(size(singleClassLabels));

[fpr, tpr, thresh, AUC, OPTROCPT] = perfcurve(singleClassLabels, dec_values, positive_class);
[fpr, accu, thresh] = perfcurve(singleClassLabels, dec_values, positive_class,'ycrit','accu');

if (plotFlag == 1)
    figure
    subplot(211)
    plot(thresh, accu);
    title('Plot of Classifcation Boundary');
    xlabel('Threshold for ''good'' Returns');
    ylabel('Classification Accuracy');
    subplot(212)
    plot(fpr, tpr);
    hold on
    plot(OPTROCPT(1),OPTROCPT(2),'ro')
    title(['ROC Curve ' nameFile]);
    xlabel('False Positive Rate');
    ylabel('True Positive Rate');
%     saveas(gcf,[pathROC filesep nameFile '.png'])
%    close
end

if isempty(optimalThreshIn)
    [maxaccu,iaccu] = max(accu);
    optimalthresh = thresh(iaccu);
else
    optimalthresh = optimalThreshIn;
end
predict_label(dec_values < optimalthresh) = -1;
predict_label(dec_values >= optimalthresh) = 1;

% CHange Class Labels to -1/+1 if not in that form
singleClassLabels(singleClassLabels == 0) = -1;

tp = sum(singleClassLabels == 1 & predict_label == 1);
tn = sum(singleClassLabels==-1 & predict_label==-1);
fp = sum(singleClassLabels==-1 & predict_label == 1);
fn = sum(singleClassLabels == 1 & predict_label==-1);

sens = tp/(tp+fn); % also called recall.
spec = tn/(tn+fp);

ppv = tp/(tp+fp);  % also called precision
npv = tn/(tn+fn);

acc = (tp+tn)/(tp+tn+fp+fn);

fscore = 2*ppv*sens/(ppv+sens); % F1 score reaches its best value at 1 and worst score at 0.

% Save plot with NaN scores

% if isnan(fscore) || isnan(npv)
%     figure
%     subplot(211)
%     plot(thresh, accu);
%     title('Plot of Classifcation Boundary');
%     xlabel('Threshold for ''good'' Returns');
%     ylabel('Classification Accuracy');
%     subplot(212)
%     plot(fpr, tpr);
%     title(['ROC Curve ' nameFile 'F-score: ']);
%     xlabel('False Positive Rate');
%     ylabel('True Positive Rate');
%     saveas(gcf,[pathROC filesep nameFile '.png'])
%     close
% end


str = sprintf('%s had an AUC %0.3f and accuracy of %0.3f (FScore %0.3f, Sens %0.3f, Spec %0.3f, PPV %0.3f, NPV %0.3f)\n', ...
            label, AUC, acc, fscore, sens, spec, ppv, npv);
if (printFlag == 1)
    fprintf(1, str);
end

%[predictResponse,scores] = predict(SVMiono.ClassificationSVM, Xtest)
%scores=scores(:,2)
%editar el comado acá y luego copiar y pegar en comand window
%%%%%%[sens, spec, ppv, npv, acc, fscore, AUC, str,optimalthresh] = summaryOfPerf(datatest(:,2), scores, 1, ...
%%%%%%                                                              [], 1, 1, [],[])
