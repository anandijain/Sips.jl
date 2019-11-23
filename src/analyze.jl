using CSV
using DataFrames
using Missings


function get_dfs()
    dir = "../sips/data/lines/lines/"
    fns = readdir(dir)
    dfs = [CSV.read(string(dir, fn)) for fn in fns]
    return dfs
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


dfs = get_dfs()
columns = [:quarter, :secs, :a_pts, :h_pts, :a_ml, :h_ml]
df = dfs[1]


p = parse_df(df[:, columns])

