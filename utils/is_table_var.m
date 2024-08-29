function isTableVar = is_table_var(T, variableName)
    isTableVar = sum(strcmp(variableName,T.Properties.VariableNames));
end