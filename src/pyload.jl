module PyLoad

using PyCall

h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


function get_data_py(cols)
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	dfs = h.get_dfs(dir)
	data = h.apply_length_bounds(dfs)
	data = s.serialize_dfs(dfs, in_cols=cols, norm=false, dont_hot=true)
end

end