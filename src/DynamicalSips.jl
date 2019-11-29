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
pyplot()


function main()
  cols = ["last_mod", "num_markets", "quarter", "secs", "a_pts", "h_pts", "a_ps", "h_ps", "a_ml", "h_ml"]
  dfs = LoadData.get_data(cols)
end

games = main()

# first game
df = rand(games)
len = size(df)[1]


# add striding
view_start = div(len, 2)
view_end = len
stride_amt = 1


# take subset of data
subset = view(df, view_start:stride_amt:view_end, :)

mls = subset[:, end-1:end]
display(mls)
# convert moneylines into decimal
decimals = map(SipsUtils.eq , mls)

display(decimals)
subset[:, end-1:end] = decimals

# first column
t = copy(Array(subset[:, 1])) |> gpu


# adjust offset to t0 = 0
t = (t .- t[1]) ./ 1000


# get min max
tspan = t[1], t[end]
# plot(t)


# other columns
data = copy(subset[:, 2:end]') |> gpu
target_data = data[:, 2:end]

# first row
u0 = data[:, 1] |> gpu


# dimension of ode
dim = length(u0)


# neural net chain
dudt = Chain(Dense(dim, 15, tanh)
            ,Dense(15, 40, tanh)
            ,Dense(40, dim)) |> gpu

n_ode(x) = neural_ode(gpu(dudt), gpu(x), tspan, AutoTsit5(Rosenbrock23()), maxiters=1e7, saveat=t, reltol=1e-4, abstol=1e-5)


function predict_n_ode()
  n_ode(u0)
end


loss_n_ode() = sum(abs2, target_data .- predict_n_ode())


cur_pred = Flux.data(predict_n_ode())

display(string("target data shape: ", size(target_data)))
display(string("pred shape: ", size(cur_pred)))

cur_loss = loss_n_ode()
display(string("loss: ", cur_loss))

# function loss_given_preds(preds)
#   loss = sum(abs2,data .- preds)
#   return loss
# end


repeated_data = Iterators.repeated((), 1000)
opt = ADAM(0.1)

cur_pred = Flux.data(predict_n_ode())

losses = []

cb = function ()
  cur_pred = Flux.data(predict_n_ode())

  display(string("data shape: ", size(data)))
  display(string("pred shape: ", size(cur_pred)))

  cur_loss = loss_n_ode()
  display(string("loss: ", cur_loss))
  append!(losses, cur_loss)

  pred_a_ml = cur_pred[end-1, :]
  pred_h_ml = cur_pred[end, :]
  
  real_a_ml = data[end-1, :]
  real_h_ml = data[end, :]
  
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
  display(real_a_ml')
  
  println("")
  println("")

  pl = scatter(t, data[end-1:end, :]', label="data")
  scatter!(pl, t, cur_pred[end-1:end, :]', label="prediction")
  yticks!([-5:5;])
  xticks!(t[1]:t[end])

  display(plot(pl, size=(900, 900)))
end

# Display the ODE with the initial parameter values.
cb()

ps = Flux.params(dudt)
Flux.train!(loss_n_ode, ps, repeated_data, opt, cb = Flux.throttle(cb, 5))

loss_plot = scatter(losses)
display(plot(loss_plot, size=(900, 900)))

end
