%% write table to folder that does not yet exist

function save_table(T, output_folder, fileName)
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    writetable(T, fullfile(output_folder, fileName));
end