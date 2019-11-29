module LoadData

using CSV
using DataFrames
using PyCall
h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


function get_data()
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	dfs = h.get_dfs(dir)
	data = serialize_dfs_py(dfs)
end


function serialize_dfs_py(dfs)
	data = h.apply_min_then_filter(dfs)
	#  "quarter", "secs", "a_pts", "h_pts", "h_ml"
	sdfs = s.serialize_dfs(data, in_cols=["last_mod", "a_ml"], dont_hot=true)
end


function df_to_ts(df)
    # ts = LoadData.my_normalize()
    ts = df[:, 1]
    u = df[:, 2:end]
    return ts, u
end


end
