module DynamicalSips

using DifferentialEquations
using Flux, DiffEqFlux
using Plots
# using CuArrays


include("LoadData.jl")
include("SipsUtils.jl")
using .LoadData
using .SipsUtils

function get_ode_ts(ts)
    lo = minimum(ts)
    hi = maximum(ts)
    return lo, hi
end

function main()
    dfs = LoadData.get_data()
    # games = [df_to_ts(df) for df in dfs]
end

games = main()

# first game
df = rand(games)
shape = size(df)

# add striding
stride_value = 3
subset = view(df, 1:stride_value:shape[1], :)

# first column
t = Array(subset[:, 1])

# other columns
data = subset[:, 2:end]'

# convert odds data to decimal
data = map(SipsUtils.eq, data)


# first row
u0 = data[:, 1]

# dimension of ode
dim = length(u0)

# tspan
tspan = get_ode_ts(t)

# neural net chain
dudt = Chain(Dense(dim,15,tanh)
            # ,Dense(10,15)
            ,Dense(15,dim))


n_ode(x) = neural_ode(dudt, x, tspan, Tsit5(), saveat=t, reltol=1e-7, abstol=1e-9)

function predict_n_ode()
  n_ode(u0)
end

loss_n_ode() = sum(abs2,data[:, 3:end] .- predict_n_ode())

repeated_data = Iterators.repeated((), 1000)
opt = ADAM(0.1)

cb = function () #callback function to observe training
  display(loss_n_ode())
  # plot current prediction against data
  cur_pred = Flux.data(predict_n_ode())
  pl = scatter(t[3:end], data[1, 3:end], label="data")
  # scatter!(pl, t[3:end], data[2, 3:end], label="data")
  scatter!(pl, t[3:end], cur_pred, label="prediction")
  # scatter!(pl, t[3:end], cur_pred[2, :], label="prediction")
  display(plot(pl))
end

# Display the ODE with the initial parameter values.
cb()

ps = Flux.params(dudt)
Flux.train!(loss_n_ode, ps, repeated_data, opt, cb = cb)


end
