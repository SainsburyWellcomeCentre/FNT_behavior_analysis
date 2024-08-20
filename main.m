clc
close all
clear

%% CONFIG
para = CONFIG;
Animal_ID = para.Animal_ID;

%% write intermediate variables and save locally

% get list of files containing session-level behavioural data for each mouse
filelist_behaviour = dir(fullfile(para.input_folder, Animal_ID,'**', '*experimental-data.csv'));

% concatenate within-session data from all sessions for animal
trial_data_mouse = table();

% acquire trial-level information from ceph and save locally
for sessionNum=1:length(filelist_behaviour)

    session_data_filepath = fullfile(filelist_behaviour(sessionNum).folder, ...
            filelist_behaviour(sessionNum).name);
    session_ID = get_session_ID(session_data_filepath);

    % output folder for session intermediate variables
    output_folder_session = fullfile(para.output_folder, 'intermediate_variables', Animal_ID, session_ID);
    filename = strcat(Animal_ID, '_', session_ID, '_trial_data.csv');

    if ~isfile(fullfile(output_folder_session, filename))
        trial_data_session = get_trial_data(session_data_filepath);
        save_table(trial_data_session, output_folder_session, filename);
    else % if trial summary already exists
       trial_data_session = read_trial_data(fullfile(output_folder_session, filename));
    end

    %concatenate across all sessions 
    trial_data_mouse = [trial_data_mouse;trial_data_session];

end

%% summarise session-level information

% behavioural data summary and ephys metadata for each session
sessions_summary = get_session_summary(para,trial_data_mouse);

% save to local directory
writetable(sessions_summary, fullfile(para.output_folder, 'intermediate_variables', ...
    strcat('sessions_summary_', Animal_ID, '.csv')));

%% plot session summary information

fig = plot_sessions_summary(para, sessions_summary);
output_folder = fullfile(para.output_folder, 'plot_performance_across_sessions');
filename = strcat('plot_session_bias_accuracy_', Animal_ID);
save_figure(fig, output_folder, filename);

%% plot changes in signal quality over time (if ephys signal quality metadata exists).
if isfile(fullfile(para.output_folder, 'ephys_signal_quality', ['quality_metrics_KS3_metadata_', Animal_ID,'.csv']))
    fig = plot_signal_quality_across_sessions(para, sessions_summary);
    output_folder = fullfile(para.output_folder, 'plot_data_quality_across_sessions');
    filename = strcat('plot_data_quality_', Animal_ID);
    save_figure(fig, output_folder, filename);
else
    warning(strcat("No ephys metadata found for animal ", Animal_ID, ". Skipping plot of signal quality."))
end

%% plot trial summary information (within each session)

filelist = dir(fullfile(para.output_folder, 'intermediate_variables', ...
    Animal_ID, '*trial_data.csv'));

% loop through all session with local trial-level data saved
for sessionNum=1:length(filelist)

    % read trial-level information
    trial_data_session = read_trial_data(fullfile(filelist(sessionNum).folder, filelist(sessionNum).name));
    Session_ID = trial_data_session.Session_ID(1,:);

    % plot accuracy, choice / abort trial bias, response times
    output_folder = fullfile(para.output_folder, 'plot_performance_across_trials', Animal_ID);
    filename = strcat('plot_trial_bias_accuracy_', Animal_ID, '_', Session_ID);
    if ~isfile(fullfile(output_folder, strcat(filename, '.png')))
        fig = plot_trials_summary(para, trial_data_session);
        save_figure(fig, output_folder, filename);
        close
    else
        disp(strcat("Skipping ", Session_ID, " session plot as it already exists."))
    end

end
