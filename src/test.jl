



function get_columns_from_dfs(dfs, cols)
    specific_columns = []
    for df in dfs
        append!(df[:, cols], specific_columns)
    end
    return specific_columns

end
