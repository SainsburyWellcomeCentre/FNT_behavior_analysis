function trial_data = read_trial_data(filepath)
% reads in table of trial-level intermediate variables saved under
% specified filepath

    opts = detectImportOptions(filepath);
    opts = setvartype(opts,{'Animal_ID','Session_ID'},{'char', 'char'});
    %opts = setvartype(opts, {'CorrectTrial', 'AbortTrial'}, {'logical',
    %'logical'}); <-- this reads all values as 0s for some reason??
    
    trial_data = readtable(filepath, opts);
    
    % Convert CorrectTrial to logicals
    trial_data.CorrectTrial = logical(trial_data.CorrectTrial);
end