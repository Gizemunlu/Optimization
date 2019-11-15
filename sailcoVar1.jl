
using JuMP, Clp, Printf

dt = [35 60 75 25 36]  # Each quarter demands for boats.

m = Model(with_optimizer(Clp.Optimizer))

#variables
@variable(m, 0 <= x[0:5] <= 40)   # Sailboats produced with regular labor.
@variable(m, y[0:5] >= 0)         # Sailboats produced with overtime labor.
@variable(m, k[1:5] >= 0)        # k[] represents number of sailboats on hand at end of quarter

#constraints
@constraint(m, k[5] >= 10)
@constraint(m, k[1] == 15)       #  15 sailboats at start of k[1]
@constraint(m, flow[t in 1:4], k[t+1]==k[t]+x[t]+y[t]-dt[t])

#objective
@objective(m, Min, 400*sum(x)+ 450*sum(y)+ 20*sum(k))    # minimize costs

optimize!(m)

@printf("Sailboats to build regular labor:  %d %d %d %d %d \n", value(x[1]), value(x[2]), value(x[3]), value(x[4]), value(x[5]))
@printf("Sailboats to build extra labor:  %d %d %d %d %d \n",value(y[1]),  value(y[2]), value(y[3]), value(y[4]), value(y[5]))
@printf("Inventories: %d %d %d %d %d \n", value(k[1]), value(k[2]), value(k[3]), value(k[4]), value(k[5]))

@printf("Objective Cost: %f\n", objective_value(m))
