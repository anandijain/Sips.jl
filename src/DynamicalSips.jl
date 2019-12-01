module DynamicalSips

using DifferentialEquations
using Flux, DiffEqFlux
using Plots
using BenchmarkTools
using CuArrays

include("load.jl")
include("utils.jl")
using .LoadData
using .SipsUtils

# -- GET AND PREPARE DATA -- #
cols = [:last_mod, :quarter, :secs, :a_ml, :h_ml, :num_markets, :a_pts, :h_pts]
games = LoadData.get_data(cols)
df = rand(games)

len = size(df)[1]
view_start = div(len, 2)
view_end = len
stride_amt = 2

subset = view(df, view_start:stride_amt:view_end, :)


# first column is time
# adjust offset to t0 = 0

t = copy(Array(subset[:, 1])) |> gpu
t = (t .- t[1]) ./ 1000
tspan = t[1], t[end]

# kinda interesting
# plot(t)

# other columns are ode data
data = copy(subset[:, 2:end]')  # notice transposition '
target_data = data |> gpu

# first row is initial conditions
u0 = target_data[:, 1] |> gpu

# dimension of ode
dim = length(u0)

# neural net chain
dudt = Chain(Dense(dim, 20, tanh)
            ,Dense(20, dim)) |> gpu

n_ode(x) = neural_ode(gpu(dudt), gpu(x), tspan, AutoTsit5(Rosenbrock23()), maxiters=1e7, saveat=t, reltol=1e-5, abstol=1e-7)


function predict_n_ode()
  n_ode(u0)
end

loss_n_ode() = sum(abs2, target_data .- predict_n_ode())

cur_pred = Flux.data(predict_n_ode())
display(string("target data shape: ", size(target_data)))
display(string("pred shape: ", size(cur_pred)))

cur_loss = Flux.data(loss_n_ode())
display(string("loss: ", cur_loss))
losses = []

repeated_data = Iterators.repeated((), 1000)
opt = ADAM(0.1)
cb = function ()
  cur_pred = Flux.data(predict_n_ode())

  display(string("target data shape: ", size(target_data)))
  display(string("pred shape: ", size(cur_pred)))

  cur_loss = Flux.data(loss_n_ode())
  display(string("loss: ", cur_loss))
  append!(losses, cur_loss)

  pred_a_ml = cur_pred[1, :]
  pred_h_ml = cur_pred[2, :]
  
  real_a_ml = target_data[, :]
  real_h_ml = target_data[end, :]
  
  println("")
  println("away predictions")
  display(pred_a_ml')
  println("")
  println("away reals")
  display(real_a_ml')
  println("")

  println("home predictions")
  display(pred_h_ml')
  println("")
  println("home real")
  display(real_h_ml')
  
  println("")
  println("")

  pl = scatter(t[2:end], target_data[end-1:end, 2:end]', label="data")
  scatter!(pl, t[2:end], cur_pred[end-1:end, :]', label="prediction")
  yticks!([-5:5;])
  xticks!(t[1]:t[end])

  display(plot(pl, size=(900, 900)))
end

# Display the ODE with the initial parameter values.
cb()

ps = Flux.params(dudt)
# Flux.train!(loss_n_ode, ps, repeated_data, opt, cb = Flux.throttle(cb, 1))
Flux.train!(loss_n_ode, ps, repeated_data, opt, cb = cb)

loss_plot = scatter(Flux.data(losses))
display(plot(loss_plot, size=(900, 900)))
sleep(10)
end
