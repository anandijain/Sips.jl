module LoadData

using CSV
using DataFrames


function get_fns()
    dir = "/home/sippycups/absa/sips/data/lines/lines/"
    fns = readdir(dir)
    full_fns = map(x -> string(dir, x), fns)
end


function get_data(cols; set_dtype=false, output_dtype=Float64, to_matrices=true)
    full_fns = get_fns()
    parsed = map(fn -> convert(Matrix{output_dtype}, get_and_parse_game(fn, cols)), full_fns)
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
        df[!, str_col_name] = tryparse.(Int, df[:, str_col_name])
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



end
