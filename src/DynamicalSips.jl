module DynamicalSips

using DifferentialEquations
using Flux, DiffEqFlux
using Plots
using BenchmarkTools
using CuArrays

# ;cd src

include("load.jl")
include("utils.jl")
using .LoadData
using .SipsUtils


function main()
  cols = ["last_mod", "num_markets", "quarter", "secs", "a_pts", "h_pts", "a_ps", "h_ps", "a_ml", "h_ml"]
  dfs = LoadData.get_data(cols)
end

games = main()

# first game
df = rand(games)
len = size(df)[1]

# add striding
view_start = div(len, 4)
view_end = len
stride_amt = 5

# take subset of data
subset = view(df, view_start:stride_amt:view_end, :)

# convert moneylines into decimal
subset[:, end-1:end] = map(SipsUtils.eq , subset[:, end-1:end])


# first column
t = copy(Array(subset[:, 1])) |> gpu

# adjust offset to t0 = 0
t -= t[0]

# get min max
tspan = t[0], t[end]

plot(t)

# other columns
data = copy(subset[:, 2:end]') |> gpu

# first row
u0 = data[:, 1] |> gpu

# dimension of ode
dim = length(u0)

# neural net chain
dudt = Chain(Dense(dim, 15, tanh)
            ,Dense(15, 40, tanh)
            ,Dense(40, dim)) |> gpu

n_ode(x) = neural_ode(gpu(dudt), gpu(x), tspan, AutoTsit5(Rosenbrock23()), maxiters=1e7, saveat=t, reltol=1e-7, abstol=1e-9)

function predict_n_ode()
  n_ode(u0)
end

@time predicted = predict_n_ode()

loss_n_ode() = sum(abs2,data .- predict_n_ode())

example_loss = loss_n_ode()


repeated_data = Iterators.repeated((), 1000)
opt = ADAM(0.1)

cb = function () #callback function to observe training
  display(loss_n_ode())
  
  # plot current prediction against data
  cur_pred = Flux.data(predict_n_ode())
  display(cur_pred)
  # display(size(cur_pred))

  pl = scatter(t, data[end-1:end, :]', label="data")
  scatter!(pl, t, cur_pred[end-1:end, :]', label="prediction")
  yticks!([-5:1:5;])
  xticks!(tspan[1]:1:tspan[2])
  display(plot(pl, fig))
end

# Display the ODE with the initial parameter values.
cb()

ps = Flux.params(dudt)
Flux.train!(loss_n_ode, ps, repeated_data, opt, cb = Flux.throttle(cb, 5))


end
