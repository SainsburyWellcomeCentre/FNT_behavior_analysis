function fig = plot_trials_summary(para, trial_data_session)
% Accepts trial-level data obtained via get_trial_data and outputs plots
% summarising bias and accuracy variation across trials within a session.
    %% plot params
    titleFontSize=16;
    accuracy_ylims = [0.2 1];
    choice_ylims = [0 1];
    
    plot_against_time = false;
    w=15; % maybe make this an optional argument?

%% extract plot variables
    
    Session_ID = trial_data_session.Session_ID(1,:);
    Animal_ID = trial_data_session.Animal_ID(1,:);

    correctTrial = double(trial_data_session.CorrectTrial);
    correctCompletedTrial = correctTrial; 
    correctCompletedTrial(~trial_data_session.AbortTrial==0)=nan;
    
    accuracy_movmean_all_trials = movmean_omitnan(correctTrial, w);
    accuracy_movmean_completed_trials = movmean_omitnan(correctCompletedTrial, w);
    
    choice_bias_movmean = movmean_omitnan(trial_data_session.ChoicePort, w);
    
    % rolling average of % aborted trials for which the animal was cued for
    % port 1
    abortedTrialCue = double(trial_data_session.CorrectPort);
    abortedTrialCue(~logical(trial_data_session.AbortTrial)) = nan;
    abort_trial_bias_movmean = movmean_omitnan(abortedTrialCue,w);

    time_to_dot_offset = trial_data_session.DotOffsetTime-trial_data_session.DotOnsetTime;
    time_to_dot_offset(logical(trial_data_session.AbortTrial))=nan;
    time_to_dot_offset_movmean = movmean_omitnan(time_to_dot_offset, w);
    time_to_nosepoke = trial_data_session.NosepokeInTime - trial_data_session.DotOffsetTime;
    time_to_nosepoke(logical(trial_data_session.AbortTrial))=nan;
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
    tl = tiledlayout(3,1);
    tl.Padding = "compact";
    
    title(tl,[strcat("Mouse ", Animal_ID), Session_ID, ""], "FontSize", titleFontSize+2);
    xlabel(tl, 'Trial Number', "FontSize",titleFontSize);
    
    ax1 = nexttile;
        hold on;
        title(ax1, strcat('Plot accuracy over sliding window, length m=', num2str(w)), 'FontSize',titleFontSize)
        pl1 = plot(x, accuracy_movmean_completed_trials, 'LineWidth', 2, 'color', ...
            para.colour_accuracy);
        pl2 = plot(x, accuracy_movmean_all_trials, 'LineWidth', 2, 'Color', ...
            para.colour_accuracy, 'LineStyle','--');
        xline(para.num_trials_discard+1, '--');
        yline(0.5, '--', "LineWidth",1);
        ylim(accuracy_ylims)
        xlim([min(x) max(x)]);
        ylabel('Fraction of Correct Trials', "FontSize",titleFontSize);
        legend([pl1 pl2], {'Fraction of Completed Trials', 'Fraction of All Trials'}, ...
            'FontSize', titleFontSize, 'Location','eastoutside');
    
    ax2 = nexttile;
        hold on;
        title(ax2, strcat('Plot local port biases over sliding window, length m=', num2str(w)), 'FontSize',titleFontSize);
        pl1 = plot(x, choice_bias_movmean, 'color', para.colour_choice, 'LineWidth', 2);
        pl2 = plot(x, abort_trial_bias_movmean, 'color', para.colour_abortRate, 'LineWidth',2);
        pl3 = scatter(x, double(abortedTrialCue), 'MarkerEdgeColor',para.colour_abortRate, 'SizeData',50, 'Marker','o');
        xline(para.num_trials_discard+1, '--');
        yline(0.5, ':', "LineWidth",1);
        ylim(choice_ylims)
        xlim([min(x) max(x)]);
        ylabel('Ratio Port 1 / Port 0', "FontSize",titleFontSize);
        legend([pl1 pl2 pl3], {'% (non-aborted) trials chose port 1', '% aborted trials cued port 1', 'Aborted trial cued port 0/1'}, ...
                   'FontSize', titleFontSize, 'Location','eastoutside');
    ax3 = nexttile;
        hold on;
        title(ax3, strcat('Plot response time over sliding window, length m=', num2str(w)), 'FontSize',titleFontSize);
        pl1 = plot(x, time_to_dot_offset_movmean, 'color', [0.3010 0.7450 0.9330], 'LineWidth', 2);
        pl2 = plot(x, time_to_nosepoke_movmean, "Color", [0.4940 0.1840 0.5560], 'LineWidth',2);
        xline(para.num_trials_discard+1, '--');
        xlim([min(x) max(x)]);
        ylabel('Time (s)', 'FontSize',titleFontSize);
        legend([pl1 pl2], {'Time taken from dot onset to offset', 'Time taken from dot offset to nosepoke'}, ...
            'FontSize', titleFontSize, 'Location','eastoutside');
    disp("Done.")
    

end