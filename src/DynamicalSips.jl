# using DifferentialEquations
# using DiffEqFlux


function main()
    u0 = Float32[2.; 0.]
    datasize = 30
    tspan = (0.0f0,1.5f0)
end

function trueODEfunc(du,u,p,t)
    true_A = [-0.1 2.0; -2.0 -0.1]
    du .= ((u.^3)'true_A)'
end

function ode_data()
    t = range(tspan[1],tspan[2],length=datasize)
    prob = ODEProblem(trueODEfunc,u0,tspan)
    ode_data = Array(solve(prob,Tsit5(),saveat=t))
end

dfs = get_dfs()
print(dfs[1])