%% get trial data

clc
close all
clear

%% CONFIG
para = CONFIG;
Animal_ID = 'FNT099';

%% write intermediate variables and save locally

% get list of files containing session-level behavioural data for each mouse
filelist_behaviour = dir(fullfile(para.input_folder, Animal_ID,'**', '*experimental-data.csv'));

% acquire trial-level information from ceph and save locally
sessionNum=37;

session_data_filepath = fullfile(filelist_behaviour(sessionNum).folder, ...
    filelist_behaviour(sessionNum).name);
session_ID = get_session_ID(session_data_filepath);

% get intermediate trial variables
trial_data_session = get_trial_data(session_data_filepath);
stage_5_trial_types = dir(fullfile(filelist_behaviour(sessionNum).folder, 'stage5_trial_types*.csv'));
stage_5_trial_types = readtable(fullfile(stage_5_trial_types.folder, stage_5_trial_types.name));
stage_5_trial_types = stage_5_trial_types(2:height(trial_data_session)+1,:); % accounting for first trial erroneously removed from bonsai output
audio_offset_delay = trial_data_session.DotOffsetTime-trial_data_session.AudioCueEnd;

trial_data_session.stage5_catch_trial = stage_5_trial_types;

%% derive performance on catch versus non-catch trials
stage5_catch_trial=table2array(trial_data_session.stage5_catch_trial);

% calculate accuracy and bias of catch trials 
catch_trials = trial_data_session(stage5_catch_trial==1,:);
catch_trials_summary = get_session_summary(para, catch_trials);
audio_offset_delay(stage5_catch_trial==1)

% calculate accuracy and bias of non-catch trials
noncatch_trials = trial_data_session(stage5_catch_trial==0,:);
noncatch_trials_summary = get_session_summary(para, noncatch_trials);