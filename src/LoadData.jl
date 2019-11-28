module LoadData

using CSV
using DataFrames
using PyCall
h = pyimport("sips.h.helpers")
s = pyimport("sips.h.serialize")


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
end


function get_dfs_py(dir)
	dfs = h.get_dfs(dir)
	return dfs
end


function serialize_dfs_py(dfs)
	data = h.apply_min_then_filter(dfs)
	sdfs = s.serialize_dfs(data, in_cols=["last_mod", "quarter", "secs", "a_pts", "h_pts", "a_ml", "h_ml"], dont_hot=true)
end

function get_data()
	dir = "/home/sippycups/absa/sips/data/lines/lines/"
	dfs = get_dfs_py(dir)
	data = serialize_dfs_py(dfs)
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


function print_shapes(dfs)
	for (i, g) in enumerate(d)
		println(string(i, ": ", size(a)))
	end
end


# NFL: 900 secs
# NBA: 720 secs
function parse_df(df)
    idxs = []
    evens = []
    for (i, row) in enumerate(eachrow(df))
        for (j, elt) in enumerate(row)
            if elt == "None"
                append!(idxs,  i)
            elseif elt == "EVEN"
                append!(evens, (i, j))
            end
        end
    end
    deleterows!(df, unique(idxs))
    ret = tryparse.(Int, df)
    for tup in evens
        setindex!(df, 100, tup)
    end
end


end

# data = main()
