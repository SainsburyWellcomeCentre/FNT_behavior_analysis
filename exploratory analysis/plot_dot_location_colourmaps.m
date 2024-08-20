clc
close all


%% CONFIG
para = CONFIG;
Animal_ID = '104';

output_folder = ['C:\Users\megan\Documents\sjlab\flexible-navigation-task' ...
    '\exploratory_analysis\plot_dot_location_colourmaps'];
%% summarise session-level information

% load metadata for each session
filename = strcat('sessions_summary_', Animal_ID, '.csv');
sessions_summary = readtable(fullfile(para.output_folder, ...
    'intermediate_variables', filename));

% remove sessions with accuracy <70%
sessions_summary(sessions_summary.accuracy_completed_trials<0.7,:) = [];

% remove sessions with <100 completed trials
sessions_summary(sessions_summary.numTrialsCompleted<100,:)=[];

% remove all sessions before dot location was finalised (11.04.2024)
for i = 1:height(sessions_summary)
    sessionDateTime(i,:) = datetime(sessions_summary.Session_ID{i,1}, ...
        'Format','uuuu-MM-dd''T''HH-mm-ss');
end
dot_locations_finalised = datetime('2024-04-11T09-00-00', 'Format', ...
    'uuuu-MM-dd''T''HH-mm-ss');
sessions_summary(sessionDateTime<dot_locations_finalised,:)=[];


%% concatenate trial level data for remaining sessions
% acquire trial-level information from ceph and save locally

trial_data_mouse = table();
trial_data_folder = fullfile(para.output_folder, 'intermediate_variables', ...
    Animal_ID);
for sessionNum=1:height(sessions_summary)

    session_ID = sessions_summary.Session_ID(sessionNum);
    filename = strcat(Animal_ID, '_', session_ID{1,1}, '_trial_data.csv');

    trial_data_session = read_trial_data(fullfile(trial_data_folder, ...
        filename));

    % concatenate across all sessions 
    trial_data_mouse = [trial_data_mouse; trial_data_session];

end

% remove erroneous dot location at 0.6495, -0.15
RX = trial_data_mouse.DotXLocation==0.649519026000000;
RY = trial_data_mouse.DotYLocation==-0.150000006000000;
trial_data_mouse(RX&RY,:) = [];

%% Get summary statistics for each dot location in selected sessions

[dotLocationIdx, DotXLocation, DotYLocation] = findgroups( ...
    trial_data_mouse.DotXLocation, trial_data_mouse.DotYLocation);

dot_locations_summary = table(DotXLocation, DotYLocation);

dot_locations_summary.numTrials = splitapply(@(x) length(x), trial_data_mouse.CorrectTrial, dotLocationIdx);
dot_locations_summary.numTrialsCompleted = splitapply(@(x) sum(~x), trial_data_mouse.AbortTrial, dotLocationIdx);
dot_locations_summary.abortNosepokeRate = splitapply(@(x) sum(x==1)/length(x), trial_data_mouse.AbortTrial, dotLocationIdx);
dot_locations_summary.abortDotOffsetRate = splitapply(@(x) sum(x==-1)/length(x), trial_data_mouse.AbortTrial, dotLocationIdx);
dot_locations_summary.accuracy_all_trials = splitapply(@(x) sum(x)/sum(~isnan(x)), trial_data_mouse.CorrectTrial, dotLocationIdx);
dot_locations_summary.accuracy_all_trials_bpci = get_bpci(dot_locations_summary.accuracy_all_trials, dot_locations_summary.numTrials);
dot_locations_summary.accuracy_completed_trials = splitapply(@(x,y) sum(x)/sum(~logical(y)), trial_data_mouse.CorrectTrial, trial_data_mouse.AbortTrial, dotLocationIdx);
dot_locations_summary.accuracy_completed_trials_bpci = get_bpci(dot_locations_summary.accuracy_completed_trials, dot_locations_summary.numTrialsCompleted);
dot_locations_summary.choice_bias = splitapply(@(x) sum(x==1)/sum(~isnan(x)), trial_data_mouse.ChoicePort, dotLocationIdx);
dot_locations_summary.choice_bias_bpci = get_bpci(dot_locations_summary.choice_bias, dot_locations_summary.numTrialsCompleted);
dot_locations_summary.mean_time_to_offset_dot = splitapply(@(x,y) mean(y-x), trial_data_mouse.DotOnsetTime, trial_data_mouse.DotOffsetTime, dotLocationIdx);
dot_locations_summary.mean_time_to_nosepoke = splitapply(@(x,y) mean(y-x), trial_data_mouse.DotOffsetTime, trial_data_mouse.NosepokeInTime, dotLocationIdx);


