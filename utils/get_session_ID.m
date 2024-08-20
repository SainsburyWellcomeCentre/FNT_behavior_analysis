function Session_ID = get_session_ID(session_data_filepath)    
% extract session ID from filepath
    Session_ID = strsplit(session_data_filepath, filesep);
    Session_ID = Session_ID{1,end};
    Session_ID = extractBefore(Session_ID, '_');
end