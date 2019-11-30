module SipsUtils

using StatsBase


function spec_view(df, view_start, stride_amt, view_end)
	# take subset of data, adjust moneylines to decimal
	subset = view(df, view_start:stride_amt:view_end, :)
	decimals = SipsUtils.to_deci(subset)
	subset[:, end-1] = decimals[:, end-1]
	subset[:, end] = decimals[:, end]
	println("subset")
	display(subset)
	return subset
end


function to_deci(subset)
    # convert moneylines into decimal
    mls = subset[:, end-1:end]
    display(mls)
    decimals = map(SipsUtils.eq , mls)
	display(decimals)
	return decimals
end


function eq(odd :: Int)::Rational
	if odd == 0
		return 0 // 1
	elseif odd > 100
   		return odd // 100
	else
   		return abs(100 // odd)
	end
end

function eq(odd :: Number)::AbstractFloat
	if odd == 0
		return 0.
	elseif odd > 100
   		return odd / 100
	else
   		return abs(100 / odd)
	end
end


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
