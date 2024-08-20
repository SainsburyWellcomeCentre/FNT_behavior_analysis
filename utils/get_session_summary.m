function session_summary = get_session_summary(para, trial_data_mouse)

    % omit first n trials from analysis
    trial_data_mouse = trial_data_mouse(trial_data_mouse.TrialNumber>para.num_trials_discard,:);

    % index rows corresponding to each session
    sessionIdx = findgroups(cellstr(trial_data_mouse.Session_ID));
    
    % get session summary info
    session_summary = table();
    session_summary.Animal_ID = splitapply(@(x) {unique(cellstr(x))}, trial_data_mouse.Animal_ID, sessionIdx);
    session_summary.Session_ID = splitapply(@(x) {unique(cellstr(x))}, trial_data_mouse.Session_ID, sessionIdx);
    session_summary.session_folder_ceph = splitapply(@(x) {unique(cellstr(x))}, trial_data_mouse.session_folder_ceph, sessionIdx);
    session_summary.Stage = splitapply(@(x) {unique(x)}, trial_data_mouse.TrainingStage, sessionIdx);
    session_summary.Substage = splitapply(@(x) {unique(x)}, trial_data_mouse.TrainingSubstage, sessionIdx);
    session_summary.AudioCueIdentities = splitapply(@(x) {unique(x)}, trial_data_mouse.AudioCueIdentity, sessionIdx);
    
    % get session summary stats
    session_summary.sessionDuration_mins = splitapply(@(x,y) (y(end)-x(1))/60, trial_data_mouse.TrialStart, trial_data_mouse.TrialEnd, sessionIdx);
    session_summary.numTrials = splitapply(@(x) length(x), trial_data_mouse.CorrectTrial, sessionIdx);
    session_summary.numTrialsCompleted = splitapply(@(x) sum(~x), trial_data_mouse.AbortTrial, sessionIdx);
    session_summary.abortNosepokeRate = splitapply(@(x) sum(x==1)/length(x), trial_data_mouse.AbortTrial, sessionIdx);
    session_summary.abortDotOffsetRate = splitapply(@(x) sum(x==-1)/length(x), trial_data_mouse.AbortTrial, sessionIdx);
    session_summary.accuracy_all_trials = splitapply(@(x) sum(x)/sum(~isnan(x)), trial_data_mouse.CorrectTrial, sessionIdx);
    session_summary.accuracy_all_trials_bpci = get_bpci(session_summary.accuracy_all_trials, session_summary.numTrials);
    session_summary.accuracy_completed_trials = splitapply(@(x,y) sum(x)/sum(~logical(y)), trial_data_mouse.CorrectTrial, trial_data_mouse.AbortTrial, sessionIdx);
    session_summary.accuracy_completed_trials_bpci = get_bpci(session_summary.accuracy_completed_trials, session_summary.numTrialsCompleted);
    session_summary.choice_bias = splitapply(@(x) sum(x==1)/sum(~isnan(x)), trial_data_mouse.ChoicePort, sessionIdx);
    session_summary.choice_bias_bpci = get_bpci(session_summary.choice_bias, session_summary.numTrialsCompleted);
    session_summary.mean_time_to_offset_dot = splitapply(@(x,y) mean(y-x), trial_data_mouse.DotOnsetTime, trial_data_mouse.DotOffsetTime, sessionIdx);
    session_summary.mean_time_to_nosepoke = splitapply(@(x,y) mean(y-x), trial_data_mouse.DotOffsetTime, trial_data_mouse.NosepokeInTime, sessionIdx);

    % preindex ephys summary info
    session_summary.electrodeConfiguration = repmat(cellstr(""), height(session_summary),1);
    session_summary.referenceChannel = repmat(cellstr(""), height(session_summary),1);

    % get ephys summary information 
    for i=1:height(session_summary)
        % find all settings.xml files located within session folder
        filelist_ephys = dir(fullfile(string(session_summary.session_folder_ceph(i,:)),'**','*settings.xml'));
        if length(filelist_ephys)==1
            settings = xml2struct(fullfile(filelist_ephys.folder, filelist_ephys.name));
            signal_chain = settings.SETTINGS.SIGNALCHAIN;
            if isscalar(signal_chain) % without NI-daq
                session_attributes = signal_chain.PROCESSOR{1,1}.EDITOR.NP_PROBE.Attributes;
            else % with NI-daq
                session_attributes = signal_chain{1,1}.PROCESSOR{1,1}.EDITOR.NP_PROBE.Attributes;
            end
            session_summary.electrodeConfiguration(i) = cellstr(session_attributes.electrodeConfigurationPreset);
            session_summary.referenceChannel(i) = cellstr(session_attributes.referenceChannel);
        elseif length(filelist_ephys)>1
            warning(strcat("More than one recording detected in session folder ", ...
                session_summary.session_folder_ceph(i,:), ". Ephys analysis skipped."))

        else

        end
    end

end