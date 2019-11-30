module LoadData

using CSV
using DataFrames
using PyCall
using BenchmarkTools

h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


function get_data_py(cols)
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	dfs = h.get_dfs(dir)
	data = h.apply_length_bounds(dfs)
	data = s.serialize_dfs(dfs, in_cols=cols, norm=false, dont_hot=true)
end

function get_fns()
    dir = "/home/sippycups/absa/sips/data/lines/lines/"
    fns = readdir(dir)
    full_fns = map(x -> string(dir, x), fns)
end


function get_data_jl(cols; to_matrices=true)
    full_fns = get_fns()
    parsed = map(fn -> get_and_parse_game(fn, cols), full_fns)
    if to_matrices
        parsed = map(x -> convert(Matrix, x), parsed)
    end
end


function get_and_parse_game(fn, cols)
    df = CSV.read(fn)[:, cols]
    for col in cols
        df = df[(df[:, col] .!= "None"), :]
    end
    replace!(df.a_ml, "EVEN"=>"100")
    replace!(df.h_ml, "EVEN"=>"100")
    str_col_names = names(df)[eltypes(df) .== String]
    for str_col_name in str_col_names
        df[:, str_col_name] = tryparse.(Int, df[:, str_col_name])
    end
    # display(df)
    return df
end


function df_to_ts(df)
    # ts = LoadData.my_normalize()
    ts = df[:, 1]
    u = df[:, 2:end]
    return ts, u
end

function time_data_retrievals()
    cols = [:last_mod, :num_markets, :quarter, :secs, :a_pts, :h_pts, :a_ml, :h_ml]
    py_cols = map(String, cols)
    println("julia time")
    @time data = get_data_jl(cols)
    
    println("python time")
    @time py_data = get_data_py(py_cols)
end

end
