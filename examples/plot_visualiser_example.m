%% config

para = CONFIG;
Animal_ID = '98';
sessionNum=24;

titleFontSize=16;

plot_against_time = false;
w=20;

%% extract trial data

% get list of files containing session-level behavioural data for each mouse
filelist_behaviour = dir(fullfile(para.input_folder, Animal_ID,'**', '*experimental-data.csv'));
session_data_filepath = fullfile(filelist_behaviour(sessionNum).folder, ...
        filelist_behaviour(sessionNum).name);
session_ID = get_session_ID(session_data_filepath);

% output folder for session intermediate variables
output_folder_session = fullfile(para.output_folder, 'intermediate_variables', Animal_ID);
filename = strcat(Animal_ID, '_', session_ID, '_trial_data.csv');

trial_data_session = read_trial_data(fullfile(output_folder_session, filename));

%% extract plot variables

Session_ID = trial_data_session.Session_ID(1,:);
Animal_ID = trial_data_session.Animal_ID(1,:);

correctTrial = double(trial_data_session.CorrectTrial);
correctCompletedTrial = correctTrial; 
correctCompletedTrial(trial_data_session.AbortTrial==1)=nan;

accuracy_movmean_all_trials = movmean_omitnan(correctTrial, w);
accuracy_movmean_completed_trials = movmean_omitnan(correctCompletedTrial, w);

choice_bias_movmean = movmean_omitnan(trial_data_session.ChoicePort, w);

abort_rate_movmean = movmean_omitnan(double(trial_data_session.AbortTrial),w);

ime_to_dot_offset = trial_data_session.DotOffsetTime-trial_data_session.DotOnsetTime;
time_to_dot_offset(trial_data_session.AbortTrial)=nan;
time_to_dot_offset_movmean = movmean_omitnan(time_to_dot_offset, w);
time_to_nosepoke = trial_data_session.NosepokeInTime - trial_data_session.DotOffsetTime;
time_to_nosepoke(trial_data_session.AbortTrial)=nan;
time_to_nosepoke_movmean = movmean_omitnan(time_to_nosepoke, w);

if plot_against_time
    x = NosepokeInTime;
    x(trial_data_session.AbortTrial==1)=nan;
else
    x = 1:height(trial_data_session);
end

%% plot local accuracy and choice bias
disp(strcat("Plotting session ", Session_ID, " ..."));

fig = figure('Visible','on', 'Position', [178 79 1543 883]);
tl = tiledlayout(2,1);
tl.Padding = "compact";

title(tl,[strcat("Mouse ", Animal_ID), Session_ID, ""], "FontSize", titleFontSize+2);
xlabel(tl, 'Trial Number', "FontSize",titleFontSize);

ax1 = nexttile;
    hold on;
    title(ax1, strcat('Plot performance over sliding window, length m=', num2str(w)), 'FontSize',titleFontSize)
    pl1 = plot(x, accuracy_movmean_completed_trials, 'LineWidth', 2, 'color', ...
        para.colour_accuracy);
    pl2 = plot(x, choice_bias_movmean, 'color', para.colour_choice, 'LineWidth', 2);
    pl3 = plot(x, abort_rate_movmean, 'color', para.colour_abortRate, 'LineWidth', 2);
    yline(0.5, '--', "LineWidth",1);
    ylim([0 1]);
    xlim([min(x) max(x)]);
    xlabel('Trial Number', 'FontSize', titleFontSize);
    legend([pl1 pl2 pl3], {'Fraction Correct', 'Fraction Chose Port 1', 'Fraction Aborted'}, ...
        'FontSize', titleFontSize, 'Location','eastoutside');

ax2 = nexttile;
    hold on;

     hold on;
    title(ax2, strcat('Plot response time over sliding window, length m=', num2str(w)), 'FontSize',titleFontSize);
    pl1 = plot(x, time_to_dot_offset_movmean, 'color', [0.3010 0.7450 0.9330], 'LineWidth', 2);
    pl2 = plot(x, time_to_nosepoke_movmean, "Color", [0.4940 0.1840 0.5560], 'LineWidth',2);
    xlim([min(x) max(x)]);
    ylabel('Time (s)', 'FontSize',titleFontSize);
    legend([pl1 pl2], {'Time taken from dot onset to offset', 'Time taken from dot offset to nosepoke'}, ...
        'FontSize', titleFontSize, 'Location','eastoutside');
