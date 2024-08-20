function Animal_ID = get_animal_ID(session_data_filepath)
% extract Animal ID from filepath
    Animal_ID = strsplit(session_data_filepath, filesep);
    Animal_ID = Animal_ID{1,end-3};
end