module LoadData

using CSV
using DataFrames
using PyCall
# using BenchmarkTools

h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


function get_data(cols)
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	dfs = h.get_dfs(dir)
	data = h.apply_length_bounds(dfs)
	data = s.serialize_dfs(dfs, in_cols=cols, norm=false, dont_hot=true)
end


function df_to_ts(df)
    # ts = LoadData.my_normalize()
    ts = df[:, 1]
    u = df[:, 2:end]
    return ts, u
end


end