%% plot accuracy for each dot location
% Erroneous dot location at 0.64951902,-0.15 (removed after sessions run 
% on 24.04.2024)

c1 = [185, 204, 230]/255;   % colour for 0% accuracy
c2 = [11 176 104]/255;      % colour for 100% accuracy

% total number of trials
n = sum(dot_locations_summary.numTrialsCompleted);

fig = figure();
title(["Plot accuracy of completed trials for each dot location", ...
    strcat("Mouse ",Animal_ID, ", Num Trials = ", num2str(n))," "], FontSize=14);
% Clear the axes.
cla

% Fix the axis limits.
xlim([-1 1]);
ylim([-1 1]);

% Set the axis aspect ratio to 1:1.
axis square

 centers = [dot_locations_summary.DotXLocation, dot_locations_summary.DotYLocation];
 radii = repmat(0.15/2,height(dot_locations_summary),1);
 accuracy = dot_locations_summary.accuracy_completed_trials;
 a_max = max(accuracy);
 a_min = min(accuracy);

% colours = accuracy.*c2 + (1-accuracy).*c1;
% viscircles(centers, radii, 'Color', colours);
hold on
viscircles([0 0], 1, 'Color', 'k')

% loop through each dot location -- need to customise colour gradient to
% vary between minimum and maximum accuracy!
for i=1:height(dot_locations_summary)
    center = centers(i,:);
    radius = radii(i);
    dot_accuracy = dot_locations_summary.accuracy_completed_trials(i);
    % select colour sampled from range c1,c2 by accuracy (normalised by min
    % / max accuracy).
    c = (a_max-dot_accuracy)*c2/(a_max-a_min) + (dot_accuracy-a_min)*c1/(a_max-a_min);
    %viscircles(center, radius, 'Color', c); can't figure out how to do
    %this filled...
    scatter(centers(i,1), centers(i,2),'o', 'filled', 'MarkerFaceColor',c, ...
        'MarkerEdgeColor','none', 'SizeData',250);

end

save_figure(fig, output_folder, strcat('plot_accuracy_colourmap_',Animal_ID));

%% plot bias for each dot location
% Erroneous dot location at 0.64951902,-0.15 (removed after sessions run 
% on 24.04.2024)

c1 = [185, 204, 230]/255;   % colour for 100% chose port 0
c2 = [11 176 104]/255;      % colour for 100% chose port 1

fig = figure();
title(["Plot average choice bias for each dot location",strcat("Mouse ", ...
    Animal_ID, ", Num Trials = ", num2str(n))," "], 'FontSize',14);
% Clear the axes.
cla

% Fix the axis limits.
xlim([-1 1])
ylim([-1 1])

% Set the axis aspect ratio to 1:1.
axis square

 centers = [dot_locations_summary.DotXLocation, dot_locations_summary.DotYLocation];
 radii = repmat(0.15/2,height(dot_locations_summary),1);
 choice_bias = dot_locations_summary.choice_bias;
 b_max = max(choice_bias);
 b_min = min(choice_bias);

% colours = accuracy.*c2 + (1-accuracy).*c1;
% viscircles(centers, radii, 'Color', colours);
hold on
viscircles([0 0], 1, 'Color', 'k')

% loop through each dot location -- need to customise colour gradient to
% vary between minimum and maximum accuracy!
for i=1:height(dot_locations_summary)
    center = centers(i,:);
    radius = radii(i);
    dot_choice_bias = dot_locations_summary.choice_bias(i);
    % select colour sampled from range c1,c2 by accuracy (normalised by min
    % / max accuracy).
    c = (b_max-dot_choice_bias)*c2/(b_max-b_min) + (dot_choice_bias-b_min)*c1/(b_max-b_min);
    %viscircles(center, radius, 'Color', c); can't figure out how to do
    %this with filled circles... try Patch instead ? 
    %this filled...
    scatter(centers(i,1), centers(i,2),'o', 'filled', 'MarkerFaceColor',c, ...
        'MarkerEdgeColor','none', 'SizeData',250);

end

save_figure(fig, output_folder, strcat('plot_bias_colourmap_',Animal_ID));
