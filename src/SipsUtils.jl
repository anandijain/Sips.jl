module SipsUtils

using StatsBase


function my_standardize(xs)
	mu = mean(xs)
	dev = std(xs)
	map(x -> (x - mu) / dev, xs)
end


function my_normalize(xs)
	lo = minimum(xs)
	hi = maximum(xs)
	map(x -> (x - lo) / (hi - lo), xs)
end

function print_shapes(dfs)
	for (i, g) in enumerate(d)
		println(string(i, ": ", size(a)))
	end
end

end
