
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
