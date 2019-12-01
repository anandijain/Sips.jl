module SippyMarks
# benchmarking

using CSV, DataFrames
using BenchmarkTools

include("load.jl")
include("utils.jl")
include("pyload.jl")

using .PyLoad
using .LoadData
using .SipsUtils


function get_data_benchmark(cols)
    println("")
    println("julia benchmark")
    display(@benchmark LoadData.get_data(cols))
    println("")
end

function get_data_py_benchmark(cols)
    println("")
    println("python time")
    display(@benchmark py_data = PyLoad.get_data_py(cols))
    println("")
end

function time_read_dfs_jl(dir, cols)
	@time dfs = get_dfs(dir)
	@time w_cols = get_columns_from_dfs(dfs, cols)
	return w_cols
end


function time_read_serialize_py(dir, cols)

	@time pydfs = get_dfs_py(dir)
	@time pysdfs = serialize_dfs_py(pydfs)
end

function benchmark_both(cols)
    py_cols = map(String, cols)
    
    get_data_benchmark(cols)
    get_data_py_benchmark(py_cols)
end    

cols = [:last_mod, :num_markets, :quarter, :secs, :a_pts, :h_pts, :a_ml, :h_ml]
benchmark_both(cols)


end