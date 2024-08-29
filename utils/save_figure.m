function save_figure(fig, folderName, filename)
    if ~exist(folderName, 'dir')
        mkdir(folderName);
    end
    saveas(fig, fullfile(folderName, strcat(filename, ".fig")));
    saveas(fig, fullfile(folderName, strcat(filename, ".png")));

%     pos = get(fig,'Position');
%     set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% 
%     print(fig,fullfile(folderName, filename),'-dpdf','-r0')

end
