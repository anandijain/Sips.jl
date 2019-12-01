module SipsUtils

using StatsBase


function get_dfs(dir="/home/sippycups/absa/sips/data/lines/lines/")
    fns = readdir(dir)
    dfs = map(fn -> CSV.read(string(dir, fn)), fns)
end


function print_shapes(dfs)
	for (i, g) in enumerate(d)
		println(string(i, ": ", size(a)))
	end
end


end
