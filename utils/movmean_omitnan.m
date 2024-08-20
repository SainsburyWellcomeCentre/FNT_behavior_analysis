function trialOutcome_movmean = movmean_omitnan(x,w)

    validTrialOutcome = x(~isnan(x));
    validTrial_movmean = movmean(validTrialOutcome, w, 'omitnan');
    
    trialOutcome_movmean = x;
    trialOutcome_movmean(~isnan(x))=validTrial_movmean;
    trialOutcome_movmean = fillmissing(trialOutcome_movmean, 'previous');

end