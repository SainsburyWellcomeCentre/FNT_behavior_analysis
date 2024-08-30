function para = CONFIG

    % directory params
    para.input_folder = 'W:\projects\FlexiVexi\behavioural_data';
    para.output_folder = 'C:\Users\megan\Documents\sjlab\flexible-navigation-task\Data Analysis';
    para.Animal_IDs = ["FNT098"; "FNT099"; "FNT101"; "FNT103"; "FNT104"; "FNT107"; "FNT108"];
    
    % analysis params
    para.num_trials_discard = 15;

    % plot params
    para.colour_accuracy = [0.4660 0.6740 0.1880];
    para.colour_choice = [0 0.4470 0.7410];
    para.colour_abortRate = [0.9290 0.6940 0.1250];

end