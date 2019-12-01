module LoadData

using CSV
using DataFrames
using BenchmarkTools

function get_fns()::Array{String, 1}
    dir = "/home/sippycups/absa/sips/data/lines/lines/"
    fns = readdir(dir)
    full_fns = map(x -> string(dir, x), fns)
end


function get_data(cols::Array{Symbol, 1}; set_dtype=false, output_dtype=Float64, to_matrices=true)
    full_fns = get_fns()
    parsed = map(fn -> to_matrices ? convert(Matrix{output_dtype}, get_and_parse_game(fn, cols)) : get_and_parse_game(fn, cols), full_fns)
end


function get_and_parse_game(fn::String, cols::Array{Symbol, 1}; verbose=false)::DataFrame
    df = CSV.read(fn)[:, cols]
    for col in cols
        df = df[(df[:, col] .!= "None"), :]
    end

    df = parse_ml(df)

    if verbose
        display(df)
    end

    return df
end

function parse_ml(df)::DataFrame
    map(ml -> replace!(ml, "EVEN"=>"100"), [df.a_ml, df.h_ml])
    str_col_names = names(df)[eltypes(df) .== String]
    for str_col_name in str_col_names
        df[!, str_col_name] = tryparse.(Int, df[:, str_col_name])
    end
    return df
end



end