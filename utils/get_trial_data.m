function trial_data = get_trial_data(session_data_filepath)
    % gets trial summary data from '*Experimental-data.csv' output directly
    % from Bonsai

    trial_data = readtable(session_data_filepath);

    % remove collumn 'correctForBias' for outputs which include this
    if is_table_var(trial_data, 'CorrectForBias')
    trial_data = removevars(trial_data, 'CorrectForBias');
    end

    % extract animal ID from filename and add to session_data table
    Animal_ID = get_animal_ID(session_data_filepath);
    trial_data.Animal_ID = repmat(cellstr(Animal_ID), height(trial_data),1);

    % extract session ID from filename and add to session_data table
    Session_ID = get_session_ID(session_data_filepath);
    trial_data.Session_ID = repmat(cellstr(Session_ID), height(trial_data), 1);

    % add session filepath
    %[session_folder_ceph,~,~] = extractBetween(session_data_filepath);
    session_folder_ceph = extractBetween(session_data_filepath, strcat(Animal_ID, filesep), filesep); 
    session_folder_ceph = strcat(extractBefore(session_data_filepath, session_folder_ceph), session_folder_ceph);
    trial_data.session_folder_ceph = repmat(cellstr(session_folder_ceph), height(trial_data),1);

    % Extract logical value for whether trial was correct
    trial_data.CorrectTrial = cellfun(@(x) strcmp(x(1:end-1),'RewardedNosepoke'), trial_data.TrialCompletionCode);

    % mark aborted trials <-- old
    %trial_data.AbortTrial = cellfun(@(x) strcmp(x(1:end-2),'AbortedTrial'), trial_data.TrialCompletionCode);

    % MAKE DISTINCTION BETWEEN ABORTTRIALTYPES
    % annotate aborted nosepokes with '1', aborted dot offsets with -1
    AbortNosepoke = cellfun(@(x) strcmp(x(1:end-2),'AbortedTrial'), trial_data.TrialCompletionCode);
    AbortDotOffset = cellfun(@(x) strcmp(x(1:end-2),'DotTimeLimitReached'), trial_data.TrialCompletionCode);
    trial_data.AbortTrial = zeros(height(trial_data),1);
    trial_data.AbortTrial(AbortNosepoke)=1;
    trial_data.AbortTrial(AbortDotOffset)=-1;

    % Extract chosen port ID for all non-aborted trials
    trial_data.ChoicePort = cellfun(@(x) str2double(x(end)), trial_data.TrialCompletionCode);
    trial_data.AbortTrial(trial_data.ChoicePort==2)=1; % Flag trials for which port 2 as aborted trials
    trial_data.ChoicePort(logical(trial_data.AbortTrial))=nan; % Omit choice port for all aborted trials

    % Extract correct port ID
    CorrectPort = nan(height(trial_data),1);
    CorrectPort(trial_data.AudioCueIdentity==10)=0;
    CorrectPort(trial_data.AudioCueIdentity==14)=1;
    trial_data.CorrectPort = CorrectPort;

    % reorder variables
    trial_data = movevars(trial_data,"Animal_ID",'before',"TrialNumber");
    trial_data = movevars(trial_data,"Session_ID",'before',"TrialNumber");
    trial_data = movevars(trial_data, "session_folder_ceph", 'before', "TrialNumber");
    trial_data = movevars(trial_data,"ChoicePort",'After',"TrialCompletionCode");
    trial_data = movevars(trial_data,"AbortTrial",'After',"TrialCompletionCode");
    trial_data = movevars(trial_data,"CorrectTrial",'After',"TrialCompletionCode");
    trial_data = movevars(trial_data, "CorrectPort", 'After', "ChoicePort");

end