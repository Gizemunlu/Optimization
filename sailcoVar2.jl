using JuMP, Clp, Printf

dt = [40 60 75 25 ]  # Each quarter demands for boats.

m = Model(with_optimizer(Clp.Optimizer))

#variables
@variable(m, 0 <= x[0:4] <= 40)     # Sailboats produced with regular labor.
@variable(m, y[0:4] >= 0)           # Sailboats produced with overtime labor.
@variable(m, ci[1:4] >= 0 )         # Increase in production.
@variable(m, cd[1:4] >= 0 )         # Decrease in production.
@variable(m, k[1:4] >= 0)           # k[] represents number of sailboats on hand at end of quarter

#constraints
@constraint(m, k[1] == 10 + x[1] + y[1] - dt[1] )
@constraint(m, k[4] >= 10)
@constraint(m, x[1] + y[1] == 50)
@constraint(m, ci[1] - cd[1] == x[1] + y[1] - 50)
@constraint(m, flow[t in 2:4], k[t]== k[t-1]+x[t]+y[t]-dt[t])
@constraint(m, stream[t in 2:4], ci[t] - cd[t] == x[t] + y[t]- (x[t-1] + y[t-1]))

#objective
@objective(m, Min, 400*sum(x)+ 450*sum(y)+ 20*sum(k)+ 400*sum(ci)+ 500*sum(cd))   # minimize costs

optimize!(m)

@printf("Sailboats to build regular labor:  %d %d %d %d  \n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Sailboats to build extra labor:  %d %d %d %d \n",value(y[1]),  value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d  \n", value(k[1]), value(k[2]), value(k[3]), value(k[4]))
@printf("C+ values: %d %d %d %d \n", value(ci[1]), value(ci[2]), value(ci[3]), value(ci[4]))
@printf("C- values: %d %d %d %d \n", value(cd[1]), value(cd[2]), value(cd[3]), value(cd[4]))
@printf("Objective cost: %f\n", objective_value(m))
