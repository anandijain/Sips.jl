module LoadData

using CSV
using DataFrames
using PyCall
using BenchmarkTools

h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


function get_data(cols)
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	@time dfs = h.get_dfs(dir)
	@time data = h.apply_min_then_filter(dfs)
	@time data = s.serialize_dfs(dfs, in_cols=cols, norm=true, dont_hot=true)
end


function df_to_ts(df)
    # ts = LoadData.my_normalize()
    ts = df[:, 1]
    u = df[:, 2:end]
    return ts, u
end


end
