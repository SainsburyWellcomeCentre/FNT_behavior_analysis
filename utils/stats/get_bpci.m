function bpci = get_bpci(p, n)
    % calculate binomial proportion confidence interval for n trials with a
    % probability of success p
    % z set to 1.96 for .95 confidence bounds
    bpci = 1.96*sqrt(p.*(1-p)./n);
end