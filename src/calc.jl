using Statistics
using StatsBase
using LinearAlgebra
using DataFrames

# todo last_mod dt epsilon nudging  

game_lengths = Dict{String, Int}(
    "bask" => 2880,
    "foot" => 3600
)

period_counts = Dict{String, Int}(
    "bask" => 4,
    "foot" => 4
)

period_lengths = Dict{String, Int}(
    "bask" => 720,
    "foot" => 900
)

function seconds_remaining(sport::String, df::Union{Matrix, DataFrame})::Array{Int}
    time_remaining_array = secs_left.(sport, df.quarter, df.secs)
end


function secs_left(sport::String, q::Int, secs::Int)::Int
    if secs == -1
        return game_lengths[sport]
    else
        q_time = (period_counts[sport] - q) * period_lengths[sport]  
        remaining = q_time + secs
    end
end


function to_deci(subset)
    # convert moneylines into decimal
    mls = subset[:, end-1:end]
    decimals = map(SipsUtils.eq , mls)
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