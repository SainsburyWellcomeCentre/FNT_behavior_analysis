function fig = plot_sessions_summary(para, sessions_summary)

    % Plot params
    plot_dayNum = false; % determines whether to plot data against date or session number
    titleFontSize=16;
    faceAlpha = 0.15;
    accuracy_ylims = [0.2 1];
    choice_ylims = [0 1];

    % Get indeces of stage progressions
    Stage = cell2mat(sessions_summary.Stage);
    changeIdx = ~(Stage - [0;Stage(1:end-1)])==0;
    changeIdx = find(changeIdx);

    %% configure plot layout

    fig = figure('Visible','on', 'Position', [278 79 1260 883]);
    tl = tiledlayout(2,1);
    tl.Padding = "compact";

    Animal_ID = sessions_summary.Animal_ID{1,1};

    title(tl,[strcat("Mouse ", Animal_ID, " Session Summary Data") ""], "FontSize", titleFontSize+2);
    xlabel(tl, 'Days since training started', "FontSize",titleFontSize);
    
    % define x-axis data
    if plot_dayNum
        dayNum = (sessions_summary.Session_ID');
        dayNum = datenum(dayNum, 'yyyy-mm-dd');
        dayNum = dayNum-dayNum(1);
        x = dayNum;
    else
        x = 1:height(sessions_summary);
        x = x';
    end

    ephys_recording_bank1 = (sessions_summary.electrodeConfiguration=="All Shanks 1-96");
    ephys_recording_bank2 = (sessions_summary.electrodeConfiguration=="All Shanks 97-192");
    ephys_recording_bank3 = (sessions_summary.electrodeConfiguration=="All Shanks 193-288");
    ephys_recording_bank4 = (sessions_summary.electrodeConfiguration=="All Shanks 289-384");


    %% plot accuracy of all non-aborted trials
    ax1 = nexttile;
        hold on;
        title(ax1, 'Plot performance over sessions', 'FontSize',titleFontSize)
        pl1 = plot_shaded_error_bar(x, sessions_summary.accuracy_completed_trials, ...
            sessions_summary.accuracy_completed_trials_bpci, para.colour_accuracy, faceAlpha);
        pl2 = plot(x, sessions_summary.accuracy_all_trials, 'LineWidth', 2, 'Color', ...
            para.colour_accuracy, 'LineStyle','--');
        yline(0.5, '--', "LineWidth",1);
        yline(0.7, ':', "LineWidth",1);

        % mark recording banks for sessions with ephys data
        pl3 = mark_condition(x,sessions_summary.accuracy_completed_trials, ...
            ephys_recording_bank1,para.colour_accuracy,'square',70);
        pl4 = mark_condition(x,sessions_summary.accuracy_completed_trials, ...
            ephys_recording_bank2,para.colour_accuracy,'o',50);
        pl5 = mark_condition(x,sessions_summary.accuracy_completed_trials, ...
            ephys_recording_bank3,para.colour_accuracy,'diamond',50);
        pl6 = mark_condition(x,sessions_summary.accuracy_completed_trials, ...
            ephys_recording_bank4,para.colour_accuracy,'^',50);

        % mark any stage progressions
        for i = 1:length(changeIdx)
            StageStr = strcat("Stage ",num2str(Stage(changeIdx(i))));
            xline(changeIdx(i), '--', StageStr, 'FontSize',titleFontSize-4);
        end

        ylim(accuracy_ylims)
        xlim([min(x) max(x)]);
        ylabel('Fraction of Correct Trials', "FontSize",titleFontSize);
        legend([pl1 pl2 pl3 pl4 pl5 pl6], {'Fraction of Completed Trials', 'Fraction of All Trials', ...
            'Recording Bank 1', 'Recording Bank 2', 'Recording Bank 3', 'Recording Bank 4'}, ...
            'FontSize', titleFontSize, 'Location','eastoutside');
    
    %% plot choice bias on all non-aborted trials (for which choice was port 0 or port 1)
    
    ax2 = nexttile;
        hold on;
        title(ax2, 'Plot choice bias over sessions', 'FontSize',titleFontSize);
        pl1 = plot_shaded_error_bar(x, sessions_summary.choice_bias, ...
            sessions_summary.choice_bias_bpci, para.colour_choice, faceAlpha);

        % mark any stage progressions
        for i = 1:length(changeIdx)
            StageStr = strcat("Stage ",num2str(Stage(changeIdx(i))));
            xline(changeIdx(i), '--', StageStr, 'FontSize',titleFontSize-4);
        end
        
        yline(0.5, '--', "LineWidth",1);
        ylim(choice_ylims)
        xlim([min(x) max(x)]);
        ylabel('Choice Ratio Port 1 / Port 0', "FontSize",titleFontSize);

end