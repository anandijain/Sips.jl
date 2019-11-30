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




function print_shapes(dfs)
	for (i, g) in enumerate(d)
		println(string(i, ": ", size(a)))
	end
end


end
