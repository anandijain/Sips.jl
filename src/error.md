# error

Hello, I've been trying to debug an error for a little bit now, but I'm finding the error message a little cryptic, the one liner is :
`ERROR: LoadError: TypeError: in typeassert, expected Float64, got ForwardDiff.Dual{Nothing,Float64,12}`

The program is ~150 lines, so I'll try to pick the stuff I think might be relevant to debugging:
I am using DiffEqFlux to take an array with rank 9 through a Flux chain like so:

```julia
dudt = Chain(Dense(dim, 20, tanh)
            ,Dense(20, dim)) |> gpu

n_ode(x) = neural_ode(gpu(dudt), gpu(x), tspan, AutoTsit5(Rosenbrock23()),maxiters=1e7, saveat=t, reltol=1e-5, abstol=1e-7)

```

[stacktrace (long)](https://pastebin.com/ycpb9ve5)

[code]()