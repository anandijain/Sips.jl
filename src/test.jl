
function time_read_dfs_jl(dir, cols)
	@time dfs = get_dfs(dir)
	@time w_cols = get_columns_from_dfs(dfs, cols)
	return w_cols
end

function time_read_serialize_py(dir, cols)

	@time pydfs = get_dfs_py(dir)
	@time pysdfs = serialize_dfs_py(pydfs)
end

function get_dfs(dir="/home/sippycups/absa/sips/data/lines/lines/")
    fns = readdir(dir)
    # print(fns)
    dfs = [CSV.read(string(dir, fn)) for fn in fns]
end


function get_columns_from_dfs(dfs, cols)
    specific_columns = []
    for df in dfs
        append!(df[:, cols], specific_columns)
    end
    return specific_columns


function time_data_retrievals()
    cols = [:last_mod, :num_markets, :quarter, :secs, :a_pts, :h_pts, :a_ml, :h_ml]
    py_cols = map(String, cols)
    println("julia time")
    @time data = LoadData.get_data_jl(cols)
    
    println("python time")
    @time py_data = LoadData.get_data_py(py_cols)
end    

end
